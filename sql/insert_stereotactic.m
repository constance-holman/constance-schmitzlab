function insert_stereotactic(animal_id, varargin)
%insert_stereotactic Insert a new row into the StereotacticInjection table.
%
%   Syntax: insert_stereotactic(animal_id,  ...)
%
%   [IN]
%       animal_id       :   Animal ID foreign key
%       virus           :   (optional) Name of injected virus
%       position        :   (optional) Vector (1x2) of [X,Y] position of injection
%       date            :   (optional) Date of injection
%       volume          :   (optional) Injected volume
%       target          :   (optional) Injection target
%       verbose         :   (optional) Verbosity flag, default true
%
%   Example: insert_stereotactic(1, 'Virus', 'Rabies', 'Date', '01.01.2019');
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
    if ~any(strcmp('StereotacticInjection', tables))
        fprintf('No StereotacticInjection table found.\n')
        return
    end
catch me
    disp(me.message);
    return
end


% parse input args
p = inputParser;
p.addRequired('animal_id', ...
    @(aid) logical(mysql(sprintf('select count(1) from Animal where animal_id = %d;', aid))));
p.addParameter('virus', '', @ischar);
p.addParameter('position', '', @(x) isnumeric(x) & numel(x)==2);
p.addParameter('date', '', @isdatestr);
p.addParameter('volume', '', @isnumeric);
p.addParameter('target', '', @ischar);
p.addParameter('verbose', true, @islogical);
p.parse(animal_id, varargin{:});
args = p.Results;

% init query elements
attr = 'animal_id';
vals = [num2str(args.animal_id)];

% handle optional input args
if ~isempty(args.virus)
    attr = [attr, ', virus_name'];
    vals = [vals, ', ''', args.virus, ''''];
end

if ~isempty(args.position)
    attr = [attr, ', x_coord, y_coord'];
    vals = [vals, ', ', num2str(args.position(1)), ', ', num2str(args.position(2))];
end

if ~isempty(args.date)
    attr = [attr, ', date'];
    vals = [vals, ', ''', args.date, ''''];
end

if ~isempty(args.volume)
    attr = [attr, ', volume'];
    vals = [vals, ', ', num2str(args.volume)];
end

if ~isempty(args.target)
    attr = [attr, ', target'];
    vals = [vals, ', ''', args.target, ''''];
end

% build insert query
insert_query = sprintf('insert into StereotacticInjection(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
catch me
    error(me.message)
end

if args.verbose
    fprintf('New StereotacticInjection: %s\n', vals);
end

end