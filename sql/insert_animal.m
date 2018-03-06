function animal_id = insert_animal(project_id, varargin)
%insert_animal Insert a new row into the Animal table.
%
%   Syntax: insert_animal(project_id, ...)
%
%   [IN]
%       project_id        :   Project ID foreign key
%       genotype          :   (optional) Animal genotype
%       birthdate         :   (optional) Animal date of birth
%       sex               :   (optional) 'm' for male, 'f' for female  
%       name              :   (optional) Animal name
%       pyrat_id          :   (optional) PyRat ID
%
%   [OUT]
%       animal_id   :   Generated unique experiment identifier
%
%   Example: animal_id = insert_animal(1, 'Sex', 'm', 'Name', 'Mouse1');
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
    if ~any(strcmp('Animal', tables))
        fprintf('No Animal table found.\n')
        return
    end
catch me
    disp(me.message);
    return
end


% parse input args
p = inputParser;
p.addRequired('project_id', ...
    @(pid) logical(mysql(sprintf('select count(1) from Project where project_id = %d;', pid))));
p.addParameter('genotype', '', @ischar);
p.addParameter('birthdate', '', @isdatestr);
p.addParameter('sex', '', @(x) any(strcmpi(x,{'m','f'})));
p.addParameter('name', '', @ischar);
p.addParameter('pyrat_id', '', @ischar);
p.parse(project_id, varargin{:});
args = p.Results;

% init query elements
attr = 'project_id';
vals = ['''', num2str(args.project_id), ''''];

% handle optional input args
if ~isempty(args.genotype)
    attr = [attr, ', genotype'];
    vals = [vals, ', ''', args.genotype, ''''];
end

if ~isempty(args.birthdate)
    attr = [attr, ', birthdate'];
    vals = [vals, ', ''', args.birthdate, ''''];
end

if ~isempty(args.sex)
    attr = [attr, ', sex'];
    vals = [vals, ', ''', args.sex, ''''];
end

if ~isempty(args.name)
    attr = [attr, ', name'];
    vals = [vals, ', ''', args.name, ''''];
end

if ~isempty(args.pyrat_id)
    attr = [attr, ', pyrat_id'];
    vals = [vals, ', ''', args.pyrat_id, ''''];
end

% build insert query
insert_query = sprintf('insert into Animal(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    animal_id = mysql('select max(animal_id) from Animal');
catch me
    disp(me.message)
end

if ~exist('animal_id', 'var') || isempty(animal_id)
    % return failed state flag
    animal_id = -1;
end

end