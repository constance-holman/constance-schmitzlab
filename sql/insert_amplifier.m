function amplifier_id = insert_amplifier(name)
%insert_amplifier Insert a new row into the Amplifier table.
%
%   Syntax: insert_amplifier(name)
%
%   [IN]
%       name        :   Name of the amplifier
%
%   [OUT]
%       amplifier_id   :   Generated unique amplifier identifier
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
    if ~any(strcmp('Amplifier', tables))
        fprintf('No Amplifier table found.\n')
        return
    end
catch me
    error(me.message);
end

% handle input args
if isempty(name)
    fprintf('Amplifier name can''t be empty.\n');
    return
end
if ~ischar(name)
    fprintf('Amplifier name has to be a string.\n');
    return
end

% init query elements
attr = 'name';
vals = ['''', name, ''''];

% build insert query
insert_query = sprintf('insert into Amplifier(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    amplifier_id = mysql(sprintf('select max(amplifier_id) from Amplifier where name=''%s''', name));
catch me
    disp(me.message)
end

if ~exist('amplifier_id', 'var') || isempty(amplifier_id)
    % return failed state flag
    amplifier_id = -1;
end

end