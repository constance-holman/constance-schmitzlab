function probe_id = insert_probe(probe_type_id, serial, varargin)
%insert_probe Insert a new row into the Probe table.
%
%   Syntax: insert_probe(name)
%
%   [IN]
%       probe_type_id   :   ProbeType foreign key
%       serial          :   Probe serial number
%       verbose         :   (optional) Verbosity flag, default true
%
%   [OUT]
%       probe_id    :   Generated unique probe identifier
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
    if ~any(strcmp('Probe', tables))
        fprintf('No Probe table found.\n')
        return
    end
catch me
    error(me.message);
end

% handle input args
p = inputParser;
p.addRequired('probe_type_id', @(ptid) logical(mysql(sprintf('select count(1) from ProbeType where probe_type_id = %d;', ptid))));
p.addRequired('serial', @ischar);
p.addParameter('verbose', true, @islogical);
p.parse(probe_type_id, serial, varargin{:});
args = p.Results;

% init query elements
attr = 'probe_type_id, serialnum';
vals = [num2str(args.probe_type_id), ', ''', args.serial, ''''];

% build insert query
insert_query = sprintf('insert into Probe(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    probe_id = mysql(sprintf('select max(probe_id) from Probe where serialnum=''%s''', args.serial));
catch me
    error(me.message)
end

if isempty(probe_id)
    error('Unable to insert new Probe.');
elseif args.verbose
    fprintf('New Probe: %s (ID: %d)\n', vals, probe_id);
end

end