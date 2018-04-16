%% plot_UDS_laser
% uses ds data from anaesthetized recs to visualize elecrophys traces
% during laser stim

laser_chan = dsdata(33,:);
%snip_lims = [9.2e5:10.7e5];
snip_lims = 1:length(laser_chan);
%my_chan = dsdata(1,:);
my_chan = dsdata(1,snip_lims);


% ha(1) = subplot(2,1,1)
% %plot(laser_chan)
% %plot(laser_chan(snip_lims))
% ha(2) =subplot(2,1,2)
%plot(my_chan);
%plot(my_chan)
%linkaxes(ha, 'x');

epoch_indices = detect_UDS_gamma(my_chan',2,100);
%%
d = designfilt('bandstopiir','FilterOrder',6, ...
               'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
               'DesignMethod','butter','SampleRate',1000);
           
          my_chan_filt = filtfilt(d,my_chan);
%%
figure
ha(1)=subplot(2,1,1)
plot(laser_chan(snip_lims))
ha(2)=subplot(2,1,2)
plot(my_chan)

% hold on
% x=1:length(my_chan);
%      for e=1:size(epoch_indices,1)
%          plot(x(epoch_indices{e,1}),my_chan(epoch_indices{e,1}),'r')
%      end
%%
     linkaxes(ha, 'x')
for e=1:size(epoch_indices,1)
    vfill([epoch_indices{e,1}(1) epoch_indices{e,1}(end)],'g','facealpha',.6,'edgecolor','g','linestyle','--')
end

% %%
% [AllMaxTheta,AllMaxDelta, AllMaxGamma, AllMaxFreqs, AllMaxFreqsGamma,...
%   AllThetaNorm, avgd] = Stockwell4Snippet_4CleanData(my_chan,1000,[],[],[],[]);
% 
% ha(3) = subplot(3,1,3)
% plot(AllMaxGamma)
% linkaxes(ha, 'x')
% 
% %%
% x=1:length(AllMaxGamma);
% test=find(AllMaxGamma > 4*std(AllMaxGamma));
% %%
% figure
% ha(1)=subplot(2,1,1)
% plot(my_chan)
% ha(2)=subplot(2,1,2)
% plot(AllMaxGamma)
% hold on
% plot(x(test),AllMaxGamma(test),'o')
% linkaxes(ha, 'x')