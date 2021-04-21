function ts_win = slice_ts(ts,[slice_start,slice_end])
%SLICE_TS Returns a subset of a simple time series
%   ts : a two-column array with timestamps in the first col
%   [slice_start, slice_end] : window in same units as timestamps

%todo: make less kludgy, add bounds checking
%slice = ts((ts >= slice_start & ts < slice_end),:);
ts_win=ts;
for i=1:length(ts_win)
    if((ts_win(i,1) < slice_start) || (ts_win(i,1) <= slice_end))
        ts_win(i,:) = [NaN,NaN];
    end
end
ts_win = rmmissing(ts_win);
end

