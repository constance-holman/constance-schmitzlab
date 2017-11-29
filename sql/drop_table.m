function sql_drop(DB)
%drop_table Simple wrapper for mysql drop table routine.
%
%   Syntax: drop_table(DB)
%
%   [IN]
%       DB       :  Struct with table names as fieldnames.
%
% Copyright (C) 2017  Viktor Bahr (viktor [at] bccn-berlin.de)
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
    c = evalc('d = mysql(''show tables'')');
catch me
    if isempty(d)
        fprintf('No tables found.\n');
        return;
    else
        fprintf('Unable to connect.\n');
        return;
    end
end

if isstruct(DB)
    tables = flipud(fieldnames(DB)); % flip in order to not violate fk-constraints
    for t = tables'
        try
            c = evalc('mysql(sprintf(''drop table %s'', char(t)));');
        catch me
            fprintf('Unable to drop ''%s''.\n', char(t));
            continue;
        end
        fprintf('Droppped ''%s'' table.\n', char(t));
    end
else
    try
        c = evalc('mysql(sprintf(''drop table %s'', DB));');
        fprintf('Droppped ''%s'' table.\n', DB);
    catch me
        fprintf('Unable to drop ''%s''.\n', char(t));
    end
end

end
