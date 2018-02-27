%% plot_UDS_laser
% uses ds data from anaesthetized recs to visualize elecrophys traces
% during laser stim

laser_chan = dsdata(33,:);
snip_lims = [5.5e5:7.5e5];
my_chan = dsdata(1,:);
%my_chan = dsdata(1,snip_lims);


% ha(1) = subplot(2,1,1)
% %plot(laser_chan)
% %plot(laser_chan(snip_lims))
% ha(2) =subplot(2,1,2)
%plot(my_chan);
%plot(my_chan)
%linkaxes(ha, 'x');

[n_SWRs_pre, n_SWRs_post, epoch_indices] = detect_SWRs_Claudia(my_chan,1)
initial_filt=designfilt('bandpassfir','FilterOrder',2,'CutoffFrequency1',...
    2,'CutoffFrequency2',300,'SampleRate',1000);
  dataIn=my_chan; 
%  dataOut = filter(b,a,dataIn);

dataOut = filter(initial_filt,dataIn);

rectified=dataOut-mean(dataOut);

sgolay=sgolayfilt(rectified,3,299);
%%
figure
ha(1)=subplot(3,1,1)
plot(laser_chan)
ha(2)=subplot(3,1,2)
plot(sgolay)

hold on
x=1:length(my_chan);
%      for e=1:size(epoch_indices,1)
%          plot(x(epoch_indices{e,1}),sgolay(epoch_indices{e,1}),'o')
%      end

% for e=1:size(epoch_indices,1)
%     vfill([epoch_indices{e,1}(1) epoch_indices{e,1}(end)],'g','facealpha',.6,'edgecolor','g','linestyle','--')
% end

%%
[AllMaxTheta,AllMaxDelta, AllMaxGamma, AllMaxFreqs, AllMaxFreqsGamma,...
  AllThetaNorm, avgd] = Stockwell4Snippet_4CleanData(my_chan,1000,[],[],[],[]);

ha(3) = subplot(3,1,3)
plot(AllMaxGamma)
linkaxes(ha, 'x')

%%
x=1:length(AllMaxGamma);
test=find(AllMaxGamma > 4*std(AllMaxGamma));
%%
figure
ha(1)=subplot(2,1,1)
plot(my_chan)
ha(2)=subplot(2,1,2)
plot(AllMaxGamma)
hold on
plot(x(test),AllMaxGamma(test),'o')
linkaxes(ha, 'x')