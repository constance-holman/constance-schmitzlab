function rec_id = insert_recording(session_id, probe_id, amplifier_id, depth, varargin)
%insert_recording Insert a new row into the Recording table.
%
%   Syntax: insert_recording(session_id, probe_id, amplifier_id, depth, ...)
%
%   [IN]
%       session_id          :   Session ID foreign key
%       probe_id            :   Probe ID foreign key
%       amplifier_id        :   Amplifier ID foreign key
%       depth               :   Depth (in micrometers, from the surface)
%       note                :   (optional) Recording notes
%       verbose             :   (optional) Verbosity flag, default true
%
%   [OUT]
%       rec_id          :   Generated unique session identifier
%
%   Example: session_id = insert_session(1, 3, 'Date', '13.12.2018', 'Type', 'rec');
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
    if ~any(strcmp('Recording', tables))
        fprintf('No Recording table found.\n')
        return
    end
catch me
    error(me.message);
end

% parse input args
p = inputParser;
p.addRequired('session_id', ...
    @(sid) logical(mysql(sprintf('select count(1) from Session where session_id = %d;', sid))));
p.addRequired('probe_id', ...
    @(pid) logical(mysql(sprintf('select count(1) from Probe where probe_id = %d;', pid))));
p.addRequired('amplifier_id', ...
    @(aid) logical(mysql(sprintf('select count(1) from Amplifier where amplifier_id = %d;', aid))));
p.addRequired('depth', @isnumeric);
p.addParameter('note', '', @ischar);
p.addParameter('verbose', true, @islogical);
p.parse(session_id, probe_id, amplifier_id, depth, varargin{:});
args = p.Results;

% init query elements
attr = 'session_id, probe_id, amplifier_id, depth';
vals = [num2str(args.session_id), ', ', num2str(args.probe_id), ', ', num2str(args.amplifier_id), ', ', num2str(args.depth)];

% handle optional input args

if ~isempty(args.note)
    attr = [attr, ', note'];
    vals = [vals, ', ''', args.note, ''''];
end

% build insert query
insert_query = sprintf('insert into Recording(%s) values (%s);', attr, vals);

% try to insert into database
try
    r = evalc('mysql(insert_query)');
    rec_id = mysql('select max(rec_id) from Recording');
catch me
    error(me.message)
end

if isempty(rec_id)
    error('Unable to insert new Recording.');
elseif args.verbose
    fprintf('New Recording: %s (ID: %d)\n', vals, rec_id);
end

end