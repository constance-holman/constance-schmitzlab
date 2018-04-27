%% batch_spectral_analysis
% used for exploratory spectral analysis on consecutive days of freely
% moving recordings
% input = dsdata files
function batch_spectral_analysis(mousename, Fs, maxfreq, showfig)
datapath = ['/alzheimer/Data_Work/' mousename '/recordings'];
analysispath = ['/alzheimer/Data_Work/' mousename '/analysis'];
cd(datapath)
%% set up output files


%intanfilesnames = uigetfile('MultiSelect','on');
[recfilenames, pathname] = uigetfile('*.mat', 'Select recordings to import', 'MultiSelect', 'on');
    if isequal(recfilenames, 0)
        error('User selected Cancel');
    end
    recfilenames = cellstr(recfilenames);  % Care for the correct type bat
    
    nrecfiles = length(recfilenames);

for n = 1:nrecfiles
    curr_file = recfilenames{n};
    
    %extract date from recording file. options are _ddmmyy.mat or
    %_ddmmyy_2.mat
    if strcmp(curr_file(end-10),'_')
        recdate = curr_file(end-9:end-4);
    else
        recdate = curr_file(end-11:end-4);
    end
    
    load(curr_file)
    datatrace = dsdata(1,:);
    t=1:1/Fs:length(dsdata); %timestamps for rec, used in stockwell_singlechan for calculating the Fs
    [StockwellSpectro, StockwellTimes, StockwellFreqs] = stockwell_singlechan(t,datatrace, maxfreq, showfig);
    %save spectro from each rec with correct filename
    cd(analysispath)
    spectrofilename=[mousename '_spectro_' recdate '.mat'];
    save(spectrofilename, 'StockwellSpectro','-v7.3');
    cd(datapath)
end