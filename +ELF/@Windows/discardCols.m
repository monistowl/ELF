function Windows = discardCols(Windows,varargin)
%discardCols: Get rid of columns you don't want
% discardCols %Get rid of everything but begin/end/name
% discardCols('Col1name','Col2name',...) %Get rid of specific cols
%See also: keepCols, Window, makeWinCols

    if nargin<2
        Windows.wins_t=Windows.wins_t_bare;
    else
        Windows.wins_t= ...
            [Windows.wins_t_bare,Windows.wins_t(:,varargin)];
    end
end