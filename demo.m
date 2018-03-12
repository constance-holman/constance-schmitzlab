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

% insert behavior
insert_behavior(session_id, [1,2;1,3;2,6], [10,20;10,30;20,60], [1;2;3], ...
    'End', [false;false;true]);

% insert reward type
reward_type_id = insert_rewardtype('Sugar', 'positive');

% insert reward
insert_reward(session_id, reward_type_id, [1;100;1000]);

% insert amplifier
amplifier_id = insert_amplifier('Test Amp');

% insert probe type
probe_type_id = insert_probetype('Test Probe type');

% insert probe
probe_id = insert_probe(probe_type_id, 'ABCDEFGHIJKLMNOPQRST');

% insert shank
shank_id = insert_shank(probe_id, 'Sites', 20);

% insert site positions
insert_sitepos(shank_id, [1,1;2,1;3,1], [1;2;3]);

% insert remapping
insert_remapping(probe_type_id, amplifier_id, ...
    'Probe', [1;2;3], 'Headstage', [4;7;9]);

% insert recording
rec_id = insert_recording(session_id, probe_id, amplifier_id, 100, ...
    'Note', 'Not deep enough...');


