classdef ELF_HandleObj < handle
%ELF_HandleObj Superclass for Extensible Lab Framework handle objects
% Other data source types inherit this class, and implement their own
% preproc methods (so that arrays of empty objects can be assigned to
% Tasks, and then preproc'd en masse).
% 
% ELF_HandleObj inherits handle, and is inherited by ELF data classes.
%                   (@ELF.Physio,@ELF.Behav,@ELF.Event...)
% 
% All classes inheriting get these methods for free:
%   save, open, saveas
%
% OBJECT SAVE AND LOAD
%
% "Normal" MATLAB save and load are unmodified, to allow scripting within
% existing paradigms. However, this can cause unintuitive behavior:
%   
%   x = false; save file1 x;
%   x = true; save file2 x;
%   load file1; load file2; overwrites x from file1
%   x % true
%
%   clear x;
%   x1 = false;
%   x2 = load(file2); % loads all vars in file2 into x struct
%   x1 %false
%   x2.x %true
% 
% For more familiar GUI-style open/save/saveas behavior, ELF objects all keep
% track of their savepath, and define methods to save one object per file:
%
% Obj = ELF.ELF_HandleObj.ELFopen(matpath) % Obj is set to saved DataSource 
%                                % Obj.savepath is set to matpath, in case
%                                %  file has been moved/copied.
%                                % (also works as ELF.PhysioData.open, &c.)
%
% Obj.open(matpath) % Calls ELF.ELF_HandleObj.ELFopen(matpath), checks class,
%                   % overwrites existing object if it matches.
%   
% Obj.save % save Obj to Obj.savepath; if Obj.savepath is not set, prompt
% Obj.save(savepath) % Save Obj to savepath, setting Obj.savepath to savepath
%
% Obj.saveas % Force prompt for new Obj.savepath
% Obj.saveas(savepath) % Same as Obj.save(savepath) 
%
%See Also: ELF.Physio, ELF.Behav, ELF.Events
    
    properties
        sourcepath=''; %Path to original file data
        savepath=''; %Save-to location
        problems=[]; %List of errors generated during (batch) processing
    end
    
    properties (Dependent)
        has_sourcepath %True if sourcepath non-empty
        has_savepath %True if savepath non-empty
        has_problems %True if problems non-empty
    end
    
    methods
        function ELF_HandleObj = ELF_HandleObj(sourcepath,varargin)
        %ELF_HandleObj Construct ELF handle object
        % ELF_HandleObj %Empty object
        % ELF_HandleObj(sourcepath) %Set data file path
        % ELF_HandleObj(___,Name,Value) %Set options
        %
        %
        %Optional params:
        % PreprocNow %If false, just set path and wait on processing
        % 
        %
        %Examples:
        % ELF_HandleObj('myfile','PreprocNow',false)
        %
        %See also: Physio.Physio, Events.Events, Behav.Behav
        
            %if nargin==0; return; end %Empty object
            
            %If passed path to existing object, load it
            
            
            %If passed an existing object, use it
            supers = superclasses(sourcepath);
            if ismember('ELF.ELF_HandleObj',supers)
                ELF_HandleObj=sourcepath; return;
            end
            
            if ~ischar(sourcepath); error('ELF_HandleObj:InvalidPath', ...
                'Invalid file name!'); return; end
        
            %If passed a .mat, load it and look for an ELF_HandleObj stored
            % in a variable called ELF__SavedObject
            [~, ~, extension] = fileparts(sourcepath);
            if strcmp(extension,'mat')
                ELF_HandleObj = ELF.ELF_HandleObj.open(sourcepath); return;
            end

            if ~isempty(sourcepath) %Store full path (see setter method)
                ELF_HandleObj.sourcepath = sourcepath;
            end 
            
            p = inputParser;
            p.KeepUnmatched=true; %Ignore args meant for subclasses
            
            p.addParameter('DebugMode',false);
            p.addParameter('PreprocNow',true);
            %addOptional(p,'CustomPreproc',@ELF.Utilities.NOP);
            p.parse(varargin{:});
            
            if(p.Results.PreprocNow); ELF_HandleObj.preproc; end
        end
        
        function preproc(ELF_HandleObj)
            %preproc Process data from sourcepath
            % Placeholder for function of same name in subclasses
            %See also: ELF.Physio.preproc, ELF.Events.preproc,
            %          ELF.Behav.preproc
            
            %do nothing
            %disp('No preproc method defined!\n');
        end
        
        function preprocAndSave(ELF_HandleObj,savepath)
            if nargin>1; ELF_HandleObj.savepath=savepath; end
            ELF_HandleObj.preproc;
            ELF_HandleObj.save;
        end
        
        function set.sourcepath(ELF_HandleObj,sourcepath)
            ELF_HandleObj.sourcepath=getFullPath(sourcepath);
            ELF_HandleObj.clearProblems(); %new file, assume new data
            if ~exist(ELF_HandleObj.sourcepath,'file'); ...
                ELF_HandleObj.addProblem('File not found! Check path.'); end
        end
        
        function set.savepath(P,savepath)
            P.savepath = getFullPath(savepath); %save full path, not relative
        end
                
        function save(ELF__SavedObject,savepath)
        %save Save an object to a single-var file using specified name
            if nargin>1; ELF__SavedObject.savepath=savepath; end
            if ~ELF__SavedObject.has_savepath
                [file,path]=uiputfile('*.mat','Saving PhysioData...');
                ELF__SavedObject.savepath=getFullPath(fullfile(path,file));
            end
            save(ELF__SavedObject.savepath,'ELF__SavedObject');
        end
        
        function ELF_HandleObj = open(~,matpath)
            ELF_HandleObj = ELF.ELF_HandleObj.ELFOpen(matpath);
        end
                
        function saveas(ELF__SavedObject,savepath)
            if nargin<2
                [file,path]=uiputfile('*.mat','Saving PhysioData...');
                savepath=fullfile(file,path);
            end
            ELF__SavedObject.savepath=savepath;
            save(ELF__SavedObject.savepath,'ELF__SavedObject');
        end
        
        function addProblem(ELF_HandleObj,ME)
            ELF_HandleObj.problems = [ELF_HandleObj.problems,ME];
        end
        
        function clearProblems(ELF_HandleObj)
            ELF_HandleObj.problems = [];
        end
    
        
        function has_sourcepath = get.has_sourcepath(ELF_HandleObj)
        %True if sourcepath non-empty
            has_sourcepath=~isempty(ELF_HandleObj.sourcepath);
        end
        function has_savepath = get.has_savepath(ELF_HandleObj)
        %True if savepath non-empty
            has_savepath=~isempty(ELF_HandleObj.savepath);
        end
        function has_problems = get.has_problems(ELF_HandleObj)
        %True if problems non-empty
            has_problems=~isempty(ELF_HandleObj.problems);
        end
    end
    
    methods (Static)
        
        function ELF_HandleObj = ELFopen(matpath)
        %ELFopen Open saved ELF object (GUI style, not MATLAB load)
        % Obj = ELF.ELF_HandleObj.ELFopen(matpath)
        % Obj is set to saved DataSource (not stuct) 
        % Obj.savepath is set to matpath, in case
        % file has been moved/copied.
        % (also works as ELF.PhysioData.open, &c.)

            s = load(getFullPath(matpath));
            ELF_HandleObj = s.ELF__SavedObject;
            ELF_HandleObj.savepath = matpath;
        end

    end
end


