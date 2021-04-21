classdef Task < ELF.ELF_HandleObj
    %ELF.Task: Collection of ALL data on a particular task
    %   Calculate pan-task data across disparate sources
    %       (e.g. physiological recordings and behavioral responses)
    %   Can be used standalone or as part of a parent Study
    %See also: Study
    
    properties
        name = ''
        savedir = ''
        sources = table
        savepaths = table
        
%         perwindow_t %table of Windows, function on sourcerow
%         pertask_t %table of function on sourcerow
%         
%         results
        

        %funcs
        
%         physio_data
%         behav_data
%         event_data % note that 'events' is a reserved keyword
        
    end
    
    properties (Dependent)
%         missingfiles_t
%         results_stacked_t
%         results_unstacked_t %struct
        has_sources
        
    end
    
    methods
        function Task = Task(name,varargin)
        %ELF.Task: Combine data from one or more sources
        % INPUTS
        % name: Will be sanitized to variable-name compatible
        %  ('_' for ' ', '/',&c.)
        % sources: optional pairs of 'sourcename' @constructor
        %
        % OUTPUTS
        %
        %
        % EXAMPLES
        %
        %See also: Physio, Event, Behav
        
            if nargin==0; return; end
            Task=Task@ELF.ELF_HandleObj('',varargin{:});
            
            p=inputParser;
            p.addParameter('Sources',table);
            p.addParameter('Paths',table);
            p.parse(varargin{:});
            p.Results
        end
        
        function gui(Task)
            TaskGui(Task);
        end
        
        function addSource(Task,classfunc,varargin)
            if nargin<2; return; end
                
            p=inputParser;
            p.addParameter('SearchPath',);
            p.parse(varargin{:});
            p.Results
            
            %Task.sources
        end
        
        function sources = loadSubject(id)
        %loadSubject
        
        end
        
        function sourceFun(sourcename,func)
            
        end
        
        function taskFun(funcs)
            
        end
        
        function genSubjects(fromid,toid,varargin)
        %genSubjects Generate a bunch of empty objects, and set their attributes
        % Task.genSubjects(101,184)
            if nargin<2
                %error
                return;
            end
            
            if nargin>2
                
            end
            
            for id=fromid:toid
                
            end
        end
        
%         function window_vars(T)
%             T.E.window_between
%             T.E.window_after
%             
%         end
        
%         function tv = hrvWindowAvgs(P,E)
%             combo_tt = synchronize( ...
%                 %T.physio_data.hrv_tt,
%                 T.event_data.windowsBetweenEventsNamed('[][]','End');
%                 
%             %tv.(sprintf()) = 
%         end
        function preprocAll(Task)
            for i=1:width(Task.sources)
                for j=1:height(Task.sources)
                    obj = Task.sources{j,i}; obj.preproc;
                end
            end
        end

    end
    
    %% STATIC TASKVAR FUNCTIONS
    % Use these to calculate taskvars out of multiple data source objects
    % All should return 1xN tables, which may be combined horizontally
    methods (Static)
        
        function asdf = fdsa(B,E,P)
            
        end

 
    end
    
    %% STATIC TASKVAR UTILITIES
    % Helper functions for flatteners above
    % All should return timetables
    methods (Static)
        
        %interpolate timetables
        hrv_with_events_behav_tt = hrvWithEventsBehav(B,E,P,toget)
        
        %hrvWindowStats: add hrv stats to all windows in wins_t
        function hrv_win_stats = hrvWindowStats(P,wins_t,varstoget)
            if nargin<3
                varstoget = P.hrv_tt.Properties.VariableNames;
            end
            
            hrv_tt = P.hrv_tt(:,varstoget);
            
            hrv_win_stats = wins_t;
            for i=1:height(wins_t)
                hrv_slice = sliceTT(hrv_tt,wins_t.WindowStart(i),wins_t.WindowEnd(i));
                hrv_vars = varfun(@mean,hrv_slice);
%                 hrv_vars = [hrv_vars varfun(@max,hrv_slice)];
%                 hrv_vars = [hrv_vars varfun(@min,hrv_slice)];
                
                varnames = hrv_vars.Properties.VariableNames;
                for j=1:length(varnames)
                    hrv_win_stats.(varnames{j})(i) = hrv_vars.(varnames{j});
                end
            end
            
        end
        
%         function hrv_with_events_tt = hrvWithEvents(E,P)
%             hrv_with_events_tt = synchronize(P.hrv_tt, E.events_tt);
%         end

        
        %eventsWithBehav.m: combine event timetable with behav vars
        wins_t = windowsFromBehav(B,E,varstoget)
    end
    
    %% SETTERS (FOR SIDE EFFECTS + VALIDATION)
    methods
%         function Task = set.name(Task,name)
%             name = getvarname(name);
%             dirpath = getFullPath(name);
%             if exists(dirpath) % If there's already a folder, rename
%                 error('A task by that name already exists!'); return;
%             end
%             movefile(Task.dirpath,dirpath);
%             Task.dirpath = 
%             
%             movefile(fullfile(),fullfile());
%             Task.name = 
%         end
    end
    
    %% GETTERS (FOR DEPENDENT PROPERTIES)
    methods
        
        %
        function has_sources = get.has_sources(Task)
            has_sources = ~isempty(Task.sources);
        end
        
%         function paths_t = get.paths_t(T)
%             paths_t = table();
%             paths_t.ids = T.ids;
%             colnames = T.sources_t.Properties.VariableNames;
%             for i=1:length(colnames)
%                 colname = colnames{i};
%                 col = T.sources_t.(colname);
%                 pathcol = repmat(string(missing),length(col),1);
%                 for j=1:length(pathcol)
%                     pathcol(j) = col(j).path;
%                 end
%                 paths_t.(colname) = pathcol;
%             end
%         end
        
        
%         function missingfiles_t = get.missingfiles_t(T)
%             missingfiles_t = table();
%             missingfiles_t.ids = T.ids;
%             paths = T.paths_t;
%             paths.ids = [];
%             
%             colnames = paths.Properties.VariableNames;
%             for i=1:length(colnames)
%                 colname = colnames{i};
%                 pathcol = paths.(colname);
%                 missingfiles_t.(colname) = boolean(cellfun(@exist,pathcol));
%             end       
%         end
%         function ecg_with_events_tt = get.ecg_with_events_tt(T)
%             ecg_with_events_tt = synchronize( ...
%                 T.physio_data.ecg_clean_tt, T.event_data.events_tt);
%         end
%         function hrv_with_events_tt = get.hrv_with_events_tt(T)
%             hrv_with_events_tt = synchronize( ...
%                 T.physio_data.hrv_tt, T.event_data.events_tt);
%         end
    end
    
end

