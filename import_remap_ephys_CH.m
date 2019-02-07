%%import_remap_ephys
%import data from dat (Amplipex) or rhd (Intan) files
%
% updated Dec 2017 John Tukker
% adapted to use files for remapping and histo information rather than
% having the info in the script (note older versions on Alzheimer server
% are still unchanged; should rename current script at some point!)
% changed order of input args!
%

function[allchansreordered]= import_remap_ephys_CH(recsystype, probetype, mousename, recnr,  npulsechans, savematfile, makeplot, plotchnrs)

if exist('recsystype', 'var') && ~isempty(recsystype)
    if ~(strcmp(recsystype,'Amplipex') || strcmp(recsystype,'Intan') ) 
        error('you have entered an amplifier name that is not recognized, pls change to Amplipex or Intan, or remove');
    end;
else
    recsystype='Amplipex';  %default recordings system type is Amplipex (alternative is Intan rhd2000 recording system)
end

if exist('probetype', 'var') && ~isempty(probetype)
    if ~(strcmp(probetype,'4x8LFP') || strcmp(probetype,'poly2')|| strcmp(probetype,'2x8LFP') || strcmp(probetype,'2x16CamNT') ...
        || strcmp(probetype,'poly3') || strcmp(probetype,'CNT64') || strcmp(probetype,  'NNEdge32') || strcmp(probetype, 'poly2optrode')...
        || strcmp(probetype, 'poly3optrode') || strcmp(probetype,'CNT32_Edge2x16') || strcmp(probetype,'CNT32_Parallel2x16')...
        ||strcmp(probetype,'NN32_Edge1x32') || strcmp(probetype,'NN32_ISO3xtet') || strcmp(probetype,'NN32_Poly2')...
        || strcmp(probetype,'NN32_Poly3') || strcmp(probetype, 'NN32_Edge1x32') || strcmp(probetype, 'NN32_Poly3'))
        error('you have entered a probe name that is not recognized, pls change or remove');
    end;
else
    probetype='4x8LFP';  %default probe type: 4 shanks x 8 sites, 100um spacing, 400um intershank dist
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

%% remapping: put channels in order of site locations: first channel is closest to headstage, left, then go row by row from left to right until tip
% for probes with multiple shanks, do first leftmost shank all chans in order of site locations, then next shank, etc
remapdir = '/alzheimer/proberemapping';
cd(remapdir);
if ~strcmp(recsystype,'Intan')
remapfile =sprintf('ProbeRemapping_%s_Amplipex.csv', probetype);
else
 remapfile =sprintf('ProbeRemapping_%s_Edge1x32_Intan.csv', probetype); 
