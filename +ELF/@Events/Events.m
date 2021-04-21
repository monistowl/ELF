classdef Events < ELF.ELF_HandleObj
%Events Data from eprime event.txt log
%   Stores data from an event file, with functions for retrieval and
%   windowing. Timestamps are normalized to seconds since acquisition
%   start.

    properties
        events_tt = timetable;
    end
    
    properties (Dependent)
        event_names
    end
    
    methods
        %% CONSTRUCTOR
        function Events = Events(sourcepath,varargin)
        %Events Initialize Events object
        % ELF.Events() %Create a totally empty object
        % ELF.Events(timetable) % Set timetable directly
        % ELF.Events(sourcepath) %Reads file
        % ELF.Events(sourcepath,'PreprocNow',false) %Only set path
        % ELF.Events(Events) %Open existing Events object
        % ELF.Events(file.mat) %Load from file 
        %See also: preproc, importFromPath, save, open, ELF_HandleObj
        
            if nargin==0; sourcepath=''; end 
            
            events_tt=timetable;
            if isa(sourcepath,'timetable')
                events_tt=sourcepath; sourcepath='';
            end
            
            Events@ELF.ELF_HandleObj(sourcepath,varargin{:}); 
            
            if ~isempty(events_tt); Events.events_tt=events_tt; end
        end
        
        %% PREPROCESSING
        
        function preproc(Events)
        %preproc Import events and transform as needed
        %
        %See also: ELF_HandleObj
        
            try
                Events.events_tt = ...
                    ELF.Events.readEprimeEvents(Events.sourcepath);
            catch ME
                %Events.addProblem(ME);
            end
        end
        
        function AdjustedEvents = adjustTimes(Events,t)
        %adjustTimes Adds or subtracts from event timetamps
        % Events.adjustTimes(t) %Adds t seconds to each (can be negative)
        %  (AdjustedEvents does not preserve sourcepath/savepath)
        % Events with negative timestamps (before acq start) will be trimmed
        
            if isempty(Events); AdjustedEvents=ELF.Events; return; end
            if ~isduration(t); t=seconds(t); end
            new_events_tt = Events.events_tt;
            new_events_tt.Time = new_events_tt.Time + t;
            new_events_tt(new_events_tt.Time<seconds(0),:)=[]; %Trim
            AdjustedEvents=ELF.Events(new_events_tt);
        end
        
        %% OPERATOR OVERLOADS
        
        function CombinedEvents = plus(Events1,Events2)
        %plus Combine two sets of events
        % CombinedEvents = Events1 + Events2 %Combine events, ignore paths
        %See also: minus, or, and
            
            CombinedEvents = ELF.Events;
                        
            %Note that new CombinedEvents does not inherit a sourcepath/savepath
            if isempty(Events1)
                CombinedEvents=ELF.Events(Events2.events_tt); return;
            end
            if isempty(Events2)
                CombinedEvents=ELF.Events(Events1.events_tt); return;
            end
            CombinedEvents.events_tt = [Events1.events_tt; Events2.events_tt];
        end
        
        function TrimmedEvents = minus(Events1,Events2)
        %minus Deletes identical events
        % TrimmedEvents = Events1 - Events2 %Combine events, ignore paths 
        %  (TrimmedEvents does not inherit sourcepath/savepath)
        %See also: plus, or, and
            
            TrimmedEvents = ELF.Events(setdiff( ...
                Events1.events_tt, Events2.events_tt));
        end
        
        function CombinedEvents = or(Events1,Events2)
        %or Combines events (same as +)
        % CombinedEvents = Events1 | Events2
        %  (CombinedEvents does not inherit sourcepath/savepath)
        %See also: and, plus, minus
            
            CombinedEvents = Events1 + Events2;
        end
        
        function TrimmedEvents = and(Events1,Events2)
        %and Events present in BOTH Events1 and Events2
        % (inverse of Events1 - Events2)
        % TrimmedEvents = Events1 & Events2
        %See also: or, plus, minus
            
            if isa(Events2,'cell') %If criteria, try findEvents
                Events2=Events1.findEvents(Events2);
            end
            
            if isa(Events2,'timetable') %If bare timetable, make new Events
                Events2=ELF.Events(Events2);
            end
            
            %Note that new TrimmedEvents does not inherit a sourcepath/savepath
            TrimmedEvents = ELF.Events(intersect( ...
                Events1.events_tt, Events2.events_tt));
        end
        
        function iseq = eq(Events1, Events2)
        %isequal Return true if timetables are identical (ignoring paths)
            iseq=isempty(Events1-Events2) && isempty(Events2-Events1);
        end
        
        function isem = isempty(Events)
        %isempty Return true if no events in timetable (ignoring paths)
            isem=isempty(Events.events_tt);
        end
        
        
        %% SUBTABLE METHODS
        
        %Search for events in events_tt
        MatchEvents = findEvents(Events,varargin)
                
        %Find first match for each name/number in a list
        MatchEvents = firstMatches(Events,varargin)
        
        function MatchEvents = eventsNamedExactly(Events, name)
        %eventsNamedExactly Events exactly matching name (events_tt.EventName)
        %
        %See also: eventsNamed, eventsNumbered, findEvents
            
            MatchEvents = ELF.Events( ...
                Events.events_tt(Events.events_tt.EventName == name,:));
        end
        
        function MatchEvents = eventsNumbered(Events, eventnums)
        %eventsNumbered Events matching event number (events_tt.EventType)
        % Events.eventsNumbered(10) %Return only events numbered 10
        % Events.eventsNumbered([10,11,12]) %Return 10s, 11s, and 12s
        %See also: eventsNamed, findEvents
        
            MatchEvents=ELF.Events;
            for i=1:length(eventnums)
                MatchEvents = MatchEvents + ELF.Events( ...
                    Events.events_tt( ...
                    Events.events_tt.EventType == eventnums(i)));
            end
        end
        
        function MatchEvents = eventsNamed(Events, varargin)
        %eventsNamed Events whose names match a regular expression
        % eventsNamed('Neutral') %Matches 'Neutral', 'Neutral47', 'neutral', &c.
        % eventsNamed('Neut','Pow') %Events matching either string
        %See also: eventsNamedExactly, eventsNumbered, findEvents
        
            MatchEvents=ELF.Events;
            if isempty(varargin); return; end
            
            if length(varargin) == 1 %If one arg, find matches with regexpi
                exp=varargin{1};
                matches = [];
                for i=1:height(Events.events_tt)
                    if ~isempty(regexpi(Events.events_tt.EventName{i},exp))
                        matches = [matches,i];
                    end
                end
                MatchEvents=ELF.Events(Events.events_tt(matches,:));
            else %If there are still args left, recurse
                MatchEvents= ...
                    Events.eventsNamed(varargin{1}) + ...
                    Events.eventsNamed(varargin{2:end});
            end
        end
        
%         function varargout = subsref(Events,s)
%             %TODO
%         end
        
        %% ROW FUNCTIONS
        
        SingleEvent = firstMatch(Events,varargin) %Find first match to criteria
        SingleEvent = lastMatch(Events,varargin) %Find last match to criteria
        SingleEvent = firstAfter(Events,t,varargin) %Find first event after criteria
        SingleEvent = lastBefore(Events,t,varargin) %Find last event before criteria
        
        
        %% WINDOW FUNCTIONS
        
        [Windows,wins_a] = winsBetween(Events, criteria1, criteria2)
        [Windows,wins_a] = winsAround(Events,criteria,t1,t2)
        
    end
    
    methods
        %% SETTERS
        function Events = set.events_tt(Events,new_tt)
            Events.events_tt=sortrows(new_tt);
        end
        
        %% GETTERS
        
        function event_names = get.event_names(Events)
            event_names = string(Events.events_tt.EventName);
        end
    end
    
    methods (Static)
        events_tt = readEprimeEvents(path)
    end
end

