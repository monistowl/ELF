function win_stats_t = hrvWinStats(Physio,Windows,varargin)
%hrvWinStats Apply (flattening) window function to hrv timetable
% (Uses @mean by default, but you can pass any function, even anonymous)
% 
% hrvWinStats() %Mean HRV data for whole recording
% hrvWinStats(Windows) %Mean HRV data for a set of windows
% hrvWinStats(Windows,'WinFunc',@max) %Find max instead of mean
% hrvWinStats(Windows,'WinVars',{'var1','var2'...}) %Only specific vars
% hrvWinStats(Windows,'KeepWinCols',true) %Keep End_EventType &c.
%
%See also: Windows, Events, Physio, winsAround, winsBetween, findEvents
    
    win_stats_t = table; %Where results will go
    
    %Set defaults
    defaultWindow = ELF.Windows(1,seconds(Physio.hrv_tt.Time(end)), ...
        'WholeRecording');
    defaultWinFunc = @mean; %Use mean unless e.g. @max specified
    defaultWinVars = Physio.hrv_tt.Properties.VariableNames; %Use all
    defaultKeepWinCols = false;
    
    p=inputParser;
    p.KeepUnmatched = true;
    p.StructExpand = false;

    addOptional(p,'Windows',defaultWindow);
    addParameter(p,'WinFunc',defaultWinFunc);
    addParameter(p,'WinVars',defaultWinVars);
    addParameter(p,'KeepWinCols',defaultKeepWinCols);
    parse(p,Windows,varargin{:});
    
    Windows = p.Results.Windows;
    WinVars = p.Results.WinVars;
    WinFunc = p.Results.WinFunc;
    KeepWinCols = p.Results.KeepWinCols;
    
%     %Old, bad way to parse input arguments (broken)
%     if nargin==1 %If no windows defined, use all available
%         Windows=ELF.Windows(1,seconds(Physio.hrv_tt.Time(end)), ...
%             'WholeRecording');
%         WinVars=Physio.hrv_tt.Properties.VariableNames;
%         WinFunc=@mean;
%     end
%     if nargin>1; Windows=ELF.Windows(Windows); end %If window args, parse
%     if nargin<4 %If only passed a func or a set of vars to get
%         if isa(WinVars,'function_handle') %If only passed func, use all vars
%             WinFunc=WinVars;
%             WinVars=Physio.hrv_tt.Properties.VariableNames;
%         else
%             WinFunc=@mean; %If passed no func, use mean
%             WinVars=intersect(WinVars, Physio.hrv_tt.Properties.VariableNames);
%         end
%     end

    hrv_dtt = retime(Physio.hrv_tt(:,WinVars), 'regular', 'pchip', ...
              'TimeStep', seconds(1/Physio.Fs));
    
    %Iterate through windows, getting HRV stats for each and compounding
    for i=1:Windows.count %TODO: Rewrite with rowfun
        tr=timerange(Windows.wins_t.WinStart(i),Windows.wins_t.WinEnd(i));
        slice=timetable2table(hrv_dtt(tr,:)); slice.Time=[];
        row_t=varfun(WinFunc,slice);
        for j=1:length(row_t.Properties.VariableNames)
            
            %matlab stupidly switches var types if only one row in table
            if ischar(Windows.wins_t.WinName)
                NewWinName = Windows.wins_t.WinName;
            else
                NewWinName = Windows.wins_t.WinName{i};
            end
            if ischar(row_t.Properties.VariableNames)
                NewVarName = row_t.Properties.VariableNames;
            else
                NewVarName = row_t.Properties.VariableNames{j};
            end
            %damn you, matlab
            
            row_t.Properties.VariableNames{j} = ...
                sprintf('%s_%s', ...
                NewWinName, ...
                NewVarName);
        end
        if ~isempty(intersect(row_t.Properties.VariableNames,win_stats_t.Properties.VariableNames))
            for j=1:length(row_t.Properties.VariableNames)
            row_t.Properties.VariableNames{j} = ...
                sprintf('%s_Copy', row_t.Properties.VariableNames{j});
            end
        end
        try 
            win_stats_t=[win_stats_t,row_t];
        catch
            disp('asdf');
        end
    end
    
end