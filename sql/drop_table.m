function drop_table(DB)
%drop_table Simple wrapper for mysql drop table routine.
%
%   Syntax: drop_table(DB)
%
%   [IN]
%       DB       :  Struct with table names as fieldnames.
%
% Copyright (C) 2017  Viktor Bahr (viktor [at] bccn-berlin.de)
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% test sql connection
try
    tables = mysql('show tables');
catch err
    if isempty(tables)
        fprintf('No tables found.\n');
        return;
    else
        fprintf('Unable to connect.\n');
        return;
    end
end

% drop table(s)
if isstruct(DB)
    fields = flipud(fieldnames(DB)); % flip in order to not violate fk-constraints
    for i = 1:numel(fields)
        if sum(strcmp(tables, fields{i})) == 0
            fprintf('Table ''%s'' not found.\n', fields{i});
            continue;
        end
        try_drop(fields{i});
    end
elseif ischar(DB)
    if is_valid_create_query(DB)
        DB = get_table_name(DB);
    end
    if sum(strcmp(tables, DB)) == 0
        fprintf('Table ''%s'' not found.\n', DB);
        return;
    end
    try_drop(DB);
else
    fprintf('Input has to be string or struct.\n')
end

%% helper functions
    % try to drop tables
    function try_drop(table)
        try
            c = evalc('mysql(sprintf(''drop table %s'', table));');
            fprintf('Droppped ''%s'' table.\n', table);
        catch me
            fprintf('Unable to drop ''%s''.\n', table);
        end
    end

    function valid = is_valid_create_query(str)
        valid = strncmpi(str, 'create table ', 13);
    end

    % extract table name from create query
    function table = get_table_name(query)
        suffix = strsplit(query,'('); % split by first '('
        commands = strsplit(suffix{1}, ' '); % split commands by ' '
        commands(cellfun(@isempty, commands)) = []; % try to drop spaces
        table = commands{end};
        table = strsplit(table, '`'); % try to split by '`'
        table(cellfun(@isempty, table)) = []; % remove '`'
        table = table{1};
    end
end
