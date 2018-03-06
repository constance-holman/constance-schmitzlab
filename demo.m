%% connection

% insert your name here
name = '';

% connect to database
mysql('open','mysql', name, name);
mysql('use', name);

%% setup

% add sql folder to path
addpath('sql/');

% add parsing folder to path
addpath('parsing/');

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

% insert stereotactic injection
insert_stereotactic(animal_id, ...
    'Date', '13.12.2018', ...
    'Virus', 'Test Virus', ...
    'Position', [100, 50]);

% insert session
session_id = insert_session(animal_id, experiment_id, '04.11.1950', ...
    'Type', 'both');

% insert amplifier
amplifier_id = insert_amplifier('Test Amp');

% insert ProbeType
probe_type_id = insert_probetype('Test Probe type');

% insert Probe
probe_id = insert_probe('Test Probe', 'ABCDEFGHIJKLMNOPQRST');

% insert recording
rec_id = insert_recording(session_id, probe_id, amplifier_id, 100, ...
    'Note', 'Not deep enough...');

