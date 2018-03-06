function probe_type_id = insert_probetype(type)
%insert_probetype Insert a new row into the ProbeType table.
%
%   Syntax: insert_probetype(type)
%
%   [IN]
%       type        :   Name of the probetype
%
%   [OUT]
%       probe_type_id   :   Generated unique ProbeType identifier
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

% test sql connection, database and table
try
    db = mysql('select database()');
    if isempty(db{1})
        fprintf('No database selected.\n')
        return
    end
    tables = mysql('show tables');
    if ~any(strcmp('ProbeType', tables))
        fprintf('No ProbeType table found.\n')
        return
    end
catch me
    error(me.message);
end

% handle input args
if isempty(type)
    fprintf('ProbeType type can''t be empty.\n');
    return
end
if ~ischar(type)
    fprintf('ProbeType type has to be a string.\n');
    return
end

% init query elements
attr = 'type';
vals = ['''', type, ''''];

% build insert query
insert_query = sprintf('insert into ProbeType(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    probe_type_id = mysql(sprintf('select max(probe_type_id) from ProbeType where type=''%s''', type));
catch me
    disp(me.message)
end

if ~exist('probe_type_id', 'var') || isempty(probe_type_id)
    % return failed state flag
    probe_type_id = -1;
end

end