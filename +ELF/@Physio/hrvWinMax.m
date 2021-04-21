function win_max_t = hrvWinMax(Physio,Windows,WinVars)
%hrvWinMax Get times and values of max of an HRV stat within windows
% Physio.hrvWinMax %Max vals/times for all HRV vars for whole recording
% Physio.hrvWinMax(Windows) %Max vals/times within windows (see whichWindow)
% Physio.hrvWinMax(Windows,WinVars) %Only fetch specified HRV vars
%See also: hrvWinMin, Physio, Windows, whichWindow
    
    win_max_t=table;
    if nargin==0; return; end
    if nargin==1 %If no windows defined, use all available
        Windows=ELF.Windows(1,seconds(Physio.hrv_tt.Time(end)), ...
            'WholeRecording');
        WinVars=Physio.hrv_tt.Properties.VariableNames;
    end
    if nargin>1; Windows=ELF.Windows(Windows); end %If window args, parse
    win_max_t = table;
    if nargin<3; WinVars=Physio.hrv_tt.Properties.VariableNames; end
    
    
    hrv_dtt = retime(Physio.hrv_tt(:,WinVars), 'regular', 'pchip', ...
        'TimeStep', seconds(1/Physio.Fs));
    if ischar(WinVars); WinVars={WinVars}; end  
          
    %Iterate through windows, getting HRV stats for each and compounding
    for i=1:Windows.count %TODO: Rewrite with rowfun
        tr=timerange(Windows.wins_t.WinStart(i),Windows.wins_t.WinEnd(i));
        slice=timetable2table(hrv_dtt(tr,:)); slice.Time=[];
        
        row_t=table;
        for j=1:length(WinVars)
            [row_t.(sprintf( ...
                '%s%sMaxVal',Windows.wins_t.WinName{i},WinVars{j})), idx] = ...
                max(slice.(WinVars{j}));
            row_t.(sprintf( ...
                '%s%sMaxTime',Windows.wins_t.WinName{i},WinVars{j})) = ...
                seconds(Windows.wins_t.WinStart(i)) + idx/Physio.Fs;
        end

        win_max_t=[win_max_t,row_t];
    end
end

