function TrimmedEvents = eventsBefore(Events,t)
%eventsBefore Get only events ocurring before time t

if ~isduration(t); t=seconds(t); end

TrimmedEvents=ELF.Events( ...
    Events.events_tt(Events.events_tt.Time<t,:));
end

