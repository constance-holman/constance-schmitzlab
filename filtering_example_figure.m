% % filtering_example_figure
% NEED raw LFP panel + HP,LP and BP filtering
% 
% % Gaussian filter with sigma = 12;     % sd for Gaussian, 120ms based on Chen et al. Mehta2011 mouse freely moving gamma paper    
%     and size = 200;     % window size for Gaussian
% 
% speed = VRdatafinal([118000:130000],5);
% 
% T = VRdatafinal([118000:130000],1);
% % Gaussian filtered coords
% x = VRdatafinal([118000:130000],2);
% y = VRdatafinal([118000:130000],3);
% t= VRdatafinal([118000:130000],1);
%  t = [0:2/12000:2]';
% rewards = find(VRdatafinal([118000:130000],4)==1);
% 
% plot(x, y, '.k');
% hold on 
% plot(x(rewards), y(rewards), 'og'); %prototypical example of plotting rewards on other curves
% % compute raw speeds
%     need VRdata
%     x_raw = VRdata([118000:130000],2);
%     y_raw = VRdata([118000:130000],3);
%     V = sqrt(diff(x_raw).^2 + diff(y_raw).^2)./diff(T);
%     V = [V;V(end)]; 
% 
% plot(t,V)
% 
% %
% hold on
% 
% plot(t,speed)
% 
% plot(t(rewards),speed(rewards), 'og','MarkerSize',10);
%  hold on
% %
%  % apply a different Gaussian smoothing to tracking data 
%     make a gaussian filter
%          sigma = 50; %half a second at 100Hz sampling rate; based on Kemere et al. Frank2013
%          size = 600; %6s window size; based on Kemere et al. Frank2013
%    sigma = 12;     % sd for Gaussian, 120ms based on Chen et al. Mehta2011 mouse freely moving gamma paper    
%     size = 200;     % window size for Gaussian
%     pos = linspace(-size / 2, size / 2, size);
%     gaussFilter = exp(-pos .^ 2 / (2 * sigma ^ 2));
%     gaussFilter = gaussFilter / sum (gaussFilter);
%     
%     create padding to reduce edge effects
%     startpadX = x_raw(1).*ones(size,1);
%     endpadX = x_raw(end).*ones(size,1);
%     Xextended = [startpadX; x_raw; endpadX];
%     apply Gaussian filter to padded data
%     Xfilt = conv(Xextended, gaussFilter, 'same');
%     remove padding
%     ind = true(length(Xextended),1);
%     ind(1:size)=0;
%     ind(end-size+1:end)=0;
%     Xfilt = Xfilt(ind); 
%     
%     startpadY = y_raw(1).*ones(size,1);
%     endpadY = y_raw(end).*ones(size,1);
%     Yextended = [startpadY;y_raw;endpadY];
%     Yfilt = conv(Yextended, gaussFilter, 'same');
%     Yfilt = Yfilt(ind);  %remove padding  
%     
% 
%      Vfilt = sqrt(diff(Xfilt).^2 + diff(Yfilt).^2)./diff(T);  
%     Vfilt = [Vfilt;Vfilt(end)]; %copy last point to keep nr of pnts same
%     
%     plot(t,Vfilt)
%     % for plotting example of reward noise
%     
%     
    limits =  [1.03e6:1.05e6];
   % limits = [1:length(alldata)];
    mychan = alldata(limits,7);
    rewards = find (alldata(limits,4) == 1);
    chan_t = 1:length(alldata);
     t = alldata(limits,1);
     x = alldata(limits,2);
     y = alldata(limits,3);
     
     grand_mean = mean(alldata(limits,[5:36])');
     clean = mychan'-grand_mean;
%          
          [Xfilt, Yfilt, Vfilt, h0] = computespeeds(t, x, y, 0);

    %% for filtered version of same data
    
%300 Hz = 0.6 rad
fc = 4; %cutoff freq
fs = 1000;

[b,a] = butter(6,fc/(fs/2),'high');

dataIn=mychan;
dataOut = filter(b,a,dataIn);

    %%
    detrended_mat = detrend(mychan);
    %%
    
    detrended = locdetrend(mychan, fs, [0.1 .05]); % chronux locdetrend with no moving window specified

    %% Final Figure Showing All Filtering Options
    h1= figure;
    h2 = figure;
    h3 = figure;
    
    times = [0:1/1000:20];
    
    %Raw
    figure(h1)
    subplot(4,1,1)
    plot(times,mychan)
    hold on

    xlim([0, 20])
    ylim([-5500, 5500])
    vline(rewards/1000,'r','Reward')

    figure(h2)
    [AllStockwellSpectro AllStockwellTimes StockwellFreqs MeanThetaPower,MeanThetaPowerNorm, ThetaGammaNorm, MaxFreq, avgd]...
        = Stockwell4_ThetaChan(mychan);
    subplot(4,1,1)
    imagesc(zscore(AllStockwellSpectro))
    axis xy
    vline(rewards,'w','Reward')
    ylim([0 50])
    title('Raw')
    
    figure(h3)
   
    %plot(MeanThetaPowerNorm)
        plot(MeanThetaPower)
hold on

    
    %Mean Subtraction
    figure(h1)
    subplot(4,1,2)
    plot(times,clean)
    xlim([0,20])
    ylim([-5500, 5500])
    title('Mean Subtraction')
        vline(rewards/1000,'r','')
    
    figure(h2) 
    [AllStockwellSpectro AllStockwellTimes StockwellFreqs MeanThetaPower,MeanThetaPowerNorm, ThetaGammaNorm, MaxFreq, avgd]...
         = Stockwell4_ThetaChan(clean);
    subplot(4,1,2)
    imagesc(zscore(AllStockwellSpectro))
    axis xy
    vline(rewards,'w','')
    ylim([0 50])
    title('Mean Subtraction')
    
        figure(h3)
   % subplot(5,1,2)
    %plot(MeanThetaPowerNorm)
        plot(MeanThetaPower)
    %xlim([1, length(mychan)])
    %title('Mean Subtraction')
    
    
    %Butterworth Filter
    figure(h1)
        subplot(4,1,3)
    plot(times, dataOut)
    xlim([0 20])
    ylim([-5500, 5500])
    title('6th Order Butterworth Filter')
            vline(rewards/1000,'r','')
    
    figure(h2)
     [AllStockwellSpectro AllStockwellTimes StockwellFreqs MeanThetaPower,MeanThetaPowerNorm,ThetaGammaNorm, MaxFreq, avgd]...
         = Stockwell4_ThetaChan(dataOut);
    subplot(4,1,3)
    imagesc(zscore(AllStockwellSpectro))
    axis xy
     vline(rewards,'w','')
    ylim([0 50])
    title('6th Order Butterworth Filter')
    
        figure(h3)
    %subplot(5,1,3)
    %plot(MeanThetaPowerNorm)
        plot(MeanThetaPower)
        
    %xlim([1, length(mychan)])
    %title('6th Order Butterworth Filter')
    
    
    %Chronux locdetrend
    figure(h1)
    subplot(4,1,4)
    plot(times, detrended)
    xlim([0 20])
    ylim([-5500, 5500])
    title('Chronux Locdetrend')
            vline(rewards/1000,'r','')
    
    figure(h2)
     [AllStockwellSpectro AllStockwellTimes StockwellFreqs MeanThetaPower,MeanThetaPowerNorm,ThetaGammaNorm, MaxFreq, avgd]...
         = Stockwell4_ThetaChan(detrended);
    subplot(4,1,4)
    imagesc(zscore(AllStockwellSpectro))
    axis xy
     vline(rewards,'w','')
    ylim([0 50])
    title('Chronux Locdetrend')
    
        figure(h3)
   % subplot(5,1,4)
    plot(MeanThetaPower)
    %plot(MeanThetaPowerNorm)
    title('Raw Theta Power')
    xlim([1, length(MeanThetaPower)])
    %title('Chronux Locdetrend')
    
    
%     %Matlab detrend
%     figure(h1)
%     subplot(5,1,5)
%     plot(detrended_mat)
%     xlim([1, length(mychan)])
%     title('Matlab Detrend')
%     
%     figure(h2)
%      [AllStockwellSpectro AllStockwellTimes StockwellFreqs MeanThetaPower,MeanThetaPowerNorm, MaxFreq, avgd]...
%          = Stockwell4_ThetaChan(detrended_mat);
%     subplot(5,1,5)
%     imagesc(AllStockwellSpectro)
%     axis xy
%     ylim([0 100])
%     title('Matlab Detrend')
%     
%         figure(h3)
%    % subplot(5,1,5)
%     plot(MeanThetaPower)
%     %xlim([1, length(mychan)])
%     %title('Matlab Detrend')
     legend('Raw','Mean Subtraction','6th Order Butterworth','Chronux Locdetrend')
%     
%     
   %% compare bandpass + hilbert

   [d,c] = butter(3,[5 11]/(fs/2)); 
   dataOut = filter(d,c,dataIn);

   theta_amp = abs(hilbert(dataOut));
   
   figure
   subplot(1,2,1)
   plot(dataOut)
   xlim([0 length(dataOut)])
   title ('Bandpass Signal (5 - 11 Hz)')
   subplot(1,2,2)
   plot(theta_amp)
   xlim([0 length(theta_amp)])
   title('Amplitude fr. Hilbert Transform')
   
    
    
    
    
  
    
    