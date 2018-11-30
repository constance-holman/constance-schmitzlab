%% training_speed_composition
% looks at different speeds present in each recordings, and bins them
% according to (normallized) occurence
% input = VRdatafinal from each training day

function[alldatastruct]= training_speed_composition(genotype)
allbins_final=[];


if strcmp('WT',genotype)
    allmice = {'M22','M26','M28','M29','M33'};
else
    allmice = {'M20','M21','M25','M27','M30','M32','M34'}; 
end

allbouts_final_mean = [];
allbouts_final_std = [];

for m = 1:length(allmice)
    mousename = char(allmice(m));
    

datadir =  ['/alzheimer/TrainingData/' mousename '/'];
    cd(datadir)
    allfiles = dir('*VRdatafinal.mat');
    allfiles = {allfiles.name}
    
    %filespecs = [ datadir '*VRdatafinal.mat']; 

        
    %[trainingfilesnames, pathname] = uigetfile(filespecs, 'Select VRdatafinal files to import', 'MultiSelect', 'on');
        
     %   if isequal(trainingfilesnames, 0)
      %      error('User selected Cancel');
       % end
        
        %trainingfilesnames = cellstr(trainingfilesnames);  % Care for the correct type 

        ntrainingfiles = length(allfiles);
    
        allbins = NaN(15,ntrainingfiles);
        
        for i=1:ntrainingfiles
            thisfile = allfiles{i};
            disp(thisfile);
            load(thisfile)


            speed = VRdatafinal(:,5);
            speed_length = length(speed);
            
            [mean_bout, std_bout] = find_running_bouts(speed);
            allbouts_final_mean(:,i,m) = mean_bout;
            allbouts_final_std(:,i,m) = std_bout;
            

%% 
    allbins(1,i) = (sum(speed < 2)./speed_length)*100;
    allbins(2,i) = (sum(speed > 2 & speed <= 4)./speed_length)*100;
    allbins(3,i) = (sum(speed > 6 & speed <= 8)./speed_length)*100;
    allbins(4,i) = (sum(speed > 10 & speed <= 12)./speed_length)*100;
    allbins(5,i) = (sum(speed > 12 & speed <= 14)./speed_length)*100;
    allbins(6,i) = (sum(speed > 14 & speed <= 16)./speed_length)*100;
    allbins(7,i) = (sum(speed > 16 & speed <= 18)./speed_length)*100;
    allbins(8,i) = (sum(speed > 18 & speed <= 20)./speed_length)*100;
    allbins(9,i) = (sum(speed > 20 & speed <= 25)./speed_length)*100;
    allbins(10,i) = (sum(speed > 25 & speed <= 30)./speed_length)*100;
    allbins(11,i) = (sum(speed > 30 & speed <= 35)./speed_length)*100;
    allbins(12,i) = (sum(speed > 35 & speed <= 40)./speed_length)*100;
    allbins(13,i) = (sum(speed > 40 & speed <= 45)./speed_length)*100;
    allbins(14,i) = (sum(speed > 45 & speed <= 50)./speed_length)*100;
    allbins(15,i) = (sum(speed > 60)./speed_length)*100;

        end
        %% Make figure for each animal

        if m == 1
            plot(allbouts_final_mean','o','LineWidth',2,'MarkerSize',20)
        else
            plot(allbouts_final_mean(:,:,m)','o','LineWidth',2,'MarkerSize',20)
        end
        titlestr = ([mousename ' Average Bout Length (Rough)']);
        title(titlestr)
%        legend('<2','2-5','5-10','10-20','20 +')
legend('<2','2-10','10+')
        ylabel('Average Speed (cm/s)')
        xlabel('Training Session')
        savefig(titlestr)
        close

%% Trim speed proportion to 7 days
        if size(allbins,2) < 7
            allbins = horzcat(allbins,NaN(15,1));
        end
        allbins_final(:,:,m) = allbins(:,[1:7]); % only look at the first 7 sessions to ease concatenation
end

allbouts_final_mean(allbouts_final_mean == 0) = NaN;
allbouts_final_std(allbouts_final_std == 0) = NaN;

        %%
%         grand_mean = nanmean(allbins_final,3);
%         h1 = imagesc(grand_mean)
%         h2 = colorbar;
%         y_values = {'<2','2-4','4-6','6-8','8-10','10-12','12-14','14-16','16-18','18-20','20-25','25-30','35-40','45-50','50+'};
%         set(gca,'YDir','normal')
%         set(gca,'ytick',[1:15],'yticklabel',y_values)
%         xlabel('Training Day')
%         ylabel(h2,'% time');
%         overall_title = [genotype ' Speed Distribution Over Time'];
%         title(overall_title)
%         savefig(overall_title)
%         
% 
% 

