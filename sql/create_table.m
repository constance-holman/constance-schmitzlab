function sql_create(DB)
%create_table Simple wrapper for mysql create table routine.
%
%   Syntax: create_table(DB)
%
%   [IN]
%       DB       :  Struct with table names as fieldnames and respective
%       sql create table statement.
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

% test sql connection

try
    r = evalc('d = mysql(''select database()'')');
catch me
    if isempty(d{1})
        fprintf('No database selected.\n')
        return
    else
        fprintf('Unable to connect.\n');
        return;
    end
end

if isstruct(DB)
    fields = fieldnames(DB); % get table names
	for i = 1:numel(fields)
	    try
            r = evalc('mysql(DB.(fields{i}))');
            fprintf('Created ''%s''.\n', fields{i});
	    catch me
            fprintf('Unable to create ''%s''.\n', fields{i});
	    end
	end
elseif isstr(DB)
    try
        r = evalc('mysql(DB)');
        fprintf('Created table.\n')
    catch me
        disp(me)
    end
else
    fprintf('Input has to be string or struct.\n')
end

end
