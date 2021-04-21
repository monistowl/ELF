function wins_t = windowsFromBehav(B,E,varstoget)
%% windowsFromBehav: combine event timetable with behav data matching task #s
% assigns EndTime as next event's time, for windowing
    if(nargin<3) %fetch all data from behav by default
        varstoget=B.taskevents_t.Properties.VariableNames;
    end
    
    warning('off','all');
    
    wins_t = table();
    
    event_codes = B.taskevents_t.TaskEvent;

    behav_t = B.taskevents_t(:,varstoget);
    events_tt = E.events_tt;
    
    colnames = behav_t.Properties.VariableNames;
    
    j=1;
    for i=1:length(event_codes)
        row = behav_t(i,:);

        while(event_codes(i) ~= events_tt.EventType(j))
            j=j+1;
        end
        
        %assign start/end window times to next event
        wins_t.WindowStart(i) = events_tt.Time(j);
        wins_t.WindowEnd(i) = events_tt.Time(j+1);
        wins_t.EventType(i) = event_codes(i);
        wins_t.EventName(i) = events_tt.EventName(j);
        
        %add whatever behav vars you want to the window table
        for k=1:width(row)
            wins_t.(colnames{k})(i) = row.(colnames{k});
        end

    end


end