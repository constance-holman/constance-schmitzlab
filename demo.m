% connect to database
mysql('open','mysql','viktor','viktor');
mysql('use','viktor');

% add sql folder to path
addpath('sql/');

% init create queries
run('init.m');

% show tables
mysql('show tables');

% drop tables in database
drop_table(db);

% create tables
create_table(db);