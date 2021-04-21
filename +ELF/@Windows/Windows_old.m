classdef Windows < ELF.ELF_HandleObj
%Windows Utilities for working with timetable windows
% Convert time windows in several formats to a common table format
% Windows(Windows) %Return input unmodified
% Windows([10,20]) %Between 10 and 20 seconds
% Windows(10,20) %Same
% Windows([10,20;20,30;30,40]) %Between 10 and 20, 20 and 30, 30 and 40
% Windows([10,20,30;20,30,40]) %Same
% Windows(table) %Looks for start and end time cols
% Windows(tt) %Windows between every other row in timetable
% Windows(tt1,tt1) %Windows between events in tt1 and tt2 (same height)
%See also: Events, Behav
    
    properties
        wins_t = table; %Table of window starts/ends with names (and optionally
                        %additional variables), ordered by start time
    end
    
    properties (Dependent)
        count %Total number of windows
        wins_tt %Timetable of window starts/durations
        wins_t_bare %Table of only start/end/name cols (no extra data)
        wins_dur_a %2-col array of durations [winstart,winend]
        wins_dbl_a %2-col array of doubles (in seconds) [winstart,winend]
        onerow_t %Table in one big row, with window names as var prefixes
    end
    
    methods
        function Windows = Windows(varargin)
        %Windows Construct window table given args in various formats
        % Windows(Windows) %Return input unmodified
        % Windows(Windows1,Windows2...) %Combine inputs TODO
        % Windows([10,20]) %Between 10 and 20 seconds
        % Windows(10,20) %Same
        % Windows([10,20;20,30;30,40]) %Between 10 and 20, 20 and 30, 30 and 40
        % Windows([10,20,30;20,30,40]) %Same
        % Windows(table) %Looks for start and end time cols
        % Windows(tt) %Windows between every other row in timetable
        % Windows(tt1,tt2) %Windows between events in tt1
        %                  %and first subsequent intt2 (same height) TODO
        % Windows(Events) %As Windows(tt) TODO
        % Windows(Events1,Events2) %As Windows(tt1,tt2)TODO
        %Returns empty object if input not recognized.
        %See also: Event, makeWinCols
        %See also: Event, makeWinCols
            
            if nargin == 0; return; end
            
            %get rid of args that don't make sense
