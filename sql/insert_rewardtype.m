function reward_type_id = insert_rewardtype(name, type, varargin)
%insert_session Insert a new row into the RewardType table.
%
%   Syntax: insert_rewardtype(session_id, name, type, ...)
%
%   [IN]
%       name                :   Name of reward type
%       type                :   Reward type enum ('positive', 'negative', 'neutral')
%       note                :   (optional) Session notes
%       verbose             :   (optional) Verbosity flag, default true
%
%   [OUT]
%       reward_type_id      :   Generated unique reward type identifier
%
%   Example: reward_type_id = insert_reward_type('Sugar', 'positive');
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
p.addRequired('name', @ischar);
p.addRequired('type', @(x) any(strcmpi(x,{'positive','negative','neutral'})));
p.addParameter('note', '', @ischar);
p.addParameter('verbose', true, @islogical);
p.parse(name, type, varargin{:});
args = p.Results;

% init query elements
attr = 'name, reward_type';
vals = ['''', args.name, ''', ''', args.type, ''''];

% handle optional input args

if ~isempty(args.note)
    attr = [attr, ', note'];
    vals = [vals, ', ''', args.note, ''''];
end

% build insert query
insert_query = sprintf('insert into RewardType(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    reward_type_id = mysql('select max(reward_type_id) from RewardType');
catch me
    error(me.message)
end

if isempty(reward_type_id)
    error('Unable to insert new RewardType.');
elseif args.verbose
    fprintf('New RewardType: %s (ID: %d)\n', vals, reward_type_id);
end
end