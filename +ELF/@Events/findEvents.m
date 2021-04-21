function MatchEvents = findEvents(Events,varargin)
%findEvents Return Events matching (any) criteria
% 
% findEvents(eventnum) %Same as eventsNumbered
% findEvents(eventname) %Same as eventsNamed
% findEvents(Events) %Same as & (only events that also exist in input)
% findEvents(criteria1, criteria2 ..) %Set search parameters
%  %Uses findEvents(criteria1) | findEvents(criteria2)
%  e.g.  findEvents('End', 11) %Events named 'End' OR numbered 11
%        findEvents([35:37]) %Events numbered 35, 36, or 37
%        findEvents('Neu','Pow','Thr') %Events matching 'Neu' OR 'Pow' OR 'Thr'
%
% To get narrower criteria, use &:
%  e.g.  findEvents('Neu') & findEvents(37) %Events matching 'Neu' AND 37
%
%
%See also: eventsNumbered, eventsNamed, eventsBetweenTimes, or, and

    MatchEvents = ELF.Events;
    
    if length(varargin)==1 %If fed only one arg, search based on type
        arg = varargin{1};
        if isnumeric(arg)
            MatchEvents = MatchEvents + Events.eventsNumbered(arg); return;
        end
        if ischar(arg) || isstring(arg) || iscellstr(arg)
            MatchEvents = MatchEvents + Events.eventsNamed(arg); return;
        end
        if isa(arg,'ELF.Events')
            MatchEvents = MatchEvents + (Events & arg);
        end
        
        return; %Return empty table
        %error('Events:BadSearchParams','Invalid search parameters!');
    else %If there are still args left, call self recursively
        MatchEvents= ...
            Events.findEvents(varargin{1}) + ...
            Events.findEvents(varargin{2:end});
    end
end