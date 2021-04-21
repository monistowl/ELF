function stats = hrvWinStatsStruct(Physio,window_start,window_end,vars,func)
%hrvWinStats Apply (flattening) window function to hrv timetable
% (Uses @mean by default, but you can pass any function, even anonymous)
% 
% hrvWinStats(window_start,window_end) %Mean HRV data for window
% hrvWinStats(window_start,window_end,vars) %Grab specific vars
%                                           % {'var1','var2'...}
% hrvWinStats(window_start,window_end,vars,func) %Custom function
%                                                % e.g. @max, @(P) ...
%See also: Event

    if nargin<5; func=@mean; end
    if nargin<4; vars=Physio.hrv_vars; end

    %init empty table to return if there are errors
    stats = struct;
    for i=1:length(vars); stats.(vars{i})=NaN; end
    if ~Physio.has_hrv; return; end


    try
        hrv_win = hrvWindow(Physio,window_start,window_end,vars)
        stats = table2struct(varfun(func,t));
    catch ME
        Physio.addProblem(ME)
    end
end

function hrv_win = hrvWindow(Physio,window_start,window_end,vars)
%hrvWindow: HRV stats window helper using hrv_tt
%See also: hrvWinStats

    if nargin<4; vars=Physio.hrv_vars; end

    %if no HRV, calculate it
    if ~Physio.has_hrv; Physio.hrvFromIbis; end

    %if only passed 'varname', make {'varname'}
    if ~iscellstr(vars); vars=cellstr(vars); end

    %init timetable with NaT, NaNs
    hrv_win = timetable;
    for i=1:length(vars); hrv_win.(vars{i})=NaN; end

    try
        hrv_win = retime(Physio.hrv_tt(:,vars), ...
            'regular', 'pchip', ...
            'TimeStep', seconds(1/Physio.Fs));
        hrv_win = sliceTT(hrv_win,window_start,window_end);
    catch ME
        Physio.addProblem(ME);           
    end
    
    hrv_win = timetable2table(hrv_win); hrv.Time=[];
end