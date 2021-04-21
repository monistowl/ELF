function wins_t = makeWinCols(tbl)
%makeStartEndCols Search for event begin/end/name cols, rename to fit
% Guarantees output has all three cols or is empty table
%See also: Windows, Events
    wins_t=table;

    if ~ismember('Start_Time',tbl.Properties.VariableNames)
        for i=1:width(tbl)
            if ~isempty( ...
                strcmpi(tbl.Properties.VariableNames{i}, 'start')) ...
                || ~isempty( ...
                strcmpi(tbl.Properties.VariableNames{i}, 'begin'))
                tbl.Properties.VariableNames{i}='Start_Time'; break;
            end
            if i>=width(tbl); return; end
        end
    end

    if ~ismember('End_Time',tbl.Properties.VariableNames)
        for i=1:width(tbl)
            if ~isempty( ...
                strcmpi(tbl.Properties.VariableNames{i}, 'end')) ...
                || ~isempty( ...
                strcmpi(tbl.Properties.VariableNames{i}, 'finish'))
                tbl.Properties.VariableNames{i}='End_Time'; break;
            end
            if i>=width(tbl); return; end
        end
    end

    if ismember('Window_Name',tbl.Properties.VariableNames); ...
        wins_t=tbl; return; end

    DefaultWindowNames=cell(height(tbl),1);
    for i=1:length(DefaultWindowNames)
        DefaultWindowNames{i}=sprintf('Window_%d',i);
    end

    for i=1:width(tbl) %If there's already a column of names, use it
        if ~isempty(regexpi(tbl.Properties.VariableNames{i}, 'name')) ...
            || ~isempty(regexpi(tbl.Properties.VariableNames{i}, 'window'))
            tbl.Window_Name=tbl{:,i};
            for j=1:length(tbl.Window_Name) %Suffix defaults, to avoid dupes
                tbl.Window_Name{j}= ...
                    sprintf('%s_%s',DefaultWindowNames{j},tbl.Window_Name{j});
            end
            wins_t=tbl; return;
        end
    end


    tbl.Window_Name=DefaultWindowNames;

    wins_t=tbl;
end