function SingleEvent = firstMatch(Events,varargin)
%firstMatch Find first match to criteria (using findEvents criteria)
%See also: findEvents, Events
    AllMatches=Events.findEvents(varargin{:});
    if height(AllMatches.events_tt) > 0
        SingleEvent=ELF.Events(AllMatches.events_tt( ...
            height(AllMatches.events_tt),:));
    else
        SingleEvent=ELF.Events;
    end
end