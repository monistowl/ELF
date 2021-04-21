classdef Windows < ELF.ELF_HandleObj
    
    properties
        wins_t = table; %Table of [WinStart, WinEnd, WinName] sorted by start
    end
    
    properties (Dependent)
        wins_tt %Timetable of [WinStart, WinDuration, WinName] sorted by start
        wins_a %Array of [winstart,winend] as seconds (doubles)
        wins_ta %Array of [winstart,winend] as seconds (durations)
        count %Total number of windows defined
    end
    
    methods
        function Windows = Windows(varargin)
        %Windows Initialize Windows object
        % ELF.Windows %Empty object
        % ELF.Windows(winstart,winend) %Between timestamps
        % ELF.Windows([winstarts,winends]) %Same (2-col array)
        %   e.g. (10,20) %Between 10s and 20s
        %        ([10,20]) Same
        %        (10,20,30,40) %Between 10s and 20s, 30s and 40s
        %        ([10,20],[30,40]) %Same
        %        ([10,20;30,40]) %Same
        % ELF.Windows(winstart,winend,names) %Set window names
        %   e.g. (10,20,'mywin')
        %        ([10,20;30,40],'mywin1','mywin2')
        %        (10,20,30,40,{'mywin1','mywin2'})
        % ELF.Windows(Events,___) %Pass args to Events.winsAround
        % ELF.Windows(Windows1,Windows2...) %Merge/add Windows
        % 
        %See also: winsAround
        
            Windows@ELF.ELF_HandleObj(''); %Don't bother setting sourcepath yet
            
            if isempty(varargin); return; end %If no args, empty object
            
            
            switch class(varargin{1})
                case 'table' %Set wins_t directly
                    Windows.wins_t=varargin{1}; %See setter
                    
                case 'double' %Set from list of numbers/names
                    [rown,coln]=size(varargin{1});
                    if coln==1 %assume (winstart1,winend1,winname1,...)
                        if length(varargin)<2; return; end
                        
                        events_t=table;
                        events_t.WinStart=varargin{1};
                        events_t.WinEnd=varargin{2};
                        
                        if length(varargin)>2
                            i=3;
                            if ischar(varargin{3})
                                events_t.WinName=varargin{3};
                                i=i+1;
                            end
                            Windows=ELF.Windows(events_t);
                            if length(varargin)>i %Recurse on remaining args
                                Windows=Windows+Windows(varargin{i:end});
                            end
                        end
                        
                    end
                        
                    if coln==2 %assume ([winstarts,winends],{winnames},...)
                        events_t=table;
                        wins_a=varargin{1};
                        events_t.WinStart=wins_a(:,1);
                        events_t.WinEnd=wins_a(:,2);
                        i=2;
                        if length(varargin)>1
                            if iscellstr(varargin{2}) %If name list, use
                                WinName=varargin{2}';
                                if length(WinName)<rown %Blank names if short
                                    WinName=[WinName; ...
                                        repmat({''},rown-length(WinName),1)];
                                end
                                if length(WinName)>rown %Trim names if long
                                    WinName=WinName(1:rown);
                                end
                                events_t.WinNames=WinName;
                                i=i+1;
                            end
                            if ischar(varargin{2}) %If one name, add nums
                               WinName=repmat({''},rown,1); %Preallocate blanks
                               for j=1:rown
                                   WinName{j}=sprintf('%s%d',varargin{2},j);
                               end
                                
                               events_t.WinNames=WinName;
                               i=i+1; 
                            end
                        end
                        Windows=ELF.Windows(events_t);
                        if length(varargin)>i %Recurse on remaining args
                            Windows=Windows+Windows(varargin{i:end});
                        end
                    end
                    
                case 'ELF.Events' %Pass args to winsAround
                    Windows=arg1.winsAround(varargin{2:end});
                    
                case 'ELF.Windows'
                    for i=1:length(varargin)
                        Windows = Windows + varargin{i};
                    end
                    
                otherwise
                    return;
            end
            
        end
        
        %% SETTERS
        
        function Windows = set.wins_t(Windows,input_t)
            new_wins_t = table;
            
            if length(intersect({'WinStart','WinEnd'}, ...
                    input_t.Properties.VariableNames))==2
                WinStart=input_t.WinStart;
                WinEnd=input_t.WinEnd;
                if ~isduration(WinStart(1)); WinStart=seconds(WinStart); end
                if ~isduration(WinEnd(1)); WinEnd=seconds(WinEnd); end

                if isempty(intersect('WinName', ...
                    input_t.Properties.VariableNames))
                    WinName=repmat({''},height(input_t),1);
                else
                    WinName=input_t.WinName;
                end
                
                new_wins_t=table(WinStart,WinEnd,WinName);

                %Fill in any missing names
                
                
                %avoid choking on height 1 tables because matlab sucks
                %new_wins_t.WinName is not cell if only one window
                
                if ischar(new_wins_t.WinName) %stupid hack
                    if isempty(new_wins_t.WinName)
                        new_wins_t.WinName = 'Window';
                    end
                else
                if any(cellfun(@isempty,new_wins_t.WinName))
                    k=1;
                    for j=1:height(new_wins_t)
                        if isempty(new_wins_t.WinName{j})
                            while ~isempty(intersect(new_wins_t.WinName, ...
                                sprintf('Win%d',k)))
                                k=k+1;
                            end
                            new_wins_t.WinName{j}=sprintf('Win%d',k);
                        end
                    end
                end
                
                end
                
            end
            Windows.wins_t=sortrows(new_wins_t,'WinStart');
        end
        
        function Windows = prefixWinNames(Windows,prefix)
        %prefixWinNames Quickly add prefix to window names
        % Windows.prefixWinNames(prefix)
        %See also: renameWins
            if ~Windows.count; Windows=Windows; return; end
            
            new_wins_t = Windows.wins_t;

            for i=1:Windows.count
                new_wins_t.WinName{i}= ...
                    sprintf('%s_%s',prefix,Windows.wins_t.WinName{i});
            end
                
            Windows.wins_t=new_wins_t;
        end
        
        function Windows = renameWins(Windows,newnames)
        %renameWins Quickly rename windows to custom titles
        % Windows.renameWins(name) %Use name if 1 win, name1 name2 &c. if mult
        % Windows.renameWins({'name1','name2'}) %Chronological list, generic
        %                                     %if too short, trimmed if too long
        %See also: renameWinsMatching
        
            new_wins_t = Windows.wins_t;
            switch class(newnames)
                case 'char'
                    switch Windows.count
                        case 0
                            Windows=Windows; return;
                        case 1
                            new_wins_t.WinName{1}=newnames;
                        otherwise
                            for i=1:Windows.count
                                new_wins_t.WinName{i}= ...
                                    sprintf('%s%d',newnames,i);
                            end
                    end                
                case 'cell'
                    if iscellstr(newnames)
                        for i=1:Windows.count
                            if i<= length(newnames)
                                new_wins_t.WinName{i}=newnames{i};
                            else
                                new_wins_t.WinName{i}='';
                            end
                        end
                    end
            end
            Windows.wins_t=new_wins_t;
        end
        
        function Windows = renameWinsMatching(Windows, varargin)
        %renameWinsMatching Quickly search and replace window names
        % Windows.renameWins(pattern,replacement)
        % Windows.renameWins(p1,r1,p2,r2,...)
        %See also: renameWinsMatching
                    
            new_wins_t = Windows.wins_t; %Init empty table
            
            if length(varargin) == 2 && iscellstr(varargin)
                for i=1:Windows.count
                    sttrep(new_wins_t.WinName{i}, ...
                        varargin{1},varargin{2});
                end
            else
                return;
            end
                
                
        end
        
        %% GETTERS
        
        function count = get.count(Windows); count=height(Windows.wins_t); end
        
        function wins_tt = get.wins_tt(Windows)
            wins_tt=table2timetable(Windows.wins_t);
        end
        
        function wins_a = get.wins_a(Windows)
            wins_a=seconds(Windows.wins_ta);
        end
        
        function wins_ta = get.wins_ta(Windows)
            wins_ta=[Windows.wins_t.WinStart, Windows.wins_t.WinEnd];
        end
        %% OPERATOR OVERLOADS
        
        function isem = isempty(Windows)
        %isempty Return true if no windows defined
            
            isem = isempty(Windows.wins_t);
        end
        
        function iseq = eq(Windows1,Windows2)
        %isequal Return true if windows are identical
        
            iseq=isempty(Windows1-Windows2) && isempty(Windows2-Windows1);
        end
        
        function CombinedWindows = plus(Windows1,Windows2)
        %plus Combine two sets of windows
        % CombinedWindows = Windows1 + Windows2 %Combine windows
        %See also: minus, or, and
        
            CombinedWindows = ELF.Windows;
            if isempty(Windows1) && isempty(Windows2); return; end;
            
            if isempty(Windows1)
                CombinedWindows=ELF.Windows(Windows2.wins_t); return;
            end
            if isempty(Events2)
                CombinedWindows=ELF.Windows(Windows2.wins_t); return;
            end
            CombinedWindows.wins_t = [Windows1.wins_t; Windows2.wins_t];
        end
        
        function TrimmedWindows = minus(Windows1,Windows2)
        %minus Deletes identical events
        % TrimmedEvents = Events1 - Events2 %Combine events, ignore paths 
        %See also: plus, or, and
            
            TrimmedWindows = ELF.Windows(setdiff( ...
                Windows1.wins_t, Windows2.wins_t));
        end
        
        function CombinedWindows = or(Windows1,Windows2)
        %or Combines events (same as +)
        % CombinedWindows = Windows1 | Windows2
        %See also: and, plus, minus
            
            CombinedWindows = Windows1 + Windows2;
        end
        
        function TrimmedWindows = and(Windows1,Windows2)
        %and Windows present in BOTH Windows1 and Windows2
        % (inverse of Windows1 - Windows2)
        % TrimmedWindows = Events1 & Events2
        %See also: or, plus, minus
           
            TrimmedWindows = ELF.Windows(intersect( ...
                Windows1.wins_t, Windows2.wins_t));
        end
        
    end
    
end