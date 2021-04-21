classdef Behav < ELF.ELF_HandleObj
    %Behav Data from eprime edat.txt
    % All the response data from an eprime task run (the edat log)
    %
    %See also: Event, Physio, 
    
    properties
        edat_t %Table of all data from an eprime task run (the edat log)
    end
    
    properties (Dependent)
        taskevents_t; %Sub-table of edat data with event numbers specified
    end
    
    methods
        
        % CONSTRUCTOR
        function Behav = Behav(sourcepath,varargin)
            %Behav: initialize from file
            if nargin==0; sourcepath=''; end
            Behav=Behav@ELF.ELF_HandleObj(sourcepath,varargin{:});
        end
        
        % PREPROCESSING
        
        function preproc(Behav)
            try
                Behav.edat_t = Behav.readEdatTxt(Behav.sourcepath);
            catch ME
                
            end
        end
        
        % DEPENDENT PROPERTIES
        
        function taskevents_t = get.taskevents_t(Behav)
            taskevents_t = Behav.onlyWith('event');
        end
        
        
        %% UTILITIES
        
        
        function trimmed_t = onlyWith(Behav,expr)
        %onlyWith Shows only table data with vars matching expr not missing
        % Behav.onlyWith('trialtype') %Show only rows/cols where
        %                             %edat_t.trialtype has non-missing rows
        %See also: 
        
        matchrows = any(~ismissing(table2array(Behav.edat_t(:, ...
            cellfun(@(x) ~isempty(regexpi(x,expr)), ...
            Behav.edat_t.Properties.VariableNames))))')';
        
        trimmed_t = rmMissingCols(Behav.edat_t(matchrows,:));        
        end
        
        %findCol('Authorship'
        function col = findSlideVar(target_)
            %rows = 
            
            
        end
        
        
        
    end
    
    methods (Static)
        
        % readEdatTxt Read an edat .txt file containing behavioral responses
        [T,headervars]=readEdatTxt(sourcepath,varargin)
        
        % read_edat_txt Read an edat.txt file containing behavioral responses
        [edat_struct, edat_cells] = read_edat_txt(path)
    end
end

