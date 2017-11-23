function sql_create(DB)

try
    c = evalc('d = mysql(''show databases'')');
catch me
    if isempty(d)
        fprintf('No databases found.\n');
        return;
    else
        fprintf('Unable to connect.\n');
        return;
    end
end

if isstruct(DB)
    tables = fieldnames(DB);
    for t = tables'
        c = evalc('mysql(DB.(char(t)))');
        fprintf('Created ''%s'' table.\n', char(t));
    end
else
    c = evalc('mysql(DB)');
    fprintf('Created table.\n')
end

end