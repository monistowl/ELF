classdef Study
    %STUDY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name = '';
        savedir = '';
        
        tasks = {};
        
        excludes=[]; % Subject ids to ignore
        
    end
    
    properties (Dependent)
        has_savedir % False if savedir not set
        
        matpaths_t
        
    end
    
    
    
    methods
        function Study = Study(name)
        %Study: Construct an instance of this class
        %
        % Study = ELF.Study; % 
        % Study.names
        
        %
        %
        	if nargin>0; Study.name = name; end
            %if nargin>1; Study.
                
                
                
%             if nargin>1
%                 switch class(templates)
%                     case 'struct'
%                         Study.templates = templates;
%                     case 'table'
%                         Study.templates = table2struct(templates);
%                     otherwise
%                         
%                 end
%             end
        
        end
        
        function saveobj(Study)
            
        end
        
        function save(ELF__SavedStudy,savedir)
        %ELF.Study.save: Save a study and associated data to a folder
            if nargin<2; savedir=ELF__SavedStudy.savedir; end
            if ~Study.has_savedir; Study.savedir = fullfile(pwd,Study.name); end
            
            
            
        end
        
        function saveas(Study,name)
            
        end
        
        function Study = open(Study,)
            
        end
        
        function addCol(name,id_start,id_end)
            
        end
        
        
        function results = colFun(Study, func, name)
        %pathsFun: Apply function to dir of saved ELF objects by path
        %    (This allows loading one at a time, to avoid using up
        %     all available memory for lots of long timeseries)
        %
        %See also: ELF.Study.dirFun
            n=length(pathcol);
            results = cell(n,:); % empty column of cells of output
            for i=1:n
                ELFObject = ELF.ELFObject.open(pathcol(i));
                results{i} = func(ELFObject);
            end     
        end
        
        
        
        function addTemplate();
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
    
    %% GETTERS AND SETTERS
    methods
        function has_savedir = get.has_savedir(Study)
            %get.has_savedir: True if savedir has been set.
            has_savedir = ~isempty(Study.savedir);
        end
        
        
    end
    
    methods (Static)
        function results = pathFun(func, dirpath)
        %dirFun: Apply function to dir of saved ELF objects by path
        %    (This allows loading one at a time, to avoid using up
        %     all available memory for lots of long timeseries)
        %
        %See also: ELF.Study.colFun
            n=length(pathcol);
            results = cell(n,:); % empty column of cells of output
            for i=1:n
                ELFObject = ELF.ELFObject.open(pathcol(i));
                results{i} = func(ELFObject);
            end     
        end
    end
end

