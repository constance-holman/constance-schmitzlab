%% berenyi_correlation
% calculates linear correlations across all channels, including
% filteresversion of signal
% based on analysis fr. Berenyi et al., 2013, J Neurophys.

%input = Mx_recx_alldata1000Hzplusanant

Fs = 1000;
mins = 5;
limit = Fs*60*mins; %creates segment of desired length
data = alldata([1:limit],:); %takes all data minus VR data and pulse channel
%a11rec2 = 7:22

figure

subplot(2,3,1)
corr_mat = corr(data);
imagesc(corr_mat)
title('Raw')
colorbar

%%
[b,a]=butter(4,10/(Fs/2),'high');
dataOut1 = filter(b,a,data);



[b2,a2]=butter(4,100/(Fs/2),'high');
dataOut2 = filter(b2,a2,data);

 %%
corr_filter_mat1 = corr(dataOut1);
corr_filter_mat2 = corr(dataOut2);

subplot(2,3,2)
imagesc(corr_filter_mat1)
title('Filtered- 10 Hz')
colorbar
subplot(2,3,3)
imagesc(corr_filter_mat2)
title('Filtered- 100 Hz')
colorbar

%%
chan_mean = nanmean(corr_mat);
std_dev = nanstd(corr_mat);
subplot(2,3,4)
errorbar([1:size(data,2)],chan_mean,std_dev,'o')

chan_mean1 = nanmean(corr_filter_mat1);
std_dev1 = nanstd(corr_filter_mat1);
subplot(2,3,5)
errorbar([1:size(data,2)],chan_mean1,std_dev1,'o')

chan_mean2 = nanmean(corr_filter_mat2);
std_dev2 = nanstd(corr_filter_mat2);
subplot(2,3,6)
errorbar([1:size(data,2)],chan_mean2,std_dev2,'o')

