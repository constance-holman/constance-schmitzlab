%% find_reward_noise
% IN: Mx_recx_alldata10Hzplusanat
% OUT: spectral composition of 5 seconds before and after reward

% extract rewards and pull channel info

% perform Stockell on each snipper

% save all spectra in multidimensional array(?)

function[alldatastruct]= find_reward_noise(genotype)
allbins_final=[];


if strcmp('WT',genotype)
    allmice = {'M22','M26','M29','M33'};
    %allmice = {'M28'};

else
    allmice = {'M27','M30','M32','M34'}; %{'M20','M21','M25',
end



for m = 1:length(allmice)
    mousename = char(allmice(m));
    

datadir =  ['/alzheimer/Data_Work/' mousename '/recordings/'];
    cd(datadir)
    myfile = dir('*_alldata1000Hzplusanat.mat'); %assumes only 1 rec has been processed
    load(myfile.name) %loads alldata

rew_index = find(alldata(:,4) == 1);
nrewards = length(rew_index);
n_samples = 10000; % @1KHz equivalent to 5 secs of data
my_chan = alldata(:,7); %taking semi-random channel from data

%%
if nrewards > 0 % if there are actually rewards
for n = 1:length(rew_index)
        if length(my_chan) - n_samples < rew_index(n) % if the reward happens less then 5 secs before end of recording (unlikely!)
            chan_pre(n,:) = my_chan(rew_index(n) - n_samples: rew_index(n));
            pad_chan = NaN(1, n_samples - (length(my_chan) - rew_index(n))); %calculate how many NaNs are needed to pad end of speed
            temp_chan = horzcat(my_chan(rew_index(n):end)',pad_chan); %concatenate real speed with NaNs
            chan_post(n,:) = temp_chan;
            
        elseif rew_index < n_samples % if the first reward is less than 5 secs from the beginning of the recording
            pad_chan = NaN(1,rew_index(n)); %calculate how many NaNs are needed to pad beginning of speed
            temp_chan = horzcat(pad_chan,rew_index(n):n_samples); %concatenate real speed with NaNs TODO may throw bug for exact number of samples (500 vs. 501)
            chan_pre(n,:) = my_chan(temp_chan);
            chan_post(n,:) = my_chan(rew_index(n):rew_index(n) + n_samples);
            
        else %general case for rewards in the beginning of the rec
            chan_pre(n,:) = my_chan(rew_index(n)-n_samples:rew_index(n));
            chan_post(n,:) = my_chan(rew_index(n):rew_index(n) + n_samples);
        end
end

elseif nrewards == 1 %if there is exactly one reward
            if length(VRdatafinal) - n_samples < rew_index % if the reward happens less then 5 secs before end of recording (unlikely!)
            chan_pre = VRdatafinal(rew_index - n_samples: rew_index);
            pad_chan = NaN(1,length(VRdatafinal) - rew_index); %calculate how many NaNs are needed to pad end of speed
            temp_chan = horzcat(VRdatafinal(rew_index:end),pad_chan); %concatenate real speed with NaNs
            chan_post = VRdatafinal(temp_chan,5);
            
        elseif rew_index < n_samples % if the first reward is less than 5 secs from the beginning of the recording
            pad_chan = NaN(1,rew_index); %calculate how many NaNs are needed to pad beginning of speed
            temp_chan = horzcat(pad_chan,rew_index:n_samples); %concatenate real speed with NaNs TODO may throw bug for exact number of samples (500 vs. 501)
            chan_pre = VRdatafinal(temp_chan,5);
            chan_post = VRdatafinal(rew_index:rew_index + n_samples,5);
            
        else %general case for rewards in the beginning of the rec
            chan_pre = VRdatafinal(rew_index-n_samples:rew_index,5);
            chan_post = VRdatafinal(rew_index:rew_index + n_samples,5);
        end
    

end
%%
all_times = horzcat(chan_pre, chan_post);
all_freqs=[];

for i = 1:size(all_times,1) - 1
    [AllStockwellSpectro AllStockwellTimes StockwellFreqs MeanThetaPower,MeanThetaPowerNorm, MaxFreq, avgd]= Stockwell4_ThetaChan(all_times(i,:));
    if i == 1
        all_freqs = AllStockwellSpectro;
    else
       all_freqs(:,:,i) = AllStockwellSpectro;
    end
end

clear all_times
%% TODO save allfreqss
allfreqs_name = [mousename '_rewardfreqs'];
save(allfreqs_name, 'all_freqs')

%%
freq_mean = mean(all_freqs,3);
imagesc(freq_mean)
axis xy
vline(5000,'g','Reward')
titlestr = [mousename ' Average Spectral Reward Content']
title(titlestr)
savefig(titlestr)


end
