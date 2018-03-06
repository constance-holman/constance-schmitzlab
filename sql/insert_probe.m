function probe_id = insert_probe(probe_type_id, serial)
%insert_probe Insert a new row into the Probe table.
%
%   Syntax: insert_probe(name)
%
%   [IN]
%       probetype_id   :   ProbeType foreign key
%       serial          :   Probe serial number
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
if isempty(probe_type_id)
    fprintf('ProbeType ID can''t be empty.\n');
    return
end

if ~logical(mysql(sprintf('select count(1) from ProbeType where probe_type_id = ''%s'';', probe_type_id)))
    fprintf('Unable to find matching ProbeType ID.\n');
    return
end

if isempty(serial)
    fprintf('Serial number can''t be empty.\n');
    return
end

if ~ischar(serial)
    fprintf('Serial number has to be a string.\n');
    return
end

% init query elements
attr = 'probe_type_id, serialnum';
vals = ['''', probe_type_id, ''', ''', serial, ''''];

% build insert query
insert_query = sprintf('insert into Probe(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    probe_id = mysql(sprintf('select max(probe_id) from Probe where serialnum=''%s''', serial));
catch me
    disp(me.message)
end

if ~exist('probe_id', 'var') || isempty(probe_id)
    % return failed state flag
    probe_id = -1;
end

end