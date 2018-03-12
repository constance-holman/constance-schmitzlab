function insert_sitepos(shank_id, pos, num, varargin)
%insert_sitepos Insert a new row into the SitePosition table.
%
%   Syntax: insert_sitepos(shank_id, pos, num, ...)
%
%   [IN]
%       shank_id            :   Shank ID foreign key
%       pos                 :   Vector (nx2) of [X,Y] site position
%       num                 :   Vector (nx1) of site number
%       verbose             :   (optional) Verbosity flag, default true
%
%   Example: insert_sitepos(1, [1,1;2,1;3,1], [1;2;3]);
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
    if ~any(strcmp('SitePosition', tables))
        fprintf('No SitePosition table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('shank_id', ...
    @(sid) isscalar(sid) & logical(mysql(sprintf('select count(1) from Shank where shank_id = %d;', sid))));
p.addRequired('pos', @(x) isnumeric(x) & size(x,2) == 2);
p.addRequired('num', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('verbose', true, @islogical);
p.parse(shank_id, pos, num, varargin{:});
args = p.Results;

if size(args.pos,1) ~= size(args.num,1)
    error('Vector length not equal.');
end

% init query elements
attr = 'shank_id, x_pos, y_pos, site_num';
format = '(%d,%d,%d,%d),';
tmp = [repmat(args.shank_id, 1, size(args.pos, 1)); args.pos'; args.num'];

vals = sprintf(format, tmp);
vals(end) = [];

% build insert query
insert_query = sprintf('insert into SitePosition(%s) values %s;', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
catch me
    error(me.message)
end

if args.verbose
    fprintf('New SitePosition(s): %d rows\n', size(args.pos, 1));
end

end