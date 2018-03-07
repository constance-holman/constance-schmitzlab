function insert_reward(session_id, reward_type_id, time, varargin)
%insert_session Insert a new row into the RewardType table.
%
%   Syntax: insert_rewardtype(session_id, name, type, ...)
%
%   [IN]
%       session_id          :   Session ID foreign key
%       reward_type_id      :   RewardType ID foreign key
%       time                :   Vector (nx1), time of stimulus presentation
%       verbose             :   (optional) Verbosity flag, default true
%
%
%   Example: insert_reward(1,1, [1;10;100]);
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
    if ~any(strcmp('RewardType', tables))
        fprintf('No RewardType table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('session_id', ...
    @(sid) isscalar(sid) & logical(mysql(sprintf('select count(1) from Session where session_id = %d;', sid))));
p.addRequired('reward_type_id', ...
    @(rtid) isscalar(rtid) & logical(mysql(sprintf('select count(1) from RewardType where reward_type_id = %d;', rtid))));
p.addRequired('time', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('verbose', true, @islogical);
p.parse(session_id, reward_type_id, time, varargin{:});
args = p.Results;

% init query elements
attr = 'session_id, reward_type_id, time';
tmp = [repmat(args.session_id, 1, size(time, 1)); repmat(args.reward_type_id, 1, size(time, 1)); time'];
vals = sprintf('(%d,%d,%f),', tmp);
vals(end) = [];

% build insert query
insert_query = sprintf('insert into Reward(%s) values %s;', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
catch me
    error(me.message)
end

if args.verbose
    fprintf('New Reward(s): %d rows\n', size(args.time, 1));
end
end