%% plot_reward_dynamics

% Input: uses Mx_rewdynamics files to plot, i.e. latency to reward over
% training day as function of full population

allrew_WT=[];
allrew_TG=[];
all_v_pre_WT=[];
all_v_pre_TG=[];
all_v_post_WT=[];
all_v_post_TG=[];


wt_datadir = '/alzheimer/TrainingData/Population Analysis/WT/';
%cd(filedir)

filespecs = [ wt_datadir '*rewdynamics.mat']; 
cd(wt_datadir)

        [trainingfilesnames, pathname] = uigetfile(filespecs, 'Select rewdynamics files to import', 'MultiSelect', 'on');
        if isequal(trainingfilesnames, 0)
            error('User selected Cancel');
        end
        trainingfilesnames = cellstr(trainingfilesnames);  % Care for the correct type
        ntrainingfiles = length(trainingfilesnames);
        
        figure
        hold on
        
            for i=1:ntrainingfiles
            thisfile = trainingfilesnames{i};
            disp(thisfile);
            load(thisfile)
            
            allrew_WT = catpad(2,allrew_WT,t_pre_final);
            all_v_pre_WT = vertcat(all_v_pre_WT, v_pre_final);
            all_v_post_WT = vertcat(all_v_post_WT, v_post_final);
            
            
            %plot(t_pre_final,'o','color',rand(1,3))
            ax1 = subplot(2,2,1)
            hold on
            mouse_colour = rand(1,3)
            plot(mean(v_pre_final(1:10,:)),'color',mouse_colour)
            title('Velocity Pre First 10 Rewards')
            
            ax2 = subplot(2,2,2)
            hold on
            plot(mean(v_post_final(1:10,:)),'color', mouse_colour)
            title('Velocity Post First 10 Rewards')
            
            ax3 = subplot(2,2,3)
            hold on
            plot(mean(v_pre_final(end-10:end,:)),'color',mouse_colour)
            title('Velocity Pre Last 10 Rewards')
            
            ax4 = subplot(2,2,4)
            hold on
            plot(mean(v_post_final(end-10:end,:)),'color', mouse_colour)
            title('Velocity Post Last 10 Rewards')
            end
            
            linkaxes([ax1,ax2,ax3,ax4],'xy')
            mtit('Velocity Over Time in WT Animals')
            
            clear v_pre_final v_post_final t_pre_final
            

            %%
            
            
tg_datadir = '/alzheimer/TrainingData/Population Analysis/TG/';
%cd(filedir)

filespecs = [ tg_datadir '*rewdynamics.mat']; 
cd(tg_datadir)

        [trainingfilesnames, pathname] = uigetfile(filespecs, 'Select rewdynamics files to import', 'MultiSelect', 'on');
        if isequal(trainingfilesnames, 0)
            error('User selected Cancel');
        end
        trainingfilesnames = cellstr(trainingfilesnames);  % Care for the correct type
        ntrainingfiles = length(trainingfilesnames);

        figure
        hold on 

%         
            for i=1:ntrainingfiles
            thisfile = trainingfilesnames{i};
            disp(thisfile);
            load(thisfile)

               allrew_TG = catpad(2,allrew_TG,t_pre_final);
               

                all_v_pre_TG = vertcat(all_v_pre_TG, v_pre_final);
                all_v_post_TG = vertcat(all_v_post_TG, v_post_final);
%             
%             plot(t_pre_final,'x','color',rand(1,3))
%             plot(t_pre_final,'o','color',rand(1,3))

            ax1 = subplot(2,2,1)
            hold on
            mouse_colour = rand(1,3)
            plot(mean(v_pre_final(3:13,:)),'color',mouse_colour)
            title('Velocity Pre First 10 Rewards')
            
            ax2 = subplot(2,2,2)
            hold on
            plot(mean(v_post_final(1:10,:)),'color', mouse_colour)
            title('Velocity Post First 10 Rewards')
            
            ax3 = subplot(2,2,3)
            hold on
            plot(mean(v_pre_final(end-10:end,:)),'color',mouse_colour)
            title('Velocity Pre Last 10 Rewards')
            
            ax4 = subplot(2,2,4)
            hold on
            plot(mean(v_post_final(end-10:end,:)),'color', mouse_colour)
            title('Velocity Post Last 10 Rewards')
            end
            
            linkaxes([ax1,ax2,ax3,ax4],'xy')
            mtit('Velocity Over Time in TG Animals')

            
            %% summary population data
% figure
% subplot(1,2,1)
% boxplot(allrew_WT')
% title('Summary Reward Latencies: WT')
% subplot(1,2,2)
% boxplot(allrew_TG')
% title('Summary Reward Latencies: TG')
%             