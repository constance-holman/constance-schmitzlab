function insert_electrostim(rec_id, time, voltage, varargin)
%insert_electrostim Insert a new row into the ElektroStim table.
%
%   Syntax: insert_electrostim(rec_id, time, voltage, ...)
%
%   [IN]
%       rec_id          :   Recording ID foreign key
%       time            :   Vector (nx1) of stimulation timestamps
%       voltage         :   Vector (nx1) of stimulation voltage
%       verbose         :   (optional) Verbosity flag, default true
%
%   Example: insert_electrostim(1, [100;200;300], [0.5;0.3;0.5]);
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
    if ~any(strcmp('ElectroStim', tables))
        fprintf('No ElectroStim table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('rec_id', ...
    @(rid) isscalar(rid) & logical(mysql(sprintf('select count(1) from Recording where rec_id = %d;', rid))));
p.addRequired('time', @(x) isnumeric(x) & size(x,2) == 1);
p.addRequired('voltage', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('verbose', true, @islogical);
p.parse(rec_id, time, voltage, varargin{:});
args = p.Results;

% init query elements
attr = 'rec_id, time, voltage';
format = '(%d,%f,%f),';
tmp = [repmat(args.rec_id, 1, size(args.time,1)); ...
    args.time'; ...
    args.voltage'];
vals = sprintf(format, tmp);
vals(end) = [];

% build insert query
insert_query = sprintf('insert into ElectroStim(%s) values %s;', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
catch me
    error(me.message)
end

if args.verbose
    fprintf('New ElectroStim(s): %d rows\n', size(args.time, 1));
end

end