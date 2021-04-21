function SingleEvent = lastBefore(Events,t,varargin)
%lastBefore Find last findEvents match before t seconds
%See also: findEvents, winsAround
    
    SingleEvent=ELF.Events(Events.events_tt);
    
    if nargin>2 %If passed criteria, use findEvents to pare down
        SingleEvent=SingleEvent.findEvents(varargin{:});
    end
    
    SingleEvent=SingleEvent.eventsBefore(t);
    SingleEvent=ELF.Events(SingleEvent.events_tt(end,:));
    
end