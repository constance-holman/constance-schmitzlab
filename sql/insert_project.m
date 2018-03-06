function project_id = insert_project(name, varargin)
%insert_project Insert a new row into the Project table.
%
%   Syntax: insert_project(name)
%
%   [IN]
%       name        :   Name of the project
%       verbose     :   (optional) Verbosity flag, default true
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
    error(me.message);
end

% handle input args
p = inputParser;
p.addRequired('name', @ischar);
p.addParameter('verbose', true, @islogical);
p.parse(name, varargin{:});
args = p.Results;

% init query elements
attr = 'name';
vals = ['''', args.name, ''''];

% build insert query
insert_query = sprintf('insert into Project(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    project_id = mysql('select max(project_id) from Project');
catch me
    error(me.message);
end

if isempty(project_id)
    error('Unable to insert new Project.');
elseif args.verbose
    fprintf('New Project: %s (ID: %d)\n', vals, project_id);
end
    
end