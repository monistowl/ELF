%TODO


%% Set up toolkits
%setupELF;

%% Locate study data
%physio_basepath = 'Y:\Individual lab members folders\Nick\Dissertation\PhysioData';
physio_basepath =  '/home/tom/Nick/Dissertation/PhysioData/';
%physio_basepath = fullfile(pwd,'DemoData','PhysioData');

%behav_basepath = 'Y:\Individual lab members folders\Nick\Dissertation\BehavData';
behav_basepath = '/home/tom/Nick/Dissertation/BehavData/';
%behav_basepath = fullfile(pwd,'DemoData','PhysioData');


%% 

%Subjects = [];

%The canonical names of your tasks. Cannot contain spaces. {'name1','name2',...}
task_names = {'Baseline','Time','Interoception','AAT','Narrative'};

%Task names as they appear in the names of the edat files
behav_task_names = {'01 Baseline';'02 Time Estimation';'03 Interoception';'04 Agency AAT';'05 Narrative Interoception'};
%Task names as they appear in the names of the mw and event files
physio_task_names = {'Baseline';'Time';'Interoception';'AAT';'Narrative'};

save_to = '/home/tom/NickDiss';
preproc_basepath = '/home/tom/NickDiss/Preprocs';

tasknum = 4;

task_name = task_names{tasknum};
behav_task_name = behav_task_names{tasknum};
physio_task_name = physio_task_names{tasknum};


ids = [101:111]';
behav_path = repmat(string(missing),length(ids),1);
physio_path = repmat(string(missing),length(ids),1);
event_path = repmat(string(missing),length(ids),1);

% for i=1:length(ids)
%     Tpaths(i,1) = fullfile(preproc_basepath,sprintf("%d_%s_Preproc.mat",ids(i),task_name));
% end



for i=1:length(ids)
    B(i,1) = ELF.Behav(fullfile(behav_basepath,sprintf('%d',ids(i)),sprintf('%s-%d-1.txt',behav_task_name,ids(i))),'PreprocNow',false);
    E(i,1) = ELF.Events(fullfile(physio_basepath,sprintf('%d',ids(i)),sprintf('%d_%s_1_event.txt',ids(i),physio_task_name)),'PreprocNow',false);
    P(i,1) = ELF.Physio(fullfile(physio_basepath,sprintf('%d',ids(i)),sprintf('%d_%s_1.mw',ids(i),physio_task_name)),'PreprocNow',false);
end

sources = table(B,E,P);

T = ELF.Task(task_name,sources);


% for i=1:length(ids)
%     fprintf('Processing Subject %d, task %s...\n',ids(i),task_name);
%     load(Tpaths(i));
%     T.preproc_and_save();
% end
% 
% for i=1:length(ids)
%     load(Tpaths(i));
%     Ts(i,1) = T;
% end

%P=Ts(67).P;

% clear P;
% clear edh;
% clear fid;
% P = PhysioData('/home/tom/Documents/bada/2570/AAI_2570_1.mw')
% P.preproc;
% fid=fopen('/home/tom/Documents/bada/2570/edit data/AAI_2570_1_cleaned.edh','r','b');
% A=fread(fid,'uint16').*(10 / (2^16));
% fclose(fid);



fid=fopen('/home/tom/Documents/bada/2570/edit data/AAI_2570_1_cleaned.edh','r','b');
ann=fread(fid,'uint16');
fclose(fid);



% for i=1:length(ids)
%     B = BehavData(fullfile(behav_basepath,sprintf('%d',ids(i)),sprintf('%s-%d-1.txt',behav_task_name,ids(i))),false);
%     B.preprocpath = fullfile(preproc_basepath,sprintf("%d_%s_BehavData.mat",ids(i),task_name));
%     save(B.preprocpath,'B');
%     
%     B_preprocs(i,1) = B.preprocpath;
%     
%     E = EventData(fullfile(physio_basepath,sprintf('%d',ids(i)),sprintf('%d_%s_1_event.txt',ids(i),physio_task_name)),false);
%     E.preprocpath = fullfile(preproc_basepath,sprintf("%d_%s_EventData.mat",ids(i),task_name));
%     save(E.preprocpath,'E');
%     
%     E_preprocs(i,1) = E.preprocpath;
%     
%     P = PhysioData(fullfile(physio_basepath,sprintf('%d',ids(i)),sprintf('%d_%s_1.mw',ids(i),physio_task_name)),false);
%     P.preprocpath = fullfile(preproc_basepath,sprintf("%d_%s_PhysioData.mat",ids(i),task_name));
%     save(P.preprocpath,'P');
%     
%     P_preprocs(i,1) = P.preprocpath;
% end
% 
% preprocs_t = table(B_preprocs, E_preprocs, P_preprocs);
% 
% % for i=1:length(ids)
% %     Bs{i,1} = matfile(preprocs_t.B_preprocs(i),'Writable',true);
% %     Es{i,1} = matfile(preprocs_t.E_preprocs(i),'Writable',true);
% %     Ps{i,1} = matfile(preprocs_t.P_preprocs(i),'Writable',true);
% % end
% % 
% % sources_t = table(Bs,Es,Ps);
% 
% T = Task(task_name);
% T.ids = ids;
% T.sources_t = sources_t;

