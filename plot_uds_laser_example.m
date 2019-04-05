%% plot_uds_laser_example
my_chan = dsdata(1,:);
laser_chan = dsdata(33,:);
laser_on = laser_chan > 0.6;
laser_switch = find(diff(laser_on) ~= 0);

switch_on = laser_switch(1:2:end);
switch_off = laser_switch(2:2:end);
%%
all_switches= padcat(switch_on,switch_off)';
%%
nice_lims1 = [1.08e5:1.2e5];
subplot(2,1,1)
x = [0.1:0.1:1200];
plot(x,baseline_data(nice_lims1(1:end-1)));
%%
subplot(2,1,2)
plot(my_chan)
hold on
%for i = 1:length(all_switches)
vfill(all_switches,'g','facealpha',0.3);
%end
xlim([7.08e5, 7.2e5]); 
ylim([-1000, 500])
xlabel('Time (ms)')