%             for i=1:length(varargin)
%                 arg=varargin{i};
%                 if iscellstr(arg) || ischar(arg) || isstring(arg) || ...
%                     isa(arg,'function_handle')
%                     varargin(i)=[];
%                 end
%             end

            
            switch class(varargin{1})
                
                %If fed another Window object, use it
                case 'ELF.Windows'; Windows = varargin{1}; return;
                
                %If fed doubles, make seconds
                case {'double','single'}
                    if ~all(cellfun(@isnumeric,varargin)); return; end
                    Windows=ELF.Windows(seconds(cell2mat(varargin))); return;
                
                %If fed seconds, make table
                case 'duration'
                    if length(varargin)>1; varargin=varargin{1}; end
                    
                    array=[]; %2 col
                    
                    for j=1:length(varargin)
                        arg=varargin{j};
                        [h,w]=size(arg);
                        if h==2 && w>2; arg=arg'; end
                        arg=reshape(arg,[],2);
                        array=[array;arg];
                    end
                    
                    [h,~]=size(array);
                    DefaultWindowNames=cell(h,1);
                    for i=1:length(DefaultWindowNames)
                    	DefaultWindowNames{i}=sprintf('Window_%d',i);
                    end
                    wins_t=array2table(array, ...
                        'VariableNames',{'Start_Time','End_Time'});
                    wins_t.Window_Name=DefaultWindowNames;
                    
                    Windows=ELF.Windows(wins_t); return;
                
                %If fed table, check for cols and use
                case 'table'
                    if ~all(cellfun(@istable,varargin)); return; end
                    if ~range(cellfun(@width,varargin))==0; return; end
                    wins_t=table;
                    for i=1:length(varargin)
                        cur_wins_t=varargin{i};
                        if length(intersect( ...
                            {'Start_Time','End_Time','Window_Name'}, ...
                            cur_wins_t.Properties.VariableNames))<3
                            cur_wins_t=ELF.Windows.makeWinCols(cur_wins_t);
                        end
                        wins_t=[wins_t;cur_wins_t]; %Vertcat
                    end
                    Windows.wins_t=wins_t;
                
                %If fed timetable, convert to table
                case 'timetable'
                    
                    %If only one timetable, un-cell it
                    if length(varargin)==1 
                        wins_tt=(varargin{1});
                        wins_t=table;
                        
                        %If from wins_tt dependent property, parse accordingly
                        if ismember('Window_Duration', ...
                            wins_tt.Properties.VariableNames)
                            wins_t=timetable2table(wins_tt);
                            wins_t.Properties.VariableNames{ ...
                                strcmp(wins_t.Properties.VariableNames, ...
                                'Time')}='Start_Time';
                            
                            End_Time = seconds(1:height(wins_t))';
                            for i=1:length(End_Time)
                                End_Time(i)= ...
                                    wins_t.Start_Time(i) ...
                                    +wins_t.Window_Duration(i);
                            end
                            wins_t.End_Time = End_Time;
                            wins_t.Window_Duration = [];
                            Windows.wins_t = wins_t; return;
                        end
                            
                        %Otherwise, get windows for every other row
                        for i=1:height(wins_tt) 
                            winstartrow=timetable2table(wins_tt(i,:));
                            winstartrow.Properties.VariableNames= ...
                                cellfun(@(varname) strcat('Start_',varname), ...
                                winstartrow.Properties.VariableNames, ...
                                'UniformOutput',false);
                            
                            if i<height(wins_tt)
                            winendrow=timetable2table(wins_tt(i+1,:));
                            winendrow.Properties.VariableNames= ...
                                cellfun(@(varname) strcat('End_',varname), ...
                                winendrow.Properties.VariableNames, ...
                                'UniformOutput',false);
                            end
                            
                            winrow=[winstartrow,winendrow];
                            
                            wins_t=[wins_t; winrow];
                            
                            i=i+1;
                        end
                        Windows.wins_t=wins_t;
                    end
                    
                    %If more than one timetable, combine
                    if length(varargin)>1
                        %If all from wins_tt dependend prop, parse accordingly
                        if all(cellfun(@(tt) ismember('Window_Duration', ...
                            tt.Properties.VariableNames),varargin)) && ...
                            range(cellfun(@width,varargin))==0
                            
                            wins_t=table;
                            for i=1:length(varargin)
                                wins_tt=varargin{i};
                                arg=timetable2table(wins_tt);
                                arg.Properties.VariableNames{ ...
                                    strcmp( ...
                                    wins_t.Properties.VariableNames,'Time')} ...
                                    ='Start_Time';
                                
                                End_Time = seconds(1:height(wins_t))';
                                for i=1:length(End_Time)
                                    End_Time(i)= ...
                                        arg.Start_Time(i) ...
                                        +arg.Window_Duration(i);
                                end
                                arg.End_Time = End_Time;
                                arg.Window_Duration = [];
                                
                                wins_t=[wins_t;arg];
                            end
                            Windows.wins_t=wins_t; return;
                        end
                    else %Otherwise, ignore all but the first two (TODO)
                        %varargin=varargin{1:2};
                        
                    end
                    
                    %If two timetables of equal height, use as begins/ends
                    if length(varargin)==2 ... %{begintbl, endtbl}
                        && height(varargin{1})==height(varargin{2})
                    
                        start_t=timetable2table(varargin{1});
                        start_t.Properties.VariableNames= ...
                            cellfun(@(varname) strcat('Start_',varname), ...
                            start_t.Properties.VariableNames, ...
                            'UniformOutput',false);
                        
                        end_t=timetable2table(varargin{2});
                        end_t.Properties.VariableNames= ...
                            cellfun(@(varname) strcat('End_',varname), ...
                            end_t.Properties.VariableNames, ...
                            'UniformOutput',false);
                        
                        Windows.wins_t=[start_t,end_t];
                    end
                                        
                otherwise; return;
            end
        end
        
        function Windows = set.wins_t(Windows,wins_t)
            varnames = wins_t.Properties.VariableNames;
            if length(intersect( ...
                {'Start_Time','End_Time','Window_Name'},varnames))<3
                wins_t = ELF.Windows.makeWinCols(wins_t);
            end

            others = setdiff(varnames,{'Start_Time','End_Time','Window_Name'});
            others = sort(others);
            varnames = [{'Start_Time','End_Time','Window_Name'},others];
            wins_t = wins_t(:,varnames);
            
            wins_t = sortrows(wins_t,'Start_Time');
            
            Windows.wins_t=wins_t;
        end
        
        function wins_dur_a = get.wins_dur_a(Windows)
            wins_dur_a=NaT; if isempty(Windows.wins_t); return; end
            wins_dur_a= ...
                table2array(Windows.wins_t(:,{'Start_Time','End_Time'}));
        end
        
        function wins_dbl_a = get.wins_dbl_a(Windows)
            wins_dbl_a=NaN; if isempty(Windows.wins_t); return; end
            wins_dbl_a=seconds(Windows.wins_dur_a);
        end
        
        function wins_t_bare = get.wins_t_bare(Windows)
            wins_t_bare = table; if isempty(Windows.wins_t); return; end
            wins_t_bare= ...
                Windows.wins_t(:,{'Start_Time','End_Time','Window_Name'});
        end
        
        function wins_tt = get.wins_tt(Windows)
            wins_tt = timetable; if isempty(Windows.wins_t); return; end
                
            wins_tt = ...
                table2timetable(Windows.wins_t, ...
                'RowTimes',Windows.wins_t.Start_Time);
            Window_Duration = seconds(1:height(wins_tt))';
            
            for i=1:length(Window_Duration)
                Window_Duration(i)=wins_tt.End_Time(i)-wins_tt.Start_Time(i);
            end

            wins_tt.Window_Duration=Window_Duration;
            wins_tt.Start_Time=[];
            wins_tt.End_Time=[];
            
            varnames = wins_tt.Properties.VariableNames;
            others = setdiff(varnames, {'Window_Duration','Window_Name'});
            others = sort(others);
            varnames = [{'Window_Duration','Window_Name'},others];
            wins_tt = wins_tt(:,varnames);
        end
        
        function count = get.count(Windows)
            count=height(Windows.wins_t);
        end
        
        function onerow_t = get.onerow_t(Windows)
            onerow_t=table;
            for i=1:Windows.count
                currow_t=Windows.wins_t(i,:);
                winname=currow_t.Window_Name{1};
                currow_t.Window_Name=[];
                for j=1:width(currow_t)
                    currow_t.Properties.VariableNames{j} = ...
                        sprintf('%s_%s',winname, ...
                        currow_t.Properties.VariableNames{j});
                end
                onerow_t=[onerow_t,currow_t];
            end
        end
        
        Windows = discardCols(Windows,varargin) %Get rid of columns you don't want
        Windows = keepCols(Windows,varargin) %Keep only columns you want
    end
    
    methods (Static)
        wins_t = makeWinCols(tbl)
    end
end

