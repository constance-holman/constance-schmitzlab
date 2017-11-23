function sql_drop(DB)

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
    c = evalc('mysql(sprintf(''drop table %s'', DB));');
    fprintf('Droppped ''%s'' table.\n', DB);
end

end