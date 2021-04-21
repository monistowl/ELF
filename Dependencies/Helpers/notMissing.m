function trimmed_t = notMissing(t,colname)
%notMissing: Table with only those rows where t.(colname) is not missing
    % also removes any columns where all data is missing
trimmed_t = t(~ismissing(t.(colname)),:);
trimmed_t = rmMissingCols(trimmed_t);
end

