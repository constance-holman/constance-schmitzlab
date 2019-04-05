%%import_remap_ephys
%import data from dat (Amplipex) or rhd (Intan) files
%
% updated Dec 2017 John Tukker
% adapted to use files for remapping and histo information rather than
% having the info in the script (note older versions on Alzheimer server
% are still unchanged; should rename current script at some point!)
% changed order of input args!
%

function[allchansreordered]= import_remap_qtrode(recsystype, probetype, mousename, recnr,  npulsechans, savematfile, makeplot, plotchnrs,comment)

if exist('recsystype', 'var') && ~isempty(recsystype)
    if ~(strcmp(recsystype,'Amplipex') || strcmp(recsystype,'Intan') ) 
        error('you have entered an amplifier name that is not recognized, pls change to Amplipex or Intan, or remove');
    end;
else
    recsystype='Amplipex';  %default recordings system type is Amplipex (alternative is Intan rhd2000 recording system)
end

if exist('probetype', 'var') && ~isempty(probetype)
    if ~(strcmp(probetype,'Q4_tetrode') || strcmp(probetype,'Q4_linear'))
        error('you have entered a probe name that is not recognized, pls change or remove');
    end;
end

if ~exist('npulsechans', 'var') || isempty(npulsechans)
    npulsechans=1;  %default assume one pulsechan
end

if ~exist('savematfile', 'var') || isempty(savematfile)
    savematfile = 1;
end

if ~exist('makeplot', 'var') || isempty(makeplot)
    makeplot=0;
end

if ~exist('comment', 'var') || isempty(makeplot)
    comment='';
end

