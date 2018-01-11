function [VRdata] = import_VRdata_CH(mousestr, recnr, posfile, pulsefile, showfigs, savefigs, savetrackingmatfiles)
% Reads in VR tracking data and creates mat file.
% Assumes 2 input files produced by VR system:
% 1. a pos file with 5 collumns (t, VR x, VR y, ball x, ball y)
% 2. a pulse file with one line for each pulse sent to ephys system, plus one lines for each reward 
% Saves single tracking matrix in mat file with systematic name
%
% created 14.3.2017 JT, based on v4_simple
% last updated 27.3.2017 JT: 
% make more flexible to also enable working with pos file with 3 collumns (ie without ballx, ball y coords) 
% change input mousenr to mousestr for more flexibility
% assume this function is called from the directory that holds the VR
% tracking data files

%% check user inputs, find files
%users enter mousenr and recnr and specify file names
if (~exist('mousestr', 'var') || isempty(mousestr) ||...
        ~exist('recnr', 'var') || isempty(recnr) )
        error('missing input vars, pls specify mousename as string, recnr as integer');
end   

%users must specify file names, if not as function param then ask for it in
%dialog box
if  ~exist('pulsefile', 'var') || isempty(pulsefile)
    [pf, pathname] = uigetfile({'*.csv';'*.xlsx';'*.mat', }, 'Select Sample File to import pulse and reward data from', 'MultiSelect', 'off');
    if isequal(pf, 0)
        error('User selected Cancel');
    end
    pulsefile = pf;  % Care for the correct type 
end   

%users enter mousenr and recnr and specify file names
if ~exist('posfile', 'var') || isempty(posfile)
    [pf, pathname] = uigetfile({'*.csv';'*.xlsx';'*.mat', }, 'Select Pos File to import POSITION data from', 'MultiSelect', 'off');
    if isequal(pf, 0)
        error('User selected Cancel');
    end
    posfile = pf;  % Care for the correct type 
end  


if ~exist('savefigs', 'var')
    savefigs = 1;
end
if ~exist('showfigs', 'var')
    showfigs = 0;
end

if showfigs || savefigs
    makefigs = 1;
else
    makefigs = 0;
end
%savetrackingmatfile = 1;    %option to save VR tracking data as mat file

currdir = pwd;
figdir = fullfile(currdir, '/trackingfigs');


%go to correct directory for this mouse
%naming may depend on expmt:
% m = APPPS1 mice (WT and Tg) from MEC/LEC project
% a= APPPS1dE9 mice (WT and Tg) from CA1 gamma project (collaboration w AMS Ronald v Kesteren & Sara Hijazi)

%dataworkdir = '/alzheimer/Data_Work/';
%mouserecdir = fullfile(dataworkdir, mousestr, '/recordings');
%cd(mouserecdir);

%figdir = fullfile(dataworkdir, mousestr, '/analysis/trackingfigs');
%cd('/store01_alzheimer/DREADD Tracking Experiments/MS-MEC-DREADD-project') %for DREADD mice


%% get times and coordinates for positions from VR data
format3=posfile(end-2:end);
if strcmp(format3,'csv')    %for csv file with position data
    [VRtimepnts, XVR, YVR, Xball, Yball] = readVRposfile(posfile);

% %     % for special cases, get data for each rec
% %     % chop up the data-arrays using manually determined times for each rec
    if strcmp(mousestr,'M18') || strcmp(mousestr,'M19')
        switch mousestr
        case 'M18'
            switch recnr
            case 1
                recindices = (VRtimepnts>42164.75 & VRtimepnts<42164.8)
            case 2
                recindices = (VRtimepnts>42164.815 & VRtimepnts<42164.84)
            end
        case 'M19'
            switch recnr
            case 1
                recindices = (VRtimepnts>42164.9 & VRtimepnts<42164.94);
            case 2
                recindices = (VRtimepnts>42164.94 & VRtimepnts<42164.98);
            case 3
                recindices = (VRtimepnts>42164.98 & VRtimepnts<42165.04);
            end
        end
        VRtimepnts=VRtimepnts(recindices);
        Xball=Xball(recindices);
        Yball=Yball(recindices);
        XVR=XVR(recindices);
        YVR=YVR(recindices);
     end
