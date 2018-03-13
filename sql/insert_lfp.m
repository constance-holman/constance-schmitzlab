function insert_lfp(rec_id, channel, time, amplitude, varargin)
%insert_lfp Insert a new row into the LFP table.
%
%   Syntax: insert_lfp(rec_id, channel, time, amplitude, ...)
%
%   [IN]
%       rec_id          :   Recording ID foreign key
%       channel         :   Vector (nx1) of channel number
%       time            :   Vector (nx1) of recording time
%       amplitude       :   Vector (nx1) of recording amplitude
%       verbose         :   (optional) Verbosity flag, default true
%
%   Example: insert_lfp(1, [1;1;1], [100;200;300], [0.3;0.4;0.5]);
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
    if ~any(strcmp('LFP', tables))
        fprintf('No LFP table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('rec_id', ...
    @(rid) isscalar(rid) & logical(mysql(sprintf('select count(1) from Recording where rec_id = %d;', rid))));
p.addRequired('channel', @(x) isnumeric(x) & size(x,2) == 1);
p.addRequired('time', @(x) isnumeric(x) & size(x,2) == 1);
p.addRequired('amplitude', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('verbose', true, @islogical);
p.parse(rec_id, channel, time, amplitude, varargin{:});
args = p.Results;

if size(args.time, 1) ~= size(args.amplitude, 1) || ...
        size(args.time, 1) ~= size(args.channel, 1)
    error('Vector length not equal.');
end

% init query elements
attr = 'rec_id, channel, time, amplitude';
format = '(%d,%d,%f,%f),';
tmp = [num2cell(repmat(args.rec_id, 1, size(args.time,1))); ...
    num2cell(args.channel'); ...
    num2cell(args.time'); ...
    num2cell(args.amplitude')];
vals = sprintf(format, tmp{:});
vals(end) = [];

% build insert query
insert_query = sprintf('insert into LFP(%s) values %s;', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
catch me
    error(me.message)
end

if args.verbose
    fprintf('New LFP(s): %d rows\n', size(args.time, 1));
end

end