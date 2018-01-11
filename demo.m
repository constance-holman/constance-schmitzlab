%% connection

% insert your name here
name = '';

% connect to database
mysql('open','mysql', name, name);
mysql('use', name);

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
project_id = insert_project('Test');

% insert amplifier
amplifier_id = insert_amplifier('Test');

% insert ProbeType
probe_type_id = insert_probetype('Test');