elseif strcmp(format3,'lsx')
    temp_pos=xlsread(posfile);
    VRtimepnts = temp_pos(:,1); VRtimepnts = VRtimepnts';
    XVR = temp_pos(:,2); XVR = XVR';
    YVR = temp_pos(:,3); YVR = YVR';

    
elseif strcmp(format3,'mat')    %if already matfile with pos data given by user
    S = load(posfile);%load matfile, this should contain matrix VRposdata w 5 collumns: t, XVR, YVR, Xball, Yball
    VRdata = S.VRposdata;
    VRtimepnts=VRdata(:,1);
    XVR=VRdata(:,2);
    YVR=VRdata(:,3);
    Xball=VRdata(:,4);
   Yball=VRdata(:,5);
end

%% check if pos file contained tracking info on ball 
if sum(isnan(Xball)) > 0
    plotball=0; %use this index to adapt plots and mat output accordingly
else
    plotball=1;
end

%% get pulsetimes and rewards from VR data
format2=pulsefile(end-2:end);
if strcmp(format2,'csv')    %for csv file with pulse data
%     if mousenr<7
%         [VRpulsetimes, VRrewardtimes] = readVRpulsefile(pulsefile);
%     else   
    %pulsefile format changed, so call updated function
    %ie order of collumns in pulsefile is different after expmt with a7
        [VRpulsetimes, VRrewardtimes] = readVRpulsefile2(pulsefile);
%     end
    npulses=length(VRpulsetimes);
elseif strcmp(format2,'lsx')
     [VRpulsetimes, VRrewardtimes] = readVRpulsefile2(pulsefile);
    npulses=length(VRpulsetimes);
    %pulse_temp = xlsread(pulsefile);
end

%check that there is no pulses outside of the VRtimepnts range
if VRpulsetimes(end)>VRtimepnts(end) || VRpulsetimes(1)<VRtimepnts(1)
    error('the first or last pulse lies outside the range of tracked datapnts!');
end

%% make selection of tracking data t, X, Y within pulsetimes 
%take only those tracking times after start of first pulse, and before last pulse 
VRselind = (VRtimepnts>VRpulsetimes(1) & VRtimepnts<VRpulsetimes(end) );
VR_t = VRtimepnts(VRselind);
VR_XVR = XVR(VRselind);
VR_YVR = YVR(VRselind);
if plotball
    VR_Xball = Xball(VRselind);
    VR_Yball = Yball(VRselind);
end
 ntrackpnts = length(VR_t);
%select rewards:
VR_trewards = VRrewardtimes(VRrewardtimes>VRpulsetimes(1) & VRrewardtimes<VRpulsetimes(end));
nrewards = length(VR_trewards);
%check that there are no NaNs in the selected times
%if any(isnan(VR_t)) || any(isnan(VR_XVR)) || any(isnan(VR_Xball)) || any(isnan(VR_YVR)) || any(isnan(VR_Yball)) || any(isnan(VR_trewards))
    if any(isnan(VR_t)) || any(isnan(VR_XVR)) || any(isnan(VR_YVR)) || any(isnan(VR_trewards))
    error('data read in from VR file contains NaN value(s) when read into matlab!')
end

%convert times to relative times in seconds, starting from first pulsetime
VR_trel = NaN(ntrackpnts,1);
for i = 1:ntrackpnts
    VR_trel(i) = etime(datevec(VR_t(i)), datevec(VRpulsetimes(1)));