%T.preproc;


% Bs = cellfun(@BehavData,behav_path);
% 
% 
% 
% 
% 
% T.sources_t = table();
% 
% for i=1:length(ids)
%     if has_behavfile(i) && has_eventfile(i) && has_physiofile(i)
%         
%     else
%         
%     end
% end


% for id=ids(1):ids(end)
%     sprintf('Attempting to process %s for participant %d...\n',task_name,id);
%     try
%         
%         toget.hrv = {'aHF','aLF','LFHF'};
%         toget.behav = {'Stimuli__RESP','Authorship__RESP','Binding__RESP', 'Delay', ...
%             'Image','up_down'};
% 
%         behav_path = fullfile(behav_basepath,sprintf('%d',id),sprintf('%s-%d-1.txt',behav_task_name,id));
%         B = BehavData(behav_path);
% 
%         event_path = fullfile(physio_basepath,sprintf('%d',id),sprintf('%d_%s_1_event.txt',id,physio_task_name));
%         E = EventData(event_path);
% 
%         physio_path = fullfile(physio_basepath,sprintf('%d',id),sprintf('%d_%s_1.mw',id,physio_task_name));
%         P = PhysioData(physio_path);
%         
%         
%         
%         wins_t = Task.windowsFromBehav(B,E,toget.behav);
%         hrv_win_stats = Task.hrvWindowStats(P,wins_t,toget.hrv);
%         
%         writetable(hrv_win_stats,fullfile(winstats_writedir,sprintf('%d_%s_WindowStats.xlsx',id,task_name)));
%         
%         subjectrow = flattenT(hrv_win_stats);
%         
%         colnames = subjectrow.Properties.VariableNames;
%         for i=1:length(colnames)
%             task_table.(colnames{i})(id) = subjectrow.(colnames{i});
%         end
%     catch ME
%         sprintf('Problem with %d!\n',id);
%         %rethrow(ME)
%     end
%     
%     
% end
% 
% % sources.B = B;
% % sources.E = E;
% % sources.P = P;
% 
% 
% 
% 
% %T = Task(task_name,sources);
% 
% 
% 
% 
% 

% 
% task_var_fn = @(T) (...
%     T.taskVarsFromTimeTableWindows( ...
%         T.sources.P, ...
%         T.sources.E.windowsBetweenEventsNamed('TC100','End')) ...
% );
% 
% T.addTaskVarFunction( ...
%     task_var_fn
% );

% function mytaskvar = get_taskvar1(sources)
%     mytaskvar = 1;
%     sources.P 
% end















% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % classdef Task
% %     %ELF.Task: Collection of ALL data on a particular task
% %     %   Calculate pan-task data across disparate sources
% %     %       (e.g. physiological recordings and behavioral responses)
% %     %   Can be used standalone or as part of a parent Study
% %     %See also: Study
% %     
% %     properties
% %         name
% %         savedir
% %         sources = {}
% %         
% %         
% %         perwindow_t %table of window name, start, end, function on T
% %         pertask_t %table of name, function on T
% %         
% %         results
% %         
% % 
% %         %funcs
% %         
% % %         physio_data
% % %         behav_data
% % %         event_data % note that 'events' is a reserved keyword
% %         
% %     end
% %     
% %     properties (Dependent)
% % %         missingfiles_t
% % %         results_stacked_t
% % %         results_unstacked_t %struct
% %         
% %     end
% %     
% %     methods
% %         function T = Task(name,perwindow_t,pertask_t)
% %             %TASK Construct an instance of this class
% %             %   Detailed explanation goes here
% %             if (nargin == 0)
% %                 name='Task_Name';
% %             end
% %             T.name = name;
% %             
% %             if nargin<2 %init empty perwindow table
% %                 perwindow_t = table( ...
% %                     string(missing), ...
% %                     seconds(0), ...
% %                     seconds(0), ...
% %                     {@(T) sprintf('No function defined!')}, ...
% %                     'VariableNames',{'Name','Start','End','Fn'});
% %                 perwindow_t(1,:)=[];
% %             end
% %             
% %             if nargin<3 %init empty pertask table
% %                 pertask_t = table( ...
% %                     string(missing), ...
% %                     {@(T) sprintf('No function defined!')}, ...
% %                     'VariableNames',{'Name','Fn'});
% %             end
% %             
% %             T.perwindow_t = perwindow_t;
% %             T.pertask_t = pertask_t;
% %         end
% %         
% %         function preproc(T)
% %             try
% %                 T.B.preproc;
% %             catch ME
% %                 disp(' Could not process BehavData!\n');
% %             end
% %             
% %             try
% %                 T.E.preproc;
% %             catch ME
% %                 disp(' Could not process EventData!\n');
% %             end
% %             
% %             try
% %                 T.P.preproc;
% %             catch ME
% %                 disp(' Could not process PhysioData!\n');
% %             end
% %         end
% %         
% %         function preproc_and_save(T)
% %             preproc(T);
% %             save(T.savepath,'T');
% %         end
% %         
% %         function gui(T)
% %             TaskGui(T);
% %         end
% %         
% %         function sources = loadSubject(id)
% %         %loadSubject:  
% %         end
% %         
% %         function sourceFun(sourcename,func)
% %             
% %         end
% %         
% %         function taskFun()
% %             
% %         end
% %         
% % %         function window_vars(T)
% % %             T.E.window_between
% % %             T.E.window_after
% % %             
% % %         end
% %         
% % %         function tv = hrvWindowAvgs(P,E)
% % %             combo_tt = synchronize( ...
% % %                 %T.physio_data.hrv_tt,
% % %                 T.event_data.windowsBetweenEventsNamed('[][]','End');
% % %                 
% % %             %tv.(sprintf()) = 
% % %         end
% %         
% % 
% %     end
% %     
% %     %% STATIC TASKVAR FUNCTIONS
% %     % Use these to calculate taskvars out of multiple data source objects
% %     % All should return 1xN tables, which may be combined horizontally
% %     methods (Static)
% %         
% %         function asdf = fdsa(B,E,P)
% %             
% %         end
% % 
% %  
% %     end
% %     
% %     %% STATIC TASKVAR UTILITIES
% %     % Helper functions for flatteners above
% %     % All should return timetables
% %     methods (Static)
% %         
% %         %interpolate timetables
% %         hrv_with_events_behav_tt = hrvWithEventsBehav(B,E,P,toget)
% %         
% %         %hrvWindowStats: add hrv stats to all windows in wins_t
% %         function hrv_win_stats = hrvWindowStats(P,wins_t,varstoget)
% %             if nargin<3
% %                 varstoget = P.hrv_tt.Properties.VariableNames;
% %             end
% %             
% %             hrv_tt = P.hrv_tt(:,varstoget);
% %             
% %             hrv_win_stats = wins_t;
% %             for i=1:height(wins_t)
% %                 hrv_slice = sliceTT(hrv_tt,wins_t.WindowStart(i),wins_t.WindowEnd(i));
% %                 hrv_vars = varfun(@mean,hrv_slice);
% % %                 hrv_vars = [hrv_vars varfun(@max,hrv_slice)];
% % %                 hrv_vars = [hrv_vars varfun(@min,hrv_slice)];
% %                 
% %                 varnames = hrv_vars.Properties.VariableNames;
% %                 for j=1:length(varnames)
% %                     hrv_win_stats.(varnames{j})(i) = hrv_vars.(varnames{j});
% %                 end
% %             end
% %             
% %         end
% %         
% % %         function hrv_with_events_tt = hrvWithEvents(E,P)
% % %             hrv_with_events_tt = synchronize(P.hrv_tt, E.events_tt);
% % %         end
% % 
% %         
% %         %eventsWithBehav.m: combine event timetable with behav vars
% %         wins_t = windowsFromBehav(B,E,varstoget)
% %     end
% %     
% %     %% GETTERS/SETTERS FOR DEPENDENT PROPERTIES
% %     methods
% %         
% % %         function paths_t = get.paths_t(T)
% % %             paths_t = table();
% % %             paths_t.ids = T.ids;
% % %             colnames = T.sources_t.Properties.VariableNames;
% % %             for i=1:length(colnames)
% % %                 colname = colnames{i};
% % %                 col = T.sources_t.(colname);
% % %                 pathcol = repmat(string(missing),length(col),1);
% % %                 for j=1:length(pathcol)
% % %                     pathcol(j) = col(j).path;
% % %                 end
% % %                 paths_t.(colname) = pathcol;
% % %             end
% % %         end
% %         
% %         
% % %         function missingfiles_t = get.missingfiles_t(T)
% % %             missingfiles_t = table();
% % %             missingfiles_t.ids = T.ids;
% % %             paths = T.paths_t;
% % %             paths.ids = [];
% % %             
% % %             colnames = paths.Properties.VariableNames;
% % %             for i=1:length(colnames)
% % %                 colname = colnames{i};
% % %                 pathcol = paths.(colname);
% % %                 missingfiles_t.(colname) = boolean(cellfun(@exist,pathcol));
% % %             end       
% % %         end
% % %         function ecg_with_events_tt = get.ecg_with_events_tt(T)
% % %             ecg_with_events_tt = synchronize( ...
% % %                 T.physio_data.ecg_clean_tt, T.event_data.events_tt);
% % %         end
% % %         function hrv_with_events_tt = get.hrv_with_events_tt(T)
% % %             hrv_with_events_tt = synchronize( ...
% % %                 T.physio_data.hrv_tt, T.event_data.events_tt);
% % %         end
% %     end
% %     
% % end
% % 
