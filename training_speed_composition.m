%% training_speed_composition
% looks at different speeds present in each recordings, and bins them
% according to (normallized) occurence
% input = VRdatafinal from each training day

function[alldatastruct]= training_speed_composition(mousename)

datadir =  ['/alzheimer/TrainingData/' mousename '/']
    cd(datadir)
    
    filespecs = [ datadir '*VRdatafinal.mat']; 

        [trainingfilesnames, pathname] = uigetfile(filespecs, 'Select VRdatafinal files to import', 'MultiSelect', 'on');
        
        if isequal(trainingfilesnames, 0)
            error('User selected Cancel');
        end
        
        trainingfilesnames = cellstr(trainingfilesnames);  % Care for the correct type 

        ntrainingfiles = length(trainingfilesnames);
    
        allbins = NaN(10,ntrainingfiles);
        
        for i=1:ntrainingfiles
            thisfile = trainingfilesnames{i};
            disp(thisfile);
            load(thisfile)


            speed = VRdatafinal(:,5);
            speed_length = length(speed);

%% 
    allbins(1,i) = (sum(speed < 5)./speed_length)*100;
    allbins(2,i) = (sum(speed > 5 & speed <= 10)./speed_length)*100;
    allbins(3,i) = (sum(speed > 10 & speed <= 15)./speed_length)*100;
    allbins(4,i) = (sum(speed > 15 & speed <= 20)./speed_length)*100;
    allbins(5,i) = (sum(speed > 20 & speed <= 25)./speed_length)*100;
    allbins(6,i) = (sum(speed > 25 & speed <= 30)./speed_length)*100;
    allbins(7,i) = (sum(speed > 30 & speed <= 40)./speed_length)*100;
    allbins(8,i) = (sum(speed > 40 & speed <= 50)./speed_length)*100;
    allbins(9,i) = (sum(speed > 50 & speed <= 60)./speed_length)*100;
    allbins(10,i) = (sum(speed > 60)./speed_length)*100;

        end
        h1 = imagesc(allbins)
        h2 = colorbar;
        y_values = {'<5','5-10','10-15','15-20','20-25','25-30','30-40','40-50','50-60','60+'};
        set(gca,'YDir','normal')
        set(gca,'ytick',[1:10],'yticklabel',y_values)
        xlabel('Training Day')
        ylabel(h2,'% time');
        overall_title = [mousename ' Speed Distribution Over Time'];
        title(overall_title)
        savefig(overall_title)
        
end


