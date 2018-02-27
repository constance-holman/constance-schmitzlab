%%importDat
% used to get .dat files from Ampliplex system
function[allchansreordered]= import_remap_ephys(recsystype, probetype, savematfile, mousenr, recnr, makeplot, plotchnrs)

if exist('recsystype', 'var') && ~isempty(recsystype)
    if ~(strcmp(recsystype,'amplipex') || strcmp(recsystype,'intan') ) 
        error('you have entered an amplifier name that is not recognized, pls change to amplipex or intan, or remove');
    end;
else
    recsystype='amplipex';  %default recordings system type is Amplipex (alternative is Intan rhd2000 recording system)
end

if exist('probetype', 'var') && ~isempty(probetype)
    if ~(strcmp(probetype,'4x8LFP') || strcmp(probetype,'poly2')|| strcmp(probetype,'2x8LFP') || strcmp(probetype,'2x16CamNT')  || strcmp(probetype,'poly3')) 
        error('you have entered a probe name that is not recognized, pls change or remove');
    end;
else
    probetype='4x8LFP';  %default probe type: 4 shanks x 8 sites, 100um spacing, 400um intershank dist
end

if ~exist('makeplot', 'var') || isempty(makeplot)
    makeplot=0;
end


if strcmp(recsystype, 'amplipex')
    switch probetype
    case '4x8LFP' %A4x8-5mm-100-400-703-A32 ; for 5C18 site 29 is bad, reported impedance 9.75 %mapping to be confirmed
            HSchans = [20,28,27,19,26,29,25,30,24,31,23,32,22,21,18,17,16,15,12,11,1,3,2,14,4,13,5,7,6,9,8,10];
    case '2x16CamNT'
            HSchans = [20,28,27,19,26,29,25,30,24,31,23,32,22,21,18,17,16,15,12,11,1,3,2,14,4,13,5,7,6,9,8,10]; 
    case 'poly3' 
        HSchans = [20,23,10,28,3,8,27,32,9,19,1,6,26,22,7,29,11,5,25,21,13,30,12,4,24,18,14,31,15,2,17,16];
    case '2x8LFP'        
        HSchans = [16,15,12,11,1,3,2,14,4,13,5,7,6,9,8,10];
    end
else
    switch probetype
    case '4x8LFP' %A4x8-5mm-100-400-703-A32 ; for 5C18 site 29 is bad, reported impedance 9.75
        HSchans = [27,17,22,21,20,26,25,30,29,24,18,19,31,23,16,28,8,13,9,2,7,15,1,0,5,11,12,10,4,14,3,6];
        HSchans = HSchans+1;    %make sure chans are in range 1-32 so can be used as indices
        nshanks=4;
        sitespershank = 8;
    case '2x16CamNT'
        HSchans = [31,27,22,18,28,23,21,26,29,24,20,25,30,19,32,17,1,16,3,14,9,10,8,2,7,15,11,12,6,13,5,4];
        nshanks=2;
        sitespershank=16;
    case 'poly3' 
        nshanks=1;
        sitespershank=32;
        HSchans = [];
    case 'poly2'
        nshanks=1;
        sitespershank=32;
        HSchans = [7,23,1,28,6,25,14,20,10,22,11,27,5,17,12,21,4,26,3,30,9,19,8,24,13,29,2,18,15,31,0,16];   
        HSchans = HSchans+1;    %make sure chans are in range 1-32 so can be used as indices
    case '2x8LFP'  
        nshanks=12;
        sitespershank=8;
        %HSchans = [1,16,3,14,9,10,8,2,7,15,11,12,6,13,5,4];
        HSchans = [27,17,22,21,20,26,25,30,29,24,18,19,31,23,16,28];
        HSchans = HSchans+1;    %make sure chans are in range 1-32 so can be used as indices
    end
end

nsites = length(HSchans);

%% read in data
if strcmp(recsystype, 'intan')
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
    tpulses = [];
    for i=1:nintanfiles
        %read intan data, time in sec, voltage in V
        [amplifier_channels, amplifier_data, aux_input_channels, aux_input_data, board_adc_channels, board_adc_data, frequency_parameters, notes, spike_triggers, supply_voltage_channels, supply_voltage_data, t_amplifier, t_aux_input, t_board_adc , t_supply_voltage] = ...
            read_Intan_RHD2000_file_jt(intanfilesnames{i}, pathname);  
        %[amplifier_data, t_amplifier, aux_input_data, t_aux_input] = read_Intan_RHD2000_file_CH(intanfilesnames{i});
        data = [data, amplifier_data];    %add data, creating one giant matrix
        tdata = [tdata, t_amplifier];
        pulses = [pulses, board_adc_data];
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
    for i=1:ndatachans
        indxcorrection = sum(chansindx(i)>missingchans);
        chansindx(i) = chansindx(i)-indxcorrection;
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
    %% add row of pulses to reordered data channels
    allchans_raw=[datachansreordered; pulses]; 
    if isempty(pulses)
        disp('no tracking pulses detected in file!');
    else
        nsites = nsites + 1;    %count pulse channel 
        if nsites ~= size(allchans_raw,1)
            error('nr of sites is wrong, maybe multiple pulse channels detected?');
        end
        HSchans = [HSchans,nsites]; %add pulsechan nr as last chan for remapping
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
    %for amplipex, assume data matrix always includes pulse channel  
    nsites = nsites+1;
    HSchans = [HSchans,nchans]; %add pulsechan nr as last chan for remapping

    a=memmapfile(filename,'Format','int16');
    allchannels=reshape(a.data, nsites, []);
    allchansreordered = NaN(size(allchannels)); %make new matrix to hold reordered chans
    %for amplipex data, assume there are no missing channels
    for i = 1:nsites 
        chani = allchannels(HSchans(i),:);
        allchansreordered(i,:)=chani;
    end
    ndatapnts = size(a,2);
    tdata = [0:ndatapnts]/20000;
    allchans_raw = allchansreordered;   %rename channels matrix for mat file below