end
fullremapfilename = fullfile(remapdir, remapfile);
fid=fopen(fullremapfilename);
D = textscan(fid, '%d %d %d %d %d', 'headerlines', 6, 'Delimiter', ';');  %read 5 collumns (for each recsite a probesitenr, adaptorchannr, HSchannr, x-coord, y-coord; first 6 lines are headers so not read here
 if strcmp(recsystype,'Intan')
    HSchans=D{1,2}';%second collumn holds HSchan nrs  for Intan files
    
    HSchans(HSchans==0) = []; %patch added to remove 0s in new remapping file, 15.03.2018
    
else
HSchans=D{1,4}';%third collumn holds HSchan nrs for Amplipex files



end
fclose(fid);


% if strcmp(recsystype, 'amplipex')
%     switch probetype
%     case '4x8LFP' %A4x8-5mm-100-400-703-A32 ; for 5C18 site 29 is bad, reported impedance 9.75 %mapping to be confirmed
%             HSchans = [20,28,27,19,26,29,25,30,24,31,23,32,22,21,18,17,16,15,12,11,1,3,2,14,4,13,5,7,6,9,8,10];
%     case '2x16CamNT'
%             HSchans = [20,28,27,19,26,29,25,30,24,31,23,32,22,21,18,17,16,15,12,11,1,3,2,14,4,13,5,7,6,9,8,10]; 
%     case 'poly3' 
%         HSchans = [20,23,10,28,3,8,27,32,9,19,1,6,26,22,7,29,11,5,25,21,13,30,12,4,24,18,14,31,15,2,17,16];
%     case '2x8LFP'        
%         HSchans = [16,15,12,11,1,3,2,14,4,13,5,7,6,9,8,10];
%     case 'CNT64'
%         HSchans = [60,57,52,51,64,63,15,16,13,14,12,11,10,9,8,7,55,58,57,50,56,49,51,52,30,54,53,...
%                         4,1,6,5,2,48,45,46,44,47,43,42,3,41,29,40,37,31,28,27,32,38,39,36,35,34,33,17,...
%                         18,19,20,22,21,24,23,26,25];
%         %nchans = 64; %patch 29.06.17 by CH
%     case 'CNT32_edge'
%         HSchans = [4,13,5,12,15,6,2,11,14,7,3,10,8,9,16,1,20,29,21,28,31,22,18,27,30,23,19,26,24,25,32,17];
%     case '1x32Edge' %verified correct JT 22.12.2017: order is from dorsal to ventral (tip is last chan)
%         nshanks=1;
%         sitespershank=32;
%         fid=fopen('/alzheimer/proberemapping/ProbeRemapping_NNEdge32_Amplipex.csv');
%         D = textscan(fid, '%d %d %d %d %d', 'headerlines', 6, 'Delimiter', ';');  %read 5 collumns (for each recsite a probesitenr, adaptorchannr, HSchannr, x-coord, y-coord; first 6 lines are headers so not read here
%         HSchans=D{1,3}';                                                %third collumn holds HSchan nrs 
%         fclose(fid);
%         %HSchans = [10,8,9,6,7,5,13,4,14,2,3,1,11,12,15,16,17,18,21,22,32,23,31,24,30,25,29,26,19,27,28,20];
%     end
%     
% else
%     switch probetype
%     case '4x8LFP' %A4x8-5mm-100-400-703-A32 ; for 5C18 site 29 is bad, reported impedance 9.75
%         HSchans = [27,17,22,21,20,26,25,30,29,24,18,19,31,23,16,28,8,13,9,2,7,15,1,0,5,11,12,10,4,14,3,6];
%         HSchans = HSchans+1;    %make sure chans are in range 1-32 so can be used as indices
%         nshanks=4;
%         sitespershank = 8;
%     case '2x16CamNT'
%         HSchans = [31,27,22,18,28,23,21,26,29,24,20,25,30,19,32,17,1,16,3,14,9,10,8,2,7,15,11,12,6,13,5,4];
%         nshanks=2;
%         sitespershank=16;
%     case 'poly3' 
%         nshanks=1;
%         sitespershank=32;
%         HSchans = [];
%         HSchans = HSchans+1;
%     case 'poly3optrode'
%         nshanks=1;
%         sitespershank=32;
%         HSchans = [0,26,16,4,30,15,3,21,31,12,17,2,5,27,18,11,22,13,10,20,29,14,25,8,6,28,24,1,23,9,7,19];
%         HSchans = HSchans+1;
%     case 'poly2' 
%          nshanks=1;
%         sitespershank=32;
%         HSchans = [7,23,1,28,6,25,14,20,10,22,11,27,5,17,12,21,4,26,3,30,9,19,8,24,13,29,2,18,15,31,0,16];   
%         HSchans = HSchans+1;    %make sure chans are in range 1-32 so can be used as indices     
%     case 'poly2optrode'
%         nshanks=1;
%         sitespershank=32;
%         HSchans = [7,23,1,28,6,25,14,20,10,22,11,27,5,17,12,21,4,26,3,30,9,19,8,24,13,29,2,18,15,31,0,16];   
%         HSchans = HSchans+1;    %make sure chans are in range 1-32 so can be used as indices
%     case '2x8LFP'  
%         nshanks=12;
%         sitespershank=8;
%         %HSchans = [1,16,3,14,9,10,8,2,7,15,11,12,6,13,5,4];
%         HSchans = [27,17,22,21,20,26,25,30,29,24,18,19,31,23,16,28];
%         HSchans = HSchans+1;    %make sure chans are in range 1-32 so can be used as indices
%     case '1x32Edge'
%         nshanks=1;
%         sitespershank=32;
%         HSchans = [];
%         HSchans = HSchans+1;    %make sure chans are in range 1-32 so can be used as indices    
%     case 'CNT32_edge'
%             HDchans = [4,13,5,12,15,6,2,11,14,7,3,10,8,9,16,1,20,29,21,28,31,22,18,27,30,23,19,26,24,25,32,17];
%             nshanks=2;
%             sitespershank=16;
%     end
%    end

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
% switch mousenr
%     case 3
%         if recnr==1 % 190231.rhd to 200531.rhd; note this expmnt has no adc input ie no pulses!
%             shank1={'cx','cx','alv','alv','so','so','sp','sr'};
%             shank2={'cx','alv','so','so','sp','sr','sr','slm'};
%             shank3={'alv','so','so','sp','sr','sr','slm','slm'};
%             shank4={'alv','alv','so','sp','sr','sr','sr','slm'};        
%             anatlocs=[shank1, shank2, shank3, shank4];
%         end
%     case 4
%     case 5
%         if recnr==1 %start rec in file .._184149.rhd
%             anatlocs={'cx','cx','alv','alv','alv','alv','alv','alv','SO','SO','SO','SO','SO','SO','SO','SP','SP','SP','SR','SR','SR','SR','SR','SR','SR','SR','SR','SR','SLM','SLM','SLM','SLM', 'pulse'}; 
%         end
%     case 6
%         if recnr==1 || recnr==2
%             %locations for all remapped sites, ie in anatomical order (exact
%             %config depends on probe type, eg linear from dorsal to ventral for poly2)
%             anatlocs={'SO','SO','SO','SO','SO','SP','SP','SP','SR','SR','SR','SR','SR','SR','SR','SR','SLM','SLM','SLM','SLM','SM','SM','SM','SM','SM','SM','SM','SM','SM','SG','SG','SG', 'pulse'}; 
%         end
%     case 7
%         if recnr==2
%             anatlocs={'cx','cx','cx','cx','cx','cx','cx','alv','alv','alv','alv','alv','alv','SO','SO','SO','SO','SO','SO','SP','SP','SR','SR','SR','SR','SR','SR','SR','SR','SR','SLM','SLM','pulse'}; 
%         end
%     case 8
%         if recnr==2
%             %note locations only correction for second part of rec2, ie
%             %after 14:54!!
%             anatlocs={'alv','alv','alv','alv','alv','alv','SO','SO','SO','SO','SO','SO','SP','SP','SR','SR','SR','SR','SR','SR','SR','SR','SR','SLM','SLM','SĹM','SLM','SLM','SLM','SLM','SLM','SLM','pulse'}; 
%         end
%     case 9
%         if recnr==3
%             shank1={'so','sp','sr','sr','slm','slm','sr','sr'};
%             shank2={'sr','sr','slm','slm','ca3sr','ca3sr','ca3sp','ca3so'};
%             shank3={'x','x','x','x','x','x','x','x'};%broken shank, ie not in brain
%             shank4={'x','x','x','x','x','x','x','x'};
%             anatlocs=[shank1, shank2, shank3, shank4, {'pulse'}];
%         end
%     case 10
%         if recnr==1
%             shank1={'alv','alv','so','sp','sp','ca3sr','ca3sr','ca3sp'};
%             shank2={'alv','so','sp','sp','sr','sr','ca3sr','ca3sr'};
%             shank3={'x','x','x','x','x','x','x','x'};%broken shank, ie not in brain
%             shank4={'x','x','x','x','x','x','x','x'};
%             anatlocs=[shank1, shank2, shank3, shank4, {'pulse'}];
%         end        
%     case 11
%         if recnr==2
%             shank1={'alv','so','so','sp','sr','ca3sr','ca3sr','ca3sr'};
%             shank2={'alv','alv','so','sp','sr','sr','sr','slm'};
%             shank3={'x','x','x','x','x','x','x','x'};%broken shank, ie not in brain
%             shank4={'x','x','x','x','x','x','x','x'};
%             anatlocs=[shank1, shank2, shank3, shank4, {'pulse'}];
%         end  
%     otherwise
%         anatlocs=[];
% end

%% cd to Data_Work
datapath = ['/alzheimer/Data_Work/' mousename '/recordings'];
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
                pulses = [pulses, board_adc_data(1,:)]; %add more chans from board_adc_data as necessary
            end
        end
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
    %chansindx list that no longer includes missing chans, and has indices 
    %for all other chans that do not exceed the actual nr of recorded chans
    chansindx=HSchans(ismember(HSchans, recordedchans));
    if nmissingchans >0
    for i=1:ndatachans
        indxcorrection = sum(chansindx(i)>missingchans);
        chansindx(i) = chansindx(i)-indxcorrection;
    end
    end
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
    allchans_raw=[datachansreordered; pulses]; 
    if isempty(pulses)
        disp('no tracking pulses detected in file!');
    else
        nchans = nsites + 1;    %count pulse channel 
        if nchans ~= size(allchans_raw,1)
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
alldatastruct(nsites).chandata = {zeros(size(allchans_raw,2),1)};
%struct to be used as follows:
%to access data from channel i: alldatastruct(i).chandata;
%to get site nr on the probe: alldatastruct(i).probesitenr
%to get site anatomical location: alldatastruct(i).anatloc
for i=1:nsites
    alldatastruct(i).chandata = allchans_raw(i,:);         
    alldatastruct(i).probesitenr = HSchans(i);
    if length(anatlocs) > 1
    alldatastruct(i).anatloc = anatlocs(i); 
    else
    alldatastruct(i).anatloc = NaN; % for files with missing anatomy data
    end
end    

%% save struct in mat file
%mousestr = sprintf('A%d', mousenr);
% recmatfilename=[mousename '_rec' num2str(recnr) '_ephys_alldatastruct2.mat'];
% if savematfile                  
%     save(recmatfilename, 'alldatastruct','-v7.3');      %save newly created struct as mat file.
% end

%% save "normal" mat file
recmatfilename2=[mousename '_rec' num2str(recnr) '_ephys_alldata.mat'];
if savematfile                  
    save(recmatfilename2, 'allchans_raw','-v7.3');      %save newly created struct as mat file.
end

%% save downsampled version of data in array
dsdata=[];
for d=1:size(allchans_raw,1)
    dsdata(d,:) = downsample(allchans_raw(d,:),20);
end
dsmatfilename=[mousename '_rec' num2str(recnr) '_downsampled.mat'];
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