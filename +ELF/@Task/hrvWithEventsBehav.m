        function hrv_with_events_behav_tt = hrvWithEventsBehav(B,E,P,toget)
            if(nargin<4)
                toget.behav = B.taskevents_t.Properties.VariableNames;
                %toget.events = E.
                toget.hrv = P.hrv_tt.Properties.VariableNames;
            end            
            
            events_with_behav_tt = Task.eventsWithBehav(B,E,toget.behav);
            
            hrv_with_events_behav_tt = synchronize( ... 
                P.hrv_tt, events_with_behav_tt);
            
            %interpolate
            %cols = events_with_behav_tt.Properties.VariableNames;
            cols = hrv_with_events_behav_tt.Properties.VariableNames;
            for i=1:length(cols)
                hrv_with_events_behav_tt.(cols{i}) = ...
                    fillmissing(hrv_with_events_behav_tt.(cols{i}),'previous');
            end
            
        end