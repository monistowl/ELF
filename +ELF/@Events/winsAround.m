function Windows = winsAround(Events,criteria,t1,t2)
%winsAround Get windows before/after events using findEvents criteria
%
% winsAround(criteria,t1) %Between event time and +t1 secs (can be negative)
% winsAround(criteria,t1,t2) %Window between event time +t1 and +t2 (ditto)
% winsAround(criteria,specifier) %'UntilNext' or 'SincePrevious' event
% winsAround(criteria1,specifier,criteria2) %As above but match next/prev
%
% All criteria follow the call procedure for ELF.Events.findEvents
%
% winsAround('Name',10) %10s windows after events matching Name
% winsAround('Name',-10) %10s leading up to same
% winsAround('Name',-10,10) %10s before and after
% winsAround('Name',10,-10) %Same
% winsAround(0,30,120) %Between 30s and 2m after acq start
% winsAround({criteria},'UntilNext') %Windows until next event
% winsAround({criteria},'SincePrevious') %Windows from previous event
% winsAround({criteria1},'UntilNext',{criteria2}) #Until next matching
%See also: findEvents, Windows
    
    if ischar(t1)
        switch t1

            case 'UntilNext'
                %{'next','Next','nextevent','NextEvent','Next_Event',...
                %  'next_event','NEXT','n','N'}
                
                %
                StartEvents=Events.findEvents(criteria);
                if isempty(StartEvents); Windows=ELF.Windows; return; end
                if nargin>3 %If there is a second set of criteria, use it
                    EndEvents=Events.findEvents(t2); % to set EndEvents
                else %Otherwise, select the next event of any kind
                    EndEvents=Events; % by setting EndEvents to *all* events
                end
                

                
                %We already know when each window starts, so set WinStart
                WinStart=StartEvents.events_tt.Time;
                
                %For each, find the next (chronologically) event in EndEvents
                WinEnd=repmat(seconds(0),length(WinStart),1); %Preallocate
                for i=1:length(WinStart) %TODO: Rewrite with rowfun
                    SingleEvent=EndEvents.firstAfter(WinStart(i));
                    if isempty(SingleEvent); Windows=ELF.Windows; return; end
                    WinEnd(i)=SingleEvent.events_tt.Time(1);
                end
                
                %Set window names
                WinName=StartEvents.events_tt.EventName;
                                
                %Construct table from window data vars
                wins_t=table(WinStart,WinEnd,WinName);
                
                %Construct Windows object from table
                Windows=ELF.Windows(wins_t); return;
                
            case 'SincePrevious'
                %{'prev','Prev','previous','Previous','prevevent',...
                % 'previousevent','PrevEvent','PreviousEvent',...
                % 'Previous_Event','previous_event','PREV',...
                % 'PREVIOUS','p','P'}
                StartEvents=Events.findEvents(criteria);
                if nargin>3
                    EndEvents=Events.findEvents(t2);
                else
                    EndEvents=Events;
                end
                
                WinStart=StartEvents.events_tt.Time;
                WinEnd=repmat(seconds(0),length(WinStart),1);
                for i=1:length(WinStart)
                    SingleEvent=EndEvents.lastBefore(WinStart(i));
                    WinEnd(i)=SingleEvent.Time;
                end
                WinName=StartEvents.events_tt.EventName;
                wins_t=table(WinStart,WinEnd,WinName);

                Windows=ELF.Windows(wins_t); return;

            otherwise
                Windows=ELF.Windows; return;
        end
    end


    %Convert to durations
    if ~isduration(t1); t1=seconds(t1); end
    if nargin>3 && ~isduration(t2); t2=seconds(t2); end

    %Find events, make a copy
    if ischar(criteria) || isnumeric(criteria); criteria={criteria}; end
    StartEvents=Events.findEvents(criteria{:});
    EndEvents=StartEvents;

    if nargin<4 %With one input, add/subtract to get window
        if t1==seconds(0); Windows=ELF.Windows; return; end
        if t1<seconds(0)
            StartEvents=StartEvents.adjustTimes(-t1);
        else
            EndEvents=EndEvents.adjustTimes(t1);
        end
    else %With two inputs, do both
        relwinstart=min(t1,t2); relwinend=max(t1,t2);
        StartEvents = StartEvents.adjustTimes(relwinstart);
        EndEvents = EndEvents.adjustTimes(relwinend);
    end
    
    if isempty(StartEvents) || isempty(EndEvents); Windows=ELF.Windows; return; end
    
    WinStart=StartEvents.events_tt.Time;
    WinEnd=EndEvents.events_tt.Time;
    WinName=StartEvents.events_tt.EventName;
    wins_t=table(WinStart,WinEnd,WinName);
    
    Windows=ELF.Windows(wins_t);
end