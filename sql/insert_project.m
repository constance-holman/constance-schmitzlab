function project_id = insert_project(name)
%insert_project Insert a new row into the Project table.
%
%   Syntax: insert_project(name)
%
%   [IN]
%       name        :   Name of the project
%
%   [OUT]
%       project_id   :   Generated unique project identifier
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
    if ~any(strcmp('Project', tables))
        fprintf('No Project table found.\n')
        return
    end
catch me
    disp(me.message);
    return
end

% handle input args
if isempty(name)
    fprintf('Project name can''t be empty.\n');
    return
end
if ~ischar(name)
    fprintf('Project name has to be a string.\n');
    return
end

% init query elements
attr = 'name';
vals = ['''', name, ''''];

% build insert query
insert_query = sprintf('insert into Project(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    project_id = mysql('select max(project_id) from Project');
catch me
    disp(me.message)
end

if ~exist('project_id', 'var') || isempty(project_id)
    % return failed state flag
    project_id = -1;
end

end