function sig = findChannel(P, name)
    %FIND_CHANNEL Return first raw column matching name
    %   Will search for any match --
    %   e.g. 'ECG' will fetch a channel named 'Ch_1 ECG'

    %find position of FIRST match in channel name array
    for i=1:length(P.raw_data_tt.Properties.VariableNames)
        if(strfind(P.raw_data_tt.Properties.VariableNames{i},name))
            sig = P.raw_data_tt{:,i};
            return;
        end
    end
    P.addProblem(sprintf('Could not find channel matching %s!',name));
end