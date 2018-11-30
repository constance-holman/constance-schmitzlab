%% batch_multitaper
% Input = Mx_recx_alldata1000Hzplusanat.mat
% Output = Matrix of all chans at all timepoints after Chronux multitaper
channelmatrix = alldata(:,[5:36]);
multitaper_final = [];
nchans = length(channelmatrix);

%%
params.Fs = 1000;
params.tapers = [3 5];
params.fpass = [1 200];
movingwin = [0.8 0.01];

[Power, Times, Freqs] = mtspecgramc(channelmatrix, movingwin, params );
%maxDb = ceil(max(max(10*log10(Power'))));
%imagesc(Times, Freqs, 10*log10(Power'), [0 maxDb])
imagesc(Times, Freqs,10*log10(Power([1:30],:,1)'))
axis xy

%%
save('M17 Multitaper Power [3 5] [0.8 0.01]', 'Power','-v7.3')
save('M17 Multitaper Times [3 5] [0.8 0.01]', 'Times','-v7.3')
save('M17 Multitaper Freqs [3 5] [0.8 0.01]', 'Freqs','-v7.3')