end
%convert reward times, replace each reward time with nearest tracking timepnt 
VR_trewardsrel = NaN(nrewards,1);   %array to hold nearest VR tracking timepnt for every reward
VR_rewardsind = zeros(ntrackpnts,1);    %array to hold ones (for reward) and zeros (for no reward) for each VR pos timepnt
VR_tpulsesrel = NaN(npulses,1);     %array to hold pulse times in sec from zero 
for i = 1:nrewards
    %compute time of reward relative to start of tracking ie first
    %pulsetime is defined as t=0
    trewrel = etime(datevec(VRrewardtimes(i)), datevec(VRpulsetimes(1)));
    %get differences between rel reward time and all rel VR times
    d = abs(VR_trel - trewrel); 
    [md, mdi] = min(d);         %find smallest difference
    %set VR tracking time with smallest difference as new reward time
    VR_trewardsrel(i) = VR_trel(mdi);    
    VR_rewardsind(mdi) = 1;      %set the value at point mdi to 1
end
for i=1:npulses
    %note first pulse should be at zero
    VR_tpulsesrel(i) = etime(datevec(VRpulsetimes(i)), datevec(VRpulsetimes(1)));
end


if makefigs
    if plotball
        h2=figure('Position', [10, -100, 700, 700]); 
        subplot(2, 1, 1);
        plot(VR_trel, VR_Xball, '.r'); hold on; 
        if nrewards > 0
            plot(VR_trel(logical(VR_rewardsind)), VR_Xball(logical(VR_rewardsind)), 'og');  
        end

        ylabel('Xball (VR units)');
        xlim([0 max(VR_trel)]);
        box off;
        subplot(2, 1, 2);
        plot(VR_trel, VR_Yball, '.b'); hold on; 
        if nrewards > 0
            plot(VR_trel(logical(VR_rewardsind)), VR_Yball(logical(VR_rewardsind)), 'og');  
        end

        xlabel('t (s)');
        ylabel('Yball (VR units)');   
        xlim([0 max(VR_trel)]);
        maxy = max([VR_Xball;VR_Yball]);
        miny = min([VR_Xball;VR_Yball]);
         ylim([miny,maxy]);   
        box off;

        currdate = datestr(date());
        figtitle = sprintf('%s rec%d VRdata ball %s', mousestr, recnr, currdate);
        suptitle(figtitle);

        if savefigs     % save the figure in the right directory
            figname = sprintf('/%s_rec%d_VRdata_XballT_YballT.fig', mousestr, recnr);
            jpgfigname = sprintf('/%s_rec%d_VRdata_XballT_YballT.jpg', mousestr, recnr);
            pngfigname = sprintf('/%s_rec%d_VRdata_XballT_YballT.png', mousestr, recnr);
            epsfigname = sprintf('/%s_rec%d_VRdata_XballT_YballT.eps', mousestr, recnr);

            if ~exist(figdir,'dir')          
                mkdir(figdir);
            end
            saveas(gcf, [figdir figname]);
            hgexport(gcf, [figdir jpgfigname], hgexport('factorystyle'), 'Format', 'jpeg');
            hgexport(gcf, [figdir pngfigname], hgexport('factorystyle'), 'Format', 'png');        
            hgexport(gcf, [figdir epsfigname], hgexport('factorystyle'), 'Format', 'eps');
        end
    end
    
    h3=figure('Position', [710, -100, 700, 700]); 
    subplot(2, 1, 1);
    plot(VR_trel, VR_XVR, '.r'); hold on; 
    if nrewards > 0
        plot(VR_trel(logical(VR_rewardsind)), VR_XVR(logical(VR_rewardsind)), 'og');  
    end

    ylabel('XVR (in VR units)');
    xlim([0 max(VR_trel)]);
    box off;
    subplot(2, 1, 2);
    plot(VR_trel, VR_YVR, '.b'); hold on; 
    if nrewards > 0
        plot(VR_trel(logical(VR_rewardsind)), VR_YVR(logical(VR_rewardsind)), 'og');  
    end

    xlabel('t (s)');
    ylabel('YVR (in VR units)');   
    xlim([0 max(VR_trel)]);
    maxy = max([VR_XVR;VR_YVR]);
    miny = min([VR_XVR;VR_YVR]);
    ylim([miny,maxy]);
    box off;
    
    currdate = datestr(date());
    figtitle = sprintf('%s rec%d VRdata VR %s', mousestr, recnr, currdate);
    suptitle(figtitle);
    
    if savefigs     % save the figure in the right directory
        figname = sprintf('/%s_rec%d_VRdata_XVRT_YVRT.fig', mousestr, recnr);
        jpgfigname = sprintf('/%s_rec%d_VRdata_XVRT_YVRT.jpg', mousestr, recnr);
        pngfigname = sprintf('/%s_rec%d_VRdata_XVRT_YVRT.png', mousestr, recnr);        
        epsfigname = sprintf('/%s_rec%d_VRdata_XVRT_YVRT.eps', mousestr, recnr);
    
        if ~exist(figdir,'dir')          
            mkdir(figdir);
        end
        saveas(gcf, [figdir figname]);
        hgexport(gcf, [figdir pngfigname], hgexport('factorystyle'), 'Format', 'png');
        hgexport(gcf, [figdir jpgfigname], hgexport('factorystyle'), 'Format', 'jpeg');
        hgexport(gcf, [figdir epsfigname], hgexport('factorystyle'), 'Format', 'eps');
    end
    