%% remapping: put channels in order of site locations: first channel is closest to headstage, left, then go row by row from left to right until tip
% % for probes with multiple shanks, do first leftmost shank all chans in order of site locations, then next shank, etc
% remapdir = '/alzheimer/proberemapping';
% cd(remapdir);
% remapfile =sprintf('ProbeRemapping_%s_Amplipex.csv', probetype);
% fullremapfilename = fullfile(remapdir, remapfile);
% fid=fopen(fullremapfilename);
% D = textscan(fid, '%d %d %d %d %d', 'headerlines', 6, 'Delimiter', ';');  %read 5 collumns (for each recsite a probesitenr, adaptorchannr, HSchannr, x-coord, y-coord; first 6 lines are headers so not read here
% if strcmp(recsystype,'Intan')
%     HSchans=D{1,2}';%second collumn holds HSchan nrs  for Intan files
%     
%     HSchans(HSchans==0) = []; %patch added to remove 0s in new remapping file, 15.03.2018
%     
% else
% HSchans=D{1,3}';%third collumn holds HSchan nrs for Amplipex files
% 
% 
% 
% end
% fclose(fid);

HSchans=[15:18]; %for intan recs

nsites = length(HSchans);

%% assign anatomical location to each probe site (note this makes use of fact that sires are remapped to an anatomical order)
anatdir = '/alzheimer/AD_Histo';
cd(anatdir)
anatlocsfilename=sprintf('%s_rec%d_recsiteanatlocs.csv', mousename, recnr);

fid=fopen(anatlocsfilename);
if fid<1%if fopen failed
    disp('could not open anatlocs file; proceeding without anatomical locations for rec sites!');
    anatlocs=[];
else
    D = textscan(fid, '%d%d%s', 'headerlines', 4);  %read 3 collumns, first 4 lines are headers so not read here
    anatlocs=D{1,3}';                                                %third collumn holds anatlocs (cell array)
    disp(anatlocs);
    fclose(fid);
end

%% cd to Data_Work
%datapath = ['/alzheimer/Data_Work/' mousename '/recordings'];
datapath = ['/home/constance/Motion Tracking Calib'];
cd(datapath)
%% read in data
if strcmp(recsystype, 'Intan')
    %intanfilesnames = uigetfile('MultiSelect','on');
    [intanfilesnames, pathname] = uigetfile('*.rhd', 'Select RHD2000 Data Files to import', 'MultiSelect', 'on');
    if isequal(intanfilesnames, 0)
        error('User selected Cancel');
    end
    intanfilesnames = cellstr(intanfilesnames);  % Care for the correct type 
    
    nintanfiles = length(intanfilesnames);
    data = [];
    tdata=[];
    pulses = [];
    TTLpulses = [];
    for i=1:nintanfiles
        intanfilesnames(i)
        %read intan data, time in sec, voltage in V
        [amplifier_channels, amplifier_data, board_dig_in_data, board_dig_in_channels, board_adc_channels, board_adc_data, frequency_parameters, notes, spike_triggers, supply_voltage_channels, supply_voltage_data, t_amplifier, t_aux_input, t_board_adc , t_supply_voltage] = ...
            read_Intan_RHD2000_file_jt(intanfilesnames{i}, pathname);  
        %[amplifier_data, t_amplifier, aux_input_data, t_aux_input] = read_Intan_RHD2000_file_CH(intanfilesnames{i});
        data = [data, amplifier_data];    %add data, creating one giant matrix
        tdata = [tdata, t_amplifier];
        
        if npulsechans>0
            % for some recordings, done with polyoptrodes, dig_in was used to
            % detect lightpulses (rather than adc, which is used for VR synchronization pulses)
            if strcmp(probetype,'poly2optrode') || strcmp(probetype,'poly3optrode')
                pulses = [pulses, board_dig_in_channels];
            else
                pulses = [pulses, board_adc_data];
            end
        end
    end

    %% Exclude blank channels
    if size(data,1)>length(HSchans)
        data = data([15:18],:);
    end
    
    %% find missing channels and rearrange data accordingly
    ndatachans = size(data,1);
    ndatapnts = size(data,2);
    recordedchans = NaN(ndatachans,1);
    for i=1:ndatachans
        recordedchans(i)=amplifier_channels(i).native_order; 
    end
    recordedchans=recordedchans+1; %reset to start with 1 instead of 0
    missingchans=HSchans(~ismember(HSchans, recordedchans));
    nmissingchans=length(missingchans);
%     %chansindx list that no longer includes missing chans, and has indices 
%     %for all other chans that do not exceed the actual nr of recorded chans
%     chansindx=HSchans(ismember(HSchans, recordedchans));
chansindx=[1:4];
%     for i=1:ndatachans
%         indxcorrection = sum(chansindx(i)>missingchans);
%         chansindx(i) = chansindx(i)-indxcorrection;
%     end
%     for i=1:nsites
%         if any(missingchans==i)
%             for i2 = 1: ndatachans
%                 if chansindx(i2) > i
%                     chansindx(i2) = chansindx(i2) - 1;
%                 end
%             end
%         end
%     end
    
        %chansindx(find(missingchans(i)<chansindx));
%         chansindx_toupdate = chansindx_toupdate-1;
%         for iupdate=1:length
%         chansindx_unchanged = chansindx(find(missingchans(i)>chansindx));
%         chansindx = [chansindx_unchanged, chansindx_toupdate];
    
    datachansreordered = NaN(size(data)); %make new matrix to hold reordered chans
    missingcnt=0;
    
    for i=1:nsites 
        if any(HSchans(i)==missingchans)
            chani = NaN(1,ndatapnts);
            missingcnt=missingcnt+1;
        else
            chani = data(chansindx(i-missingcnt),:); %get data from the recorded chans
        end
        datachansreordered(i,:)=chani;
    end
        
    % add row of pulses to reordered data channels
    allchans_reordered=[datachansreordered; pulses]; 
    if isempty(pulses)
        disp('no tracking pulses detected in file!');
        nchans=nsites;
    else
        nchans = nsites + 1;    %count pulse channel 
        if nchans ~= size(allchans_reordered,1)
            error('nr of chans is wrong, maybe multiple pulse channels detected?');
        end
        HSchans = [HSchans,nchans]; %add pulsechan nr as last chan for remapping
        anatlocs=[anatlocs, {'pulse'}];%add pulse label to anatlocs to distinguish pulse chan from normal  recsites
    end
    
        %% plot segment for testing histo-ephys alignment
%     tsegstart = 216.8;
%     tsegend = 217.1;
%     if tsegstart>=min(tdata_ds) && tsegend<=max(tdata_ds)
%         error('cannot display requested segment, out of range!');
%     else
%         tseg = tdata_ds(tdata_ds>tsegstart & tdata_ds<tsegend);
%         for i= 1:nchans
%             dataseg = datachansreordered_ds(i,:);
%             dataseg = dataseg(tdata_ds>tsegstart & tdata_ds<tsegend);
%             datachansreordered_ds_seg(i,:) = dataseg;
%         end
%         plotsegment_probelayout(tseg, datachansreordered_ds_seg, nshanks, sitespershank)
%     end
else
    %for amplipex, load single .dat file which includes all recorded chans
    %including pulse channel
    [datfilename, pathname] = uigetfile('*.dat', 'Select .dat file to import', 'MultiSelect', 'off');
    if isequal(datfilename, 0)
        error('User selected Cancel');
    end
    
    if npulsechans>0
        %assume dat file always includes pulse chans
        nchans = nsites+1;  %nr of chans is nr of sites plus extra channel for pulse chan
        HSchans = [HSchans,nchans]; %add pulsechan nr as last chan for remapping
        anatlocs=[anatlocs, {'pulse'}];%add pulse label to anatlocs to distinguish pulse chan from normal  recsites
    else 
        pulses=[];
        nchans=nsites;
    end
    
    a=memmapfile(datfilename,'Format','int16');
    allchannels=reshape(a.data, nchans, []);
    clear('a'); %clear variable from memory, no longer needed
    allchansreordered = NaN(size(allchannels)); %make new matrix to hold reordered chans
    %for amplipex data, assume there are no missing channels
    for i = 1:nchans
        chani = allchannels(HSchans(i),:);
        allchansreordered(i,:)=chani;
    end
    ndatapnts = size(allchannels,2);
    tdata = [0:ndatapnts-1]/20000;%data times in seconds
    allchans_raw = allchansreordered;   %rename channels matrix for mat file below
end




%% create data structure to store all info
% pre-allocate struct
alldatastruct(nsites).chandata = {zeros(size(allchans_reordered,2),1)};
%struct to be used as follows:
%to access data from channel i: alldatastruct(i).chandata;
%to get site nr on the probe: alldatastruct(i).probesitenr
%to get site anatomical location: alldatastruct(i).anatloc
for i=1:nchans
    alldatastruct(i).chandata = allchans_reordered(i,:);         
    alldatastruct(i).probesitenr = HSchans(i);
    if length(anatlocs) > 1
    alldatastruct(i).anatloc = anatlocs(i); 
    else
    alldatastruct(i).anatloc = NaN; % for files with missing anatomy data
    end
end    

%% save struct in mat file
%mousestr = sprintf('A%d', mousenr);
recmatfilename=[mousename '_rec' num2str(recnr) '_ephys_alldatastruct2_' comment '.mat'];
% if savematfile                  
%     save(recmatfilename, 'alldatastruct','-v7.3');      %save newly created struct as mat file.
% end

recmatfilename2=[mousename '_rec' num2str(recnr) '_ephys_alldata_' comment '.mat'];
if savematfile                  
    save(recmatfilename2, 'allchans_reordered','-v7.3');      %save newly created struct as mat file.
end
%% save downsampled version of data in array
dsdata=[];
for d=1:size(data,1)
    dsdata(d,:) = downsample(datachansreordered(d,:),20);
end
dsmatfilename=[mousename '_rec' num2str(recnr) '_downsampled_' comment '.mat'];
if savematfile                  
    save(dsmatfilename, 'dsdata','-v7.3');      %save newly created struct as mat file.
end
%% make plot if requested
if makeplot
    %get probesitenrs from struct
    %probesitenrs = NaN(nsites,1);
    %anatlocs = NaN(nsites,1);
    %chantext = string(nsites,1);
    chantexts = cell(nsites,1);
    for i=1:nchans
        nrstr = num2str(alldatastruct(i).probesitenr);
        anatstr = alldatastruct(i).anatloc;
        anatstr = anatstr{1};
        chantexts{i} = [nrstr ' ' anatstr];
    end
    
    %say which chnrs to plot (assuming simple numbering 1-nsites where 1 is
    %most dorsal site on first shank, 2 is secondmost dorsal site on 1st shank, etc
    if ~exist('plotchnrs', 'var') || isempty(plotchnrs)
        plotchnrs=[1:nchans];
    else
         if npulsechans==1  %if there is a pulse chan
             if ~any(plotchnrs==nchans)     %if last chan of the rec (assume this is pulse chan) is not selected by user
                plotchnrs=[plotchnrs,nchans];   %always add pulse chan to user-requested chans
             end
         end
    end
    %take only the correct probesitenrs
    chantexts = chantexts(plotchnrs);
    
    %plot all chans (in mV)
    tdata_ds = downsample(tdata,20);
%     rawdata_ds = downsample(allchans_raw',20);
    rawdata = reshape([alldatastruct.chandata], [length(tdata), size(alldatastruct,2) ]);
    rawdata_ds = downsample(rawdata, 20);
    rawdata_ds = rawdata_ds';

    % plot (subset of channels from) file   
    if npulsechans==1
        %call function to plot data with channels arranged in linear manner
        %last argument is plotlastchanaspulses, set to 1 if pulses are
        %included in rec
        plotsegment_linear(tdata_ds, rawdata_ds, plotchnrs, chantexts,1);
    else
        plotsegment_linear(tdata_ds, rawdata_ds, plotchnrs, chantexts, 0);
    end
end