function insert_druginjection(rec_id, drug, time, varargin)
%insert_druginjection Insert a new row into the DrugInjection table.
%
%   Syntax: insert_druginjection(rec_id, drug, time, ...)
%
%   [IN]
%       rec_id          :   Recording ID foreign key
%       drug            :   Drug name
%       time            :   Vector (nx1) of injection timestamps
%       volume          :   (optional) Vector (nx1) of injected volume
%       type            :   (optional) Injection type enum(IP, IC, SC, IM)
%       verbose         :   (optional) Verbosity flag, default true
%
%   Example: insert_druginjection(1, 'Lidocain', [10;1000]);
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
    if ~any(strcmp('DrugInjection', tables))
        fprintf('No DrugInjection table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('rec_id', ...
    @(rid) isscalar(rid) & logical(mysql(sprintf('select count(1) from Recording where rec_id = %d;', rid))));
p.addRequired('drug', @ischar);
p.addRequired('time', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('volume', [],  @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('type', '', @(x) isscalar(x) & any(strcmpi(x,{'ip','ic','sc','im'})));
p.addParameter('verbose', true, @islogical);
p.parse(rec_id, drug, time, varargin{:});
args = p.Results;

% init query elements
attr = 'rec_id, drug, time';
format = '(%d,''%s'',%f),';
tmp = [num2cell(repmat(args.rec_id, 1, size(args.time,1))); ...
    repmat({args.drug}, 1, size(args.time,1)); ...
    num2cell(args.time')];

% handle optional input args
if ~isempty(args.volume)
    if size(args.volume,1) ~= size(args.time,1)
        error('Vector length not equal.');
    end
    attr = [attr, ', volume'];
    format = '(%d,''%s'',%f,%f),';
    tmp = [tmp; num2cell(args.volume')];
end

if ~isempty(args.type)
    attr = [attr, ', type'];
    format = '(%d,''%s'',%f,%f,''%s''),';
    tmp = [tmp; repmat({args.type}, 1, size(args.time,1))];
end

vals = sprintf(format, tmp{:});
vals(end) = [];

% build insert query
insert_query = sprintf('insert into DrugInjection(%s) values %s;', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
catch me
    error(me.message)
end

if args.verbose
    fprintf('New DrugInjection(s): %d rows\n', size(args.time, 1));
end

end