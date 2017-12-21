function create_table(DB)
%create_table Simple wrapper for mysql create table routine.
%
%   Syntax: create_table(DB)
%
%   [IN]
%       DB       :  Struct with table names as fieldnames and respective
%       sql create table statement.
%
% Copyright (C) 2017  Viktor Bahr (viktor [at] eridian.systems)
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
    r = evalc('d = mysql(''select database()'')');
catch me
    if isempty(d{1})
        fprintf('No database selected.\n')
        return
    else
        fprintf('Unable to connect.\n');
        return;
    end
end

% create table(s)
if isstruct(DB)
    fields = fieldnames(DB); % get table names
	for i = 1:numel(fields)
        if ~is_valid_create_query(DB.(fields{i}))
            fprintf('DB.%s is not a valid create query.\n', fields{i});
            return;
        end
	    try
            r = evalc('mysql(DB.(fields{i}))');
            fprintf('Created ''%s'' table.\n', fields{i});
	    catch me
            fprintf('Unable to create ''%s'' table.\n', fields{i});
	    end
	end
elseif ischar(DB)
    if ~is_valid_create_query(DB)
        fprintf('DB.%s is not a valid create query.\n', DB);
        return;
    end
    table = get_table_name(DB);
    try
        r = evalc('mysql(DB)');
        fprintf('Created table ''%s''.\n', table);
    catch me
        fprintf('Unable to create ''%s''.\n', table);
    end
else
    fprintf('Input has to be string or struct.\n')
end

%% helper functions
    
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
