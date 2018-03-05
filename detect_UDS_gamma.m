%% detect_UDS_gamma
% finds UDS based on deflection of gamma power above a certain threshold
% and returns indices of said event
function [final_epoch_indices] = detect_UDS_gamma(my_chan,std_thresh,mindur)

% extract gamma power from channel
[AllMaxTheta,AllMaxDelta, AllMaxGamma, AllMaxFreqs, AllMaxFreqsGamma,...
  AllThetaNorm, avgd] = Stockwell4Snippet_4CleanData(my_chan,1000,[],[],[],[]);

% find places where gamma power goes above a certain threshold
%event=find(AllMaxGamma > std_thresh*std(AllMaxGamma))';
event=find(AllMaxDelta > std_thresh*std(AllMaxDelta));


            da=find(diff(event) ~= 1)+1; %find discontinuities in speed
            da = [1, da, length(event)+1];
            
            for k = 1 : length(da)-1
                % First cell has the linear segments
                sa{k, 1} = event(da(k) : da(k+1)-1);
                % Second cell has the starting and stopping indices in the
                % original trace
                sa{k, 2} = [event(da(k)),event(da(k+1)-1)];
            end
            %% find snippets longer than a given threshhold
             epoch_lengths=[1:length(sa)];
             epoch_indices=[];
             if exist('sa')
             for i=1:size(sa,1)
                if (length(sa{i,1}))>=mindur; %minimum time
                    epoch_temp=sa(i,:);
                    if ~isempty(epoch_indices)
                   epoch_indices=vertcat(epoch_indices,epoch_temp);
                    else
                        epoch_indices=epoch_temp;
                    end
                end
             end
             end
     clear sa
     clear epoch_temp
%% combines epochs that are close enough to one another to be part of the same event

r=1; %row counter
c=1;
diff_count = 1;
while c < length(epoch_indices)-diff_count
            diff_count = 1;
            
    if epoch_indices{c+diff_count,1}(1) - epoch_indices{c+diff_count-1,1}(end) < 1000
        while epoch_indices{c+diff_count,1}(1) - epoch_indices{c+diff_count-1,1}(end) < 1000 ...
            && c < length(epoch_indices)-diff_count
            % c always lags behind "edge" of longer epochs
            final_epoch_indices{r,1} = epoch_indices{c,1}(1):epoch_indices{c+diff_count,1}(end);
            final_epoch_indices{r, 2} = [epoch_indices{c,1}(1),epoch_indices{c+diff_count,1}(end)];
            diff_count = diff_count + 1;
        end

    else
        final_epoch_indices{r,1} = epoch_indices{c,1};
        final_epoch_indices{r, 2} = [epoch_indices{c,1}(1),epoch_indices{c,1}(end)];
    end
    c=c+diff_count; %default: c increases by 1.
    r = r+1; % move to a new row
end
x=1:length(my_chan);
figure
plot(my_chan)
hold on
 if ~isempty(final_epoch_indices) %if there are any detected events
     for e=1:size(final_epoch_indices,1)
         plot(x(final_epoch_indices{e,1}),my_chan(final_epoch_indices{e,1}),'o')
     end
 end