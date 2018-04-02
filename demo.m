%% connection

% insert your name here
name = 'viktor';

% connect to database
mysql('open','mysql', name, name);
mysql('use', name);

%% setup

% add sql folder to path
addpath('sql/');
% add remapping folder to path
addpath('proberemapping/');
% add remapping folder to path
addpath('histo/');

% init create queries
run('init.m');

%% create / drop tables

% show tables
mysql('show tables');

% drop tables in database
drop_table(db);

% create tables
create_table(db);

%% insert metadata

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

% insert probe
% probe info from header of histology CSV, parse that too?
probe_id = insert_probe(probe.NN32_edge, '92C9');


%% insert data set

% insert project
project_id = insert_project('Test Project');

% insert experiment
experiment_id = insert_experiment(project_id, ...
    'Experimenter', 'JT', ...
    'Description', 'This is a test experiment.');

% insert animal
animal_id = insert_animal(project_id, ...
    'Name', 'M17', ...
    'Sex', 'm');

% insert session
session_id = insert_session(animal_id, experiment_id, '06.06.2015', ...
    'Type', 'both');

% insert recording
% depth unknown...
rec_id  = insert_recording(session_id, probe_id, amp.Amplipex, 0);

% insert histology
% TODO: What dye / staining? Unable to find any info on this in the CSVs
histology_id = insert_histology(rec_id, 'Unknown', 'Unknown');

% import and insert anatomy
[shank, channel, anatomy] = import_histology('M17_rec1_recsiteanatlocs.csv');
insert_anatomy(histology_id, anatomy, channel);



