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
project_id = insert_project('Test Project');

% insert experiment
experiment_id = insert_experiment(project_id, ...
    'Experimenter', name, ...
    'Description', 'This is a test experiment.');

% insert animal
animal_id = insert_animal(project_id, ...
    'Name', 'Test Animal', ...
    'Sex', 'm');

% insert session
session_id = insert_session(animal_id, experiment_id, ...
    'Type', 'both');

% insert amplifier
amplifier_id = insert_amplifier('Test Amp');

% insert ProbeType
probe_type_id = insert_probetype('Test Probe type');

% insert Probe
probe_id = insert_probe('Test Probe', 'ABCDEFGHIJKLMNOPQRST');