end

%% assign anatomical location to each probe site
switch mousenr
    case 1
    case 3
        if recnr==1 % 190231.rhd to 200531.rhd; note this expmnt has no adc input ie no pulses!
            shank1={'cx','cx','alv','alv','so','so','sp','sr'};
            shank2={'cx','alv','so','so','sp','sr','sr','slm'};
            shank3={'alv','so','so','sp','sr','sr','slm','slm'};
            shank4={'alv','alv','so','sp','sr','sr','sr','slm'};        
            anatlocs=[shank1, shank2, shank3, shank4];
        end
    case 4
    case 5
        if recnr==1 %start rec in file .._184149.rhd
            anatlocs={'cx','cx','alv','alv','alv','alv','alv','alv','SO','SO','SO','SO','SO','SO','SO','SP','SP','SP','SR','SR','SR','SR','SR','SR','SR','SR','SR','SR','SLM','SLM','SLM','SLM', 'pulse'}; 
        end
    case 6
        if recnr==1 || recnr==2
            %locations for all remapped sites, ie in anatomical order (exact
            %config depends on probe type, eg linear from dorsal to ventral for poly2)
            anatlocs={'SO','SO','SO','SO','SO','SP','SP','SP','SR','SR','SR','SR','SR','SR','SR','SR','SLM','SLM','SLM','SLM','SM','SM','SM','SM','SM','SM','SM','SM','SM','SG','SG','SG', 'pulse'}; 
        end
    case 7
        if recnr==2
            anatlocs={'cx','cx','cx','cx','cx','cx','cx','alv','alv','alv','alv','alv','alv','SO','SO','SO','SO','SO','SO','SP','SP','SR','SR','SR','SR','SR','SR','SR','SR','SR','SLM','SLM','pulse'}; 
        end
    case 8
        if recnr==2
            %note locations only correction for second part of rec2, ie
            %after 14:54!!
            anatlocs={'alv','alv','alv','alv','alv','alv','SO','SO','SO','SO','SO','SO','SP','SP','SR','SR','SR','SR','SR','SR','SR','SR','SR','SLM','SLM','SĹM','SLM','SLM','SLM','SLM','SLM','SLM','pulse'}; 
        end
    case 9
        if recnr==3
            shank1={'so','sp','sr','sr','slm','slm','sr','sr'};
            shank2={'sr','sr','slm','slm','ca3sr','ca3sr','ca3sp','ca3so'};
            shank3={'x','x','x','x','x','x','x','x'};%broken shank, ie not in brain
            shank4={'x','x','x','x','x','x','x','x'};
            anatlocs=[shank1, shank2, shank3, shank4, {'pulse'}];
        end
    case 10
        if recnr==1
            shank1={'alv','alv','so','sp','sp','ca3sr','ca3sr','ca3sp'};
            shank2={'alv','so','sp','sp','sr','sr','ca3sr','ca3sr'};
            shank3={'x','x','x','x','x','x','x','x'};%broken shank, ie not in brain
            shank4={'x','x','x','x','x','x','x','x'};
            anatlocs=[shank1, shank2, shank3, shank4, {'pulse'}];
        end        
    case 11
        if recnr==2
            shank1={'alv','so','so','sp','sr','ca3sr','ca3sr','ca3sr'};
            shank2={'alv','alv','so','sp','sr','sr','sr','slm'};
            shank3={'x','x','x','x','x','x','x','x'};%broken shank, ie not in brain
            shank4={'x','x','x','x','x','x','x','x'};
            anatlocs=[shank1, shank2, shank3, shank4, {'pulse'}];
        end                  
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
    %alldatastruct(i).anatloc = anatlocs(i);        
end    

%% save struct in mat file
mousestr = sprintf('A%d', mousenr);
recmatfilename=[mousestr '_rec' num2str(recnr) '_ephys_alldatastruct2.mat'];
if savematfile                  
    save(recmatfilename, 'alldatastruct','-v7.3');      %save newly created struct as mat file.
end

%% make plot if requested
if makeplot
    %get probesitenrs from struct
    %probesitenrs = NaN(nsites,1);
    %anatlocs = NaN(nsites,1);
    %chantext = string(nsites,1);
    chantexts = cell(nsites,1);
    for i=1:nsites
        nrstr = num2str(alldatastruct(i).probesitenr);
        anatstr = alldatastruct(i).anatloc;
        anatstr = anatstr{1};
        chantexts{i} = [nrstr ' ' anatstr];
    end
    
    %say which chnrs to plot (assuming simple numbering 1-nsites where 1 is
    %most dorsal site on first shank, 2 is secondmost dorsal site on 1st shank, etc
    if ~exist('plotchnrs', 'var') || isempty(plotchnrs)
        plotchnrs=[1:nsites];
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
    if isempty(pulses)
%         plotsegment_linear(tdata_ds, rawdata_ds, plotchnrs, probesitenrs);
        plotsegment_linear(tdata_ds, rawdata_ds, plotchnrs, chantexts);
    else
        %plot channels without pulse chan (= last chan = nchans)
        plotchnrs = plotchnrs(plotchnrs~=nsites);
%         plotsegment_linear(tdata_ds, rawdata_ds, plotchnrs, probesitenrs);
        plotsegment_linear(tdata_ds, rawdata_ds, plotchnrs, chantexts);
        %plot pulses on different scale, in black
        plot(tdata_ds,rawdata_ds(nsites,:)+3, '-k');
    end
end