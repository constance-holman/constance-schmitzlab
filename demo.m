%% connection

% connect to database
mysql('open','mysql','viktor','viktor');
mysql('use','viktor');

%% setup

% add sql folder to path
addpath('sql/');

% init create queries
run('init.m');

%% create / drop tables

% show tables
mysql('show tables');

% drop tables in database
drop_table(db);

% create tables
create_table(db);

%% insert data

% insert project
project_id = insert_project('Test Project');

% insert experiment
experiment_id = insert_experiment(project_id, 'Viktor', 'This is a test experiment.');

% insert amplifier
amplifier_id = insert_amplifier('Test');

% insert ProbeType
probe_type_id = insert_probetype('Test');

