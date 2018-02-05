function experiment_id = insert_experiment(project_id, varargin)
%insert_experiment Insert a new row into the Experiment table.
%
%   Syntax: insert_experiment(project_id, 'Experimenter', experimenter, 'Description', description)
%
%   [IN]
%       project_id        :   Project ID foreign key
%       experimenter      :   (optional) Name of the person conducting the experiment
%       description       :   (optional) Experiment description
%
%   [OUT]
%       experiment_id   :   Generated unique experiment identifier
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
    if ~any(strcmp('Experiment', tables))
        fprintf('No Experiment table found.\n')
        return
    end
catch me
    disp(me.message);
    return
end

% parse input args
p = inputParser;
p.addRequired('project_id', ...
    @(pid) mysql(sprintf('select count(1) from Project where project_id = %d;', pid)));
p.addParameter('experimenter', '', @isstr);
p.addParameter('description', '', @isstr);
p.parse(project_id, varargin{:});
args = p.Results;

% init query elements
attr = 'project_id';
vals = ['''', num2str(args.project_id), ''''];

% handle optional input args
if ~isempty(args.experimenter)
    attr = [attr, ', experimenter'];
    vals = [vals, ', ''', args.experimenter, ''''];
end

if ~isempty(args.description)
    attr = [attr, ', description'];
    vals = [vals, ', ''', args.description, ''''];
end

% build insert query
insert_query = sprintf('insert into Experiment(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    experiment_id = mysql('select max(experiment_id) from Experiment');
catch me
    disp(me.message)
end

if ~exist('experiment_id', 'var') || isempty(experiment_id)
    % return failed state flag
    experiment_id = -1;
end
end