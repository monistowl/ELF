function trimmed_t = rmMissingCols(t)
%rmMissingCols: remove columns of all-missing data from table
%   Detailed explanation goes here
trimmed_t = t;
for i=1:length(t.Properties.VariableNames)
    if all(ismissing(trimmed_t.(t.Properties.VariableNames{i})))
        trimmed_t.(t.Properties.VariableNames{i}) = [];
    end
end

end

