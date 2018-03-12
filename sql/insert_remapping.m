function insert_remapping(probe_type_id, amplifier_id, varargin)
%insert_remapping Insert a new row into the Remapping table.
%
%   Syntax: insert_remapping(probe_type_id, amplifier_id, ...)
%
%   [IN]
%       probe_type_id       :   ProbeType ID foreign key
%       amplifier_id        :   Amplifier ID foreign key
%       probe               :   (optional) Vector (nx1) of probe channels
%       connector           :   (optional) Vector (nx1) of connector channels
%       headstage           :   (optional) Vector (nx1) of headstage channels
%       verbose             :   (optional) Verbosity flag, default true
%
%   Example: insert_remapping(1, 1, 'Probe', [1;2;3], 'Connector', [4;7;9]);
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
    if ~any(strcmp('Remapping', tables))
        fprintf('No Remapping table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('probe_type_id', ...
    @(ptid) isscalar(ptid) & logical(mysql(sprintf('select count(1) from ProbeType where probe_type_id = %d;', ptid))));
p.addRequired('amplifier_id', ...
    @(aid) isscalar(aid) & logical(mysql(sprintf('select count(1) from Amplifier where amplifier_id = %d;', aid))));
p.addParameter('probe', '', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('connector', '', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('headstage', '', @(x) isnumeric(x) & size(x,2) == 1);
p.addParameter('verbose', true, @islogical);
p.parse(probe_type_id, amplifier_id, varargin{:});
args = p.Results;

if isempty(args.probe) && isempty(args.connector) && isempty(args.headstage)
    error('Nothing to remap.')
end

% init query elements
attr = 'probe_type_id, amplifier_id';
n = 0;

% handle optional arguments
if ~isempty(args.probe)
    attr = [attr, ', probe_channel'];
    n = size(args.probe, 1);
    tmp = [repmat(args.probe_type_id, 1, n); ...
        repmat(args.amplifier_id, 1, n); ...
        args.probe'];
    format = '(%d,%d,%d';
end

if ~isempty(args.connector)
    attr = [attr, ', connector_channel'];
    if n ~= 0
        if size(args.connector, 1) ~= n
            error('Size of remapping vectors don''t match.')
        end
        tmp = [tmp; args.connector'];
        format = [format, ',%d'];
    else
        n = size(args.connector, 1);
        tmp = [repmat(args.probe_type_id, 1, n); ...
            repmat(args.amplifier_id, 1, n); ...
            args.connector'];
        format = '(%d,%d,%d';
    end
end

if ~isempty(args.headstage)
    attr = [attr, ', headstage_channel'];
    if n ~= 0
        if size(args.headstage, 1) ~= n
            error('Size of remapping vectors don''t match.')
        end
        tmp = [tmp; args.headstage'];
        format = [format, ',%d'];
    else
        n = size(args.headstage, 1);
        tmp = [repmat(args.probe_type_id, 1, n); ...
            repmat(args.amplifier_id, 1, n); ...
            args.headstage'];
        format = '(%d,%d,%d';
    end
end

format = [format, '),'];
vals = sprintf(format, tmp);
vals(end) = [];

% build insert query
insert_query = sprintf('insert into Remapping(%s) values %s;', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
catch me
    error(me.message)
end

if args.verbose
    fprintf('New Remapping(s): %d rows\n', n);
end

end