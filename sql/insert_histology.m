function histology_id = insert_histology(rec_id, dye, staining, varargin)
%insert_histology Insert a new row into the Histology table.
%
%   Syntax: insert_histology(rec_id, dye, staining, ...)
%
%   [IN]
%       rec_id          :   Recording ID foreign key
%       dye             :   Dye used for histology
%       staining        :   Staining used for histology
%       note            :   (optional) Histology notes
%       verbose         :   (optional) Verbosity flag, default true
%
%   [OUT]
%       histology_id    :   Generated unique histology identifier
%
%   Example: histology_id = insert_histology(1, 'Fuchsin', 'COX');
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
    if ~any(strcmp('Histology', tables))
        fprintf('No Histology table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('rec_id', ...
    @(rid) isscalar(rid) & logical(mysql(sprintf('select count(1) from Recording where rec_id = %d;', rid))));
p.addRequired('dye', @ischar);
p.addRequired('staining', @ischar);
p.addParameter('note', '', @ischar);
p.addParameter('verbose', true, @islogical);
p.parse(rec_id, dye, staining, varargin{:});
args = p.Results;

% init query elements
attr = 'rec_id, dye, staining';
vals = [num2str(args.rec_id), ', ''', args.dye, ''', ''', args.staining, ''''];

% handle optional input args
if ~isempty(args.note)
    attr = [attr, ', note'];
    vals = [vals, ', ''', args.note, ''''];
end

% build insert query
insert_query = sprintf('insert into Histology(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    histology_id = mysql('select max(histology_id) from Histology');
catch me
    error(me.message)
end

if isempty(histology_id)
    error('Unable to insert new Histology.');
elseif args.verbose
    fprintf('New Histology: %s (ID: %d)\n', vals, histology_id);
end
end