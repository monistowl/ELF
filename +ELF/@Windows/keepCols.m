function Windows = keepCols(Windows,varargin)
%keepCols: Get rid of everything but columns you want
% keepCols %Keep everything, return unmodified
% keepCols('Col1name','Col2name',...) %Get rid all but named cols
%                                     %AND start/end/name cols
%See also: keepCols, Window, makeWinCols

    if nargin<2; return; end
    Windows.wins_t=Windows.wins_t(:,varargin);
end