%% find_running_bouts
% sorts running speed in different bins and sorts according to bout (i.e.
% continuous activity) length. Compares across training days.
% Input speed, i.e. final column of VRdatafinal

function [mean_bout, std_bout] = find_running_bouts(speed)

mean_bout = NaN(1,3);
std_bout = NaN(1,3);
%% Part I: Fine Bins

% bin1 = find(speed < 2); % indices where speed is below threshold x
% bin1_t = find(diff(bin1) ~= 1); %speed discontinuities mark end of epoch above/below threshold
% bin1_bouts = vertcat(bin1_t(1),diff(bin1_t));
% mean_bout(1) = mean(bin1_bouts);
% std_bout(1) = std(bin1_bouts);
% 
% 
% bin2 = find((speed >= 2) & (speed < 5));
% bin2_t = find(diff(bin2) ~= 1);
% bin2_bouts = vertcat(bin2_t(1),diff(bin2_t));
% mean_bout(2) = mean(bin2_bouts);
% std_bout(2) = std(bin2_bouts);
% 
% bin3 = find((speed >= 5) & (speed < 10));
% bin3_t = find(diff(bin3) ~= 1);
% bin3_bouts = vertcat(bin3_t(1),diff(bin3_t));
% mean_bout(3) = mean(bin3_bouts);
% std_bout(3) = std(bin3_bouts);
% 
% bin4 = find((speed >= 10) & (speed < 20));
% bin4_t = find(diff(bin4) ~= 1);
% bin4_bouts = vertcat(bin4_t(1),diff(bin4_t));
% mean_bout(4) = mean(bin4_bouts);
% std_bout(4) = std(bin4_bouts);
% 
% bin5 = find(speed >= 20);
% bin5_t = find(diff(bin5) ~= 1);
% bin5_bouts = vertcat(bin5_t(1),diff(bin5_t));
% mean_bout(5) = mean(bin5_bouts);
% std_bout(5) = std(bin5_bouts);

%% Rough Version
bin1 = find(speed < 2); % indices where speed is below threshold x
bin1_t = find(diff(bin1) ~= 1); %speed discontinuities mark end of epoch above/below threshold
bin1_bouts = vertcat(bin1_t(1),diff(bin1_t));
mean_bout(1) = mean(bin1_bouts);
std_bout(1) = std(bin1_bouts);

bin2 = find((speed >= 2) & (speed < 10));
bin2_t = find(diff(bin2) ~= 1);
bin2_bouts = vertcat(bin2_t(1),diff(bin2_t));
mean_bout(2) = mean(bin2_bouts);
std_bout(2) = std(bin2_bouts);

bin3 = find(speed >= 10);
bin3_t = find(diff(bin3) ~= 1);
bin3_bouts = vertcat(bin3_t(1),diff(bin3_t));
mean_bout(3) = mean(bin3_bouts);
std_bout(3) = std(bin3_bouts);