end

%% put all corrected tracking data into a mat file with 4 or 6 collumns
if plotball
    VRdata = horzcat(VR_trel, VR_XVR, VR_YVR, VR_Xball, VR_Yball, VR_rewardsind);
else
    VRdata = horzcat(VR_trel, VR_XVR, VR_YVR, VR_rewardsind);
end

if savetrackingmatfiles
    file2save=([mousestr '_rec' num2str(recnr) '_VRdataraw.mat']);
    save(file2save, 'VRdata', 'VR_tpulsesrel','-v7.3');   %saves tracking data in same folder with identifying info.
end

if makefigs
    x = VRdata(:,2);
    y = VRdata(:,3);
    if plotball
        rewards = logical(VRdata(:,6));
    else
        rewards = logical(VRdata(:,4));
    end
    h4 = figure; 
    
    subplot(2, 1, 1);
    hold on;
    plot(x, y, '.k');
    plot(x(rewards), y(rewards), 'og');
    xlabel('X (VR units)');
    ylabel('Y (VR units)');
    box off;


    if plotball    
        x = VRdata(:,4);
        y = VRdata(:,5);
        subplot(2, 1, 2);
        hold on;
        plot(x, y, '.k');
        plot(x(rewards), y(rewards), 'og');
        xlabel('Xball (VR units)');
        ylabel('Yball (VR units)');
        box off;
        currdate = datestr(date());
        figtitle = sprintf('%s rec%d VRdata VR and ball coords %s', mousestr, recnr, currdate);
        suptitle(figtitle);
    end
    if savefigs     % save the figure in the right directory
        figname = sprintf('/%s_rec%d_VRdata_finalXY.fig', mousestr, recnr);
        jpgfigname = sprintf('/%s_rec%d_VRdata_finalXY.jpg', mousestr, recnr);
        pngfigname = sprintf('/%s_rec%d_VRdata_finalXY.png', mousestr, recnr);
        epsfigname = sprintf('/%s_rec%d_VRdata_finalXY.eps', mousestr, recnr);
    
        if ~exist(figdir,'dir')          
            mkdir(figdir);
        end
        saveas(gcf, [figdir figname]);
        hgexport(gcf, [figdir jpgfigname], hgexport('factorystyle'), 'Format', 'jpeg');
        hgexport(gcf, [figdir pngfigname], hgexport('factorystyle'), 'Format', 'png');
        hgexport(gcf, [figdir epsfigname], hgexport('factorystyle'), 'Format', 'eps');
    end
