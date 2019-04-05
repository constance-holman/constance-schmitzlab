%% test_ephys_bonsai
pulses = allchans_reordered(5,:);

pulse_on = pulses < 0.5;
pulse_switch = find(diff(pulse_on) ~= 0);

switch_on = pulse_switch(1:2:end);
switch_off = pulse_switch(2:2:end);
%%
filename ='constant_strobe.csv';
fid = fopen(filename);
C = textscan(fid, repmat('%s',1,7), 'delimiter',' ', 'CollectOutput',true);
C=C{1};
%C(:,1) = ROI1; C(:,2) = ROI2; C(:,3) = ROI3; C(:,4) = ROI4;
bonsai_pulses = str2double(C(:,5));
timestamp = C(:,6);

