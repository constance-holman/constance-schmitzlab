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

%% insert toy data

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

%% insert real metadata

% insert amplifiers
amp.Amplipex = insert_amplifier('Amplipex');
amp.Intan = insert_amplifier('Intan');

% insert probe types
probe.NN32_4x8 = insert_probetype('NN32_4x8LFP');
probe.NN32_2x8 = insert_probetype('NN32_2x8LFP');
probe.CNT32_edge = insert_probetype('CNT32_Edge2x16');
probe.CNT32_parallel = insert_probetype('CNT32_Parallel2x16');
probe.NN32_poly2 = insert_probetype('NN32_poly2');
probe.NN32_poly3 = insert_probetype('NN32_poly3');
probe.NN32_edge = insert_probetype('NN32_Edge1x32');
probe.NN32_poly2opto = insert_probetype('NN32_poly2optrode');
probe.NN32_poly3opto = insert_probetype('NN32_poly3optrode');
probe.NN32_ISO3 = insert_probetype('NN32_ISO3xtet');

% import and insert remappings
[shank,probechan,connectorchan,headstagechan,x,y] = import_remapping('ProbeRemapping_CNT32_Edge2x16_Amplipex.csv');
insert_remapping(probe.CNT32_edge, amp.Amplipex, ...
    'Probe', probechan, 'Headstage', headstagechan, 'Connector', connectorchan);

[shank,probechan,connectorchan,headstagechan,x,y] = import_remapping('ProbeRemapping_CNT32_Parallel2x16_Amplipex.csv');
insert_remapping(probe.CNT32_parallel, amp.Amplipex, ...
    'Probe', probechan, 'Headstage', headstagechan, 'Connector', connectorchan);

[shank,probechan,connectorchan,headstagechan,x,y] = import_remapping('ProbeRemapping_NN32_Edge1x32_Amplipex.csv');
insert_remapping(probe.NN32_edge, amp.Amplipex, ...
    'Probe', probechan, 'Headstage', headstagechan, 'Connector', connectorchan);

[shank,probechan,connectorchan,headstagechan,x,y] = import_remapping('ProbeRemapping_NN32_ISO3xtet_Intan.csv');
insert_remapping(probe.NN32_ISO3, amp.Intan, ...
    'Probe', probechan, 'Headstage', headstagechan, 'Connector', connectorchan);

[shank,probechan,connectorchan,headstagechan,x,y] = import_remapping('ProbeRemapping_NN32_Poly2_Amplipex.csv');
insert_remapping(probe.NN32_poly2, amp.Amplipex, ...
    'Probe', probechan, 'Headstage', headstagechan, 'Connector', connectorchan);

[shank,probechan,connectorchan,headstagechan,x,y] = import_remapping('ProbeRemapping_NN32_Poly3_Amplipex.csv');
insert_remapping(probe.NN32_poly3, amp.Amplipex, ...
    'Probe', probechan, 'Headstage', headstagechan, 'Connector', connectorchan);
%%

% insert probe
probe_id = insert_probe(probe.NN4x8, 'ABCDEFGHIJKLMNOPQRST');

% insert shank
shank_id = insert_shank(probe_id, 'Sites', 20);

% insert site positions
insert_sitepos(shank_id, [1,1;2,1;3,1], [1;2;3]);



%% insert recording
rec_id = insert_recording(session_id, probe_id, amp.Amplipex, 100, ...
    'Note', 'Not deep enough...');

% insert histology
histology_id = insert_histology(rec_id, 'Fuchsia', 'COX');

% insert anatomy
insert_anatomy(histology_id, {'vhc'; 'fi'}, [1; 2])

% insert drug injection
insert_druginjection(rec_id, 'Lidocain', [1;100;1000]);

% insert electro stimulation
insert_electrostim(rec_id, [100;200;300], [0.5;0.3;0.5]);

% insert optogenetic stimulation
insert_optostim(rec_id, [100;200;300], [650;650;650]);

% insert ephys data
insert_lfp(rec_id, [1;1;1], [100;200;300], [0.3;0.4;0.5]);
insert_juxta(rec_id, 'rec', [100;200;300], [0.3;0.4;0.5]);
insert_patch(rec_id, 'rec', [100;200;300], [0.3;0.4;0.5])

