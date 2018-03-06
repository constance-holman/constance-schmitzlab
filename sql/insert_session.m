function session_id = insert_session(animal_id, experiment_id, date, varargin)
%insert_session Insert a new row into the Session table.
%
%   Syntax: insert_session(animal_id, experiment_id, ...)
%
%   [IN]
%       animal_id           :   Animal ID foreign key
%       experiment_id       :   Experiment ID foreign key
%       date                :   Session start date
%       note                :   (optional) Session notes
%       type                :   (optional) Session type (behav, rec, both)
%
%   [OUT]
%       session_id          :   Generated unique session identifier
%
%   Example: session_id = insert_session(1, 3, '13.12.2018', 'Type', 'rec');
%
% Copyright (C) 2018  Viktor Bahr (viktor [at] eridian.systems)
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
    if ~any(strcmp('Session', tables))
        fprintf('No Session table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('animal_id', ...
    @(aid) logical(mysql(sprintf('select count(1) from Animal where animal_id = %d;', aid))));
p.addRequired('experiment_id', ...
    @(eid) logical(mysql(sprintf('select count(1) from Experiment where experiment_id = %d;', eid))));
p.addRequired('date', @isdatestr);
p.addParameter('note', '', @ischar);
p.addParameter('type', '', @(x) any(strcmpi(x,{'behav','rec','both'})));
p.parse(animal_id, experiment_id, date, varargin{:});
args = p.Results;

% init query elements
attr = 'animal_id, experiment_id, start_date';
vals = ['''', num2str(args.animal_id), ''', ''', num2str(args.experiment_id), ''', ''', args.date, ''''];

% handle optional input args

if ~isempty(args.note)
    attr = [attr, ', note'];
    vals = [vals, ', ''', args.note, ''''];
end

if ~isempty(args.type)
    attr = [attr, ', session_type'];
    vals = [vals, ', ''', args.type, ''''];
end

% build insert query
insert_query = sprintf('insert into Session(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    session_id = mysql('select max(session_id) from Session');
catch me
    disp(me.message)
end

if ~exist('session_id', 'var') || isempty(session_id)
    % return failed state flag
    session_id = -1;
end
end