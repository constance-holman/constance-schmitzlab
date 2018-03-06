function amplifier_id = insert_amplifier(name, varargin)
%insert_amplifier Insert a new row into the Amplifier table.
%
%   Syntax: insert_amplifier(name)
%
%   [IN]
%       name        :   Name of the amplifier
%       verbose     :   (optional) Verbosity flag, default true
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
p = inputParser;
p.addRequired('name', @ischar);
p.addParameter('verbose', true, @islogical);
p.parse(name, varargin{:});
args = p.Results;

% init query elements
attr = 'name';
vals = ['''', args.name, ''''];

% build insert query
insert_query = sprintf('insert into Amplifier(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    amplifier_id = mysql(sprintf('select max(amplifier_id) from Amplifier where name=''%s''', name));
catch me
    error(me.message)
end

if isempty(amplifier_id)
    error('Unable to insert new Amplifier.');
elseif args.verbose
    fprintf('New Amplifier: %s (ID: %d)\n', vals, amplifier_id);
end

end