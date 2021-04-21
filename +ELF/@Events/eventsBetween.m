function TrimmedEvents = eventsBetween(Events,t1,t2)
%Get all events between t1 and t2 (exclusive)
    winstart=min(t1,t2);
    winend=max(t1,t2);
    TrimmedEvents=Events.eventsAfter(winstart)+Events.eventsBefore(winend);
end