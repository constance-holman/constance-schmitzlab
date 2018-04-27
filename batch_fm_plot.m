%% batch_fm_plot
% used to make various plots based on spectro data created by
% batch_spectral_analysis
function batch_fm_plot(mousename)
analysispath = ['/alzheimer/Data_Work/' mousename '/analysis'];
cd(analysispath)

[recfilenames, pathname] = uigetfile('*.mat', 'Select spectro files to import', 'MultiSelect', 'on');
    if isequal(recfilenames, 0)
        error('User selected Cancel');
    end
    recfilenames = cellstr(recfilenames);  % Care for the correct type bat
    
    nrecfiles = length(recfilenames);
    reclegend = [];
    figure
    hold on
    
for n = 1:nrecfiles
    curr_file = recfilenames{n};
    
    %extract date from recording file. options are _ddmmyy.mat or
    %_ddmmyy_2.mat
    if strcmp(curr_file(end-10),'_')
        recdate = curr_file(end-9:end-4);
    else
        recdate = curr_file(end-11:end-4);
    end
    reclegend{n} = recdate;
    
     load(curr_file)
     plot(mean(StockwellSpectro))

end
legend(reclegend)


