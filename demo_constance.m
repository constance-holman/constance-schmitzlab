%% demo_constance
% quick and dirty script for overview of mysql core commands

mysql('open','mysql','constance','constance')
mysql('use','constance')

addpath('sql/')
run('init.m')
drop_table(db);
create_table(db);

mysql('close')

