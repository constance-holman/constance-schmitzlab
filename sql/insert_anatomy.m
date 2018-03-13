function insert_anatomy(histology_id, location, channel, varargin)
%insert_anatomy Insert a new row into the Anatomy table.
%
%   Syntax: insert_anatomy(histology_id, score, location, channel, ...)
%
%   [IN]
%       histology_id        :   Histology ID foreign key
%       location            :   Cell (nx1) anatomical location name
%       channel             :   Vector (nx1) channel numbers (int)
%       score               :   (optional) Vector (nx1) of location certainty (float)
%       verbose             :   (optional) Verbosity flag, default true
%
%   Example: insert_anatomy(1, {'vhc'; 'fi'}, [1; 2]);
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
    if ~any(strcmp('Anatomy', tables))
        fprintf('No Anatomy table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('histology_id', ...
    @(hid) isscalar(hid) & logical(mysql(sprintf('select count(1) from Histology where histology_id = %d;', hid))));
p.addRequired('location', @(x) iscellstr(x) & size(x,2) == 1);
p.addRequired('channel', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('score', [], @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('verbose', true, @islogical);
p.parse(histology_id, location, channel, varargin{:});
args = p.Results;

if size(args.channel, 1) ~= size(args.location, 1)
    error('Vector length not equal.');
end

% init query elements
attr = 'histology_id, location, channel';
format = '(%d,''%s'',%d),';
tmp = [num2cell(repmat(args.histology_id, 1, size(args.location,1))); ...
    args.location'; ...
    num2cell(args.channel')];

if ~isempty(args.score)
    if size(args.score, 1) ~= size(args.channel, 1)
        error('Vector length not equal.');
    end
    attr = [attr, ', score'];
    format = '(%d,''%s'',%d,%f),';
    tmp = [tmp; num2cell(score')];
end

vals = sprintf(format, tmp{:});
vals(end) = [];

% build insert query
insert_query = sprintf('insert into Anatomy(%s) values %s;', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
catch me
    error(me.message)
end

if args.verbose
    fprintf('New Anatomy(s): %d rows\n', size(args.channel, 1));
end

end