function tt_slice = sliceTT(tt, window_start, window_end)
%sliceTT: Convenience function for grabbing a subset of a timetable
%   Returns all tt rows between window_start and window_end durations
%   sliceTT(tt,win) expects win = [window_start, window_end]
if nargin<3
    window_end = window_start(2);
    window_start = window_start(1);
end

%if passed non-duration, convert to seconds
if ~isduration(window_start)
    window_start = seconds(window_start);
end
if ~isduration(window_end)
    window_end = seconds(window_end);
end

tt_slice = tt(tt.Time >= window_start & tt.Time < window_end,:);

end