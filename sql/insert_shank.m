function shank_id = insert_shank(probe_id, varargin)
%insert_shank Insert a new row into the Shank table.
%
%   Syntax: insert_amplifier(name)
%
%   [IN]
%       probe_id    :   Probe ID foreign key
%       sites       :   Number of sites on the shank
%       verbose     :   (optional) Verbosity flag, default true
%
%   [OUT]
%       shank_id   :   Generated unique shank identifier
%
%   Example: shank_id = insert_shank(1, 'Sites', 20);
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
    if ~any(strcmp('Shank', tables))
        fprintf('No Shank table found.\n')
        return
    end
catch me
    error(me.message);
end

% handle input args
p = inputParser;
p.addRequired('probe_id', ...
    @(pid) isscalar(pid) & logical(mysql(sprintf('select count(1) from Probe where probe_id = %d;', pid))));
p.addParameter('sites', -1, @(x) isnumeric(x) & isscalar(x));
p.addParameter('verbose', true, @islogical);
p.parse(probe_id, varargin{:});
args = p.Results;

% init query elements
attr = 'probe_id';
vals = [num2str(args.probe_id)];

% handle optional arguments
if args.sites ~= -1
    attr = [attr, ', num_sites'];
    vals = [vals, ', ', num2str(args.sites)];
end

% build insert query
insert_query = sprintf('insert into Shank(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    shank_id = mysql(sprintf('select max(shank_id) from Shank where probe_id=%d', args.probe_id));
catch me
    error(me.message)
end

if isempty(shank_id)
    error('Unable to insert new Shank.');
elseif args.verbose
    fprintf('New Shank: %s (ID: %d)\n', vals, shank_id);
end

end