%% compare_rewards_training_v_rec
% extracts reward and speed information for recordings and compares it to
% training sessions
% INPUT: genotype string, 'WT' or 'TG'
function compare_rewards_training_v_rec(genotype)

if strcmp('WT',genotype)
    allmice = {'M22','M26','M28','M29'}; %,'M33'};
    %allmice = {'M28'};
    trainingdir = '/alzheimer/TrainingData/Population Analysis/WT';

else
    allmice = {'M20','M21','M30','M32','M34'};  %skip off target recs for now
    trainingdir = '/alzheimer/TrainingData/Population Analysis/TG';
end


%% load training-based reward and speed data

for m = 1:length(allmice)
    mousename = char(allmice(m));
    
datadir = ['/alzheimer/Data_Work/' mousename '/recordings/'];

cd(trainingdir)

    myfile = dir('*_trainingspecs.mat'); %assumes only 1 rec has been processed
    load(myfile(m).name) %loads alldata
    
% reminder: from pop_training_analysis.m
    
%             trainingspecs(i,1) = length(VRdatafinal)./100; %number of seconds in the recording
%             trainingspecs(i,2) = sum(VRdatafinal(:,4)==1); %total number of rewards from session
%             trainingspecs(i,3) = mean(VRdatafinal(:,5)); % mean speed
%             trainingspecs(i,4) = std(VRdatafinal(:,5)); % std ofspeed

% fill in "before" data with info from last 2 training sessions

n_rewards(1,m) = mean(trainingspecs([end-1:end],2));
rew_sec(1,m) = n_rewards(1,m)/mean(trainingspecs([end-1:end],1)); %time from training files is already in seconds

mean_speed(1,m) = mean(trainingspecs([end-1:end],3));
std_speed(1,m) = mean(trainingspecs([end-1:end],4));
%% load recording data (default rec 1?)
% calculate speed
% calculate rewards per min, etc. etc.
cd(datadir)
allrecs = dir('*_alldata1000Hzplusanat.mat');
load(allrecs.name); % loads alldata
rec_t = length(alldata)./1000; % length of recording in seconds

% fill in "after" columns with reward information

n_rewards(2,m) = sum(alldata(:,4));
rew_sec(2,m) = n_rewards(2,m)/rec_t;

rec_speed = filter_speed(alldata(:,1),alldata(:,2),alldata(:,3));
mean_speed(2,m) = nanmean(rec_speed);
std_speed(2,m) = nanstd(rec_speed);

clear trainingspecs alldata

%% fill in details from each mouse for plotting

end

subplot(1,4,1)
plot(n_rewards,'-o')
title('Total Rewards')
hold on
subplot(1,4,2)
plot(rew_sec, '-o')
title('Rewards per Second')
subplot(1,4,3)
plot(mean_speed, '-o')
title('Mean Speed')
subplot(1,4,4)
plot(std_speed, '-o')
title('St Dev Speed')
