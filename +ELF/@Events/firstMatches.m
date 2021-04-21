function TrimmedEvents = firstMatches(Events, varargin)
%findFirst Find first match for each input
% findFirst('Neu','Pow','Thr') %Just first match for each name

    TrimmedEvents=ELF.Events;
    if isempty(varargin); return; end
    for i=1:length(varargin)
        TrimmedEvents=TrimmedEvents+Events.firstMatch(varargin{i});
    end

end

