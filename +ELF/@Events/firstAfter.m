function SingleEvent = firstAfter(Events,t,varargin)
%firstAfter Find first findEvents match after t seconds
% Return empty timetable if no match found.
%See also: findEvents, winsAround
    
    SingleEvent=table;
    if isempty(Events); return; end

    SingleEvent=ELF.Events(Events.events_tt);
    
    if nargin>2 %If passed criteria, use findEvents to pare down
        SingleEvent=SingleEvent.findEvents(varargin{:});
    end
    
    SingleEvent=Events.eventsAfter(t);
    if isempty(SingleEvent)
        SingleEvent=table; return;
    else
        SingleEvent=ELF.Events(SingleEvent.events_tt(1,:));
    end
    
end