end
if ~showfigs
%    close(h2, h3);
end
%cd(dataworkdir);

%% do further processing
seg=[1:ntrackpnts];  %normally get all datapnts
if strcmp(mousestr,'a8')    %for mouse a8 rec2 take only last 45 mins
    npnts = 45 * 60 * 100 %45mins assuming 100Hz tracking
    seg = seg(ndatapnts-npnts+1:ndatapnts);
    length(seg)
end

%             seg = [1:10000];  %check subset of datapnts for testing
T = VRdata(seg,1);
Talt = [0:length(seg)-1]'/100;  %make new regularly spaced timestamps, without gaps
XVR = VRdata(seg,2);
YVR = VRdata(seg,3);
if plotball
    Xball = VRdata(seg,4);
    Yball = VRdata(seg,5);
    rewards = VRdata(seg,6);
else
    rewards = VRdata(seg,4);
end

%convert position coords to cm, based on 500 units per 60 cm of the ball
XVR = XVR*60/500; 
YVR = YVR*60/500;     
if plotball
    Xball = Xball*60/500; 
    Yball = Yball*60/500;         
end
%% apply temporal (Gaussian) filter to position data and compute speeds
[XVRfilt, YVRfilt, VRspeeds, hVRfig] = computespeeds(Talt, XVR, YVR, makefigs);
if plotball
    [Xballfilt, Yballfilt, ballspeeds, hballfig] = computespeeds(Talt, Xball, Yball, makefigs);
end
%% create and save new VRdata mat file
if plotball
VRdatafinal = horzcat(Talt, XVRfilt, YVRfilt, Xballfilt, Yballfilt, rewards, VRspeeds, ballspeeds);  
else
    VRdatafinal = horzcat(Talt, XVRfilt, YVRfilt, rewards, VRspeeds); 
end

if savetrackingmatfiles
    file2save=([mousestr '_rec' num2str(recnr) '_VRdatafinal.mat']);
    save(file2save, 'VRdatafinal', 'VR_tpulsesrel', '-v7.3'); 
end

%% save figures from computespeeds if requested
if savefigs  
    % save the figure in the right directory
    %figdir = ['/store01_alzheimer/Data_Work/' mousestr '/analysis/trackingfigs'];
    if ~exist(figdir,'dir')          
        mkdir(figdir);
    end
    %first plot VR tracking
    figure(hVRfig);
    figname = sprintf('/%s_rec%d_alltrackingVRfinal.fig', mousestr, recnr);
    fullname = [figdir figname];
    saveas(gcf, fullname);
    figname = sprintf('/%s_rec%d_alltrackingVRfinal.eps', mousestr, recnr);
    fullname = [figdir figname];
    hgexport(gcf, fullname, hgexport('factorystyle'), 'Format', 'eps');
    figname = sprintf('/%s_rec%d_alltrackingVRfinal.png', mousestr, recnr);
    fullname = [figdir figname];
    hgexport(gcf, fullname, hgexport('factorystyle'), 'Format', 'png');
    %then plot ball tracking
    if plotball
        figure(hballfig);
        figname = sprintf('/%s_rec%d_alltrackingballfinal.fig', mousestr, recnr);
        fullname = [figdir figname];
        saveas(gcf, fullname);
        figname = sprintf('/%s_rec%d_alltrackingballfinal.eps', mousestr, recnr);
        fullname = [figdir figname];
        hgexport(gcf, fullname, hgexport('factorystyle'), 'Format', 'eps');
        figname = sprintf('/%s_rec%d_alltrackingballfinal.png', mousestr, recnr);
        fullname = [figdir figname];
        hgexport(gcf, fullname, hgexport('factorystyle'), 'Format', 'png');
    end
end
