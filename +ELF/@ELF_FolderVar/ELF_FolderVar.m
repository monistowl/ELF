classdef ELF_FolderVar
    %ELF_FolderVar Superclass for treating a folder of vars like a vector
    %   Objects inheriting this class are saved as folders of
    %   ELF.ELF_Handleobj objects. 
    
    properties
        name
        dirpath
        
    end
    
    properties (Dependent)
        
    end
    
    methods
        function ELF_FolderVar = ELF_FolderVar(name,dest)
            %ELF_FolderVar Construct an instance of this class
            %   Detailed explanation goes here
            
            
            
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
    
    %% SETTERS
    
    %% GETTERS
    
    %% STATIC
end

