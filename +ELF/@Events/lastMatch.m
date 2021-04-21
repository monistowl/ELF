function row_tt = lastMatch(Events,criteria)
%lastMatch Find last match to criteria (using findEvents criteria)
%See also: findEvents, Events
    match_tt=Events.findEvents(criteria);
    row_tt=match_tt(end,:);
end