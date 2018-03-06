function insert_behavior(session_id, real, virtual, time, varargin)
%insert_behavior Insert a new row into the Behavior table.
%
%   Syntax: insert_behavior(session_id, ...)
%
%   [IN]
%       session_id          :   Session ID foreign key
%       real                :   Vector (nx2) of [X,Y] real animal position
%       virtual             :   Vector (nx2) of [X,Y] virtual animal position
%       time                :   Vector (nx2) of position timestamps
%       end                 :   (optional) Vector (nx2) logicals about if end of virtual track is reached
%       verbose             :   (optional) Verbosity flag, default true
%
%   Example: insert_behavior(1, [1,2;1,3;2,6], [10,20;10,30;20,60], [1,2,3]);
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
    if ~any(strcmp('Behavior', tables))
        fprintf('No Behavior table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('session_id', ...
    @(sid) isscalar(sid) & logical(mysql(sprintf('select count(1) from Session where session_id = %d;', sid))));
p.addRequired('real', @(x) isnumeric(x) & size(x,2) == 2);
p.addRequired('virtual', @(x) isnumeric(x) & size(x,2) == 2);
p.addRequired('time', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('end', '',  @(x) islogical(x) & size(x,2) == 1);
p.addParameter('verbose', true, @islogical);
p.parse(session_id, real, virtual, time, varargin{:});
args = p.Results;

if size(args.virtual,1) ~= size(args.real,1) || size(args.time,1) ~= size(args.real,1)
    error('Vector length not equal.');
end

% init query elements
attr = 'session_id, real_x, real_y, virt_x, virt_y, time';
format = '(%d,%f,%f,%f,%f,%f),';
tmp = [repmat(args.session_id, 1, size(real, 1)); real'; virtual'; time'];

% handle optional input args
if ~isempty(args.end)
    if size(args.end,1) ~= size(args.real,1)
        error('Vector length not equal.');
    end
    attr = [attr, ', virt_end'];
    format = '(%d,%f,%f,%f,%f,%f,%d),';
    tmp = [tmp; args.end'];
end

vals = sprintf(format, tmp);
vals(end) = [];

% build insert query
insert_query = sprintf('insert into Behavior(%s) values %s;', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
catch me
    error(me.message)
end

if args.verbose
    fprintf('New Behavior(s): %d rows\n', size(args.real, 1));
end

end