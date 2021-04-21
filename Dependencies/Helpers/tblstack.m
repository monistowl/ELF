function combotable = tablestack(tables)
%tblstack: Attempt to combine non-uniform 1-row tables vertically
%   Expects cell aray of tables, outputs table
%   Does NOT attempt to check types, missing replaced with NaNs

combotable = table;
allvars = [];

%get all field names from all tables
for i=1:length(tables); allvars = union(allvars,tables{i}.Properties.VariableNames); end

%fill in missing with NaN
for i=1:length(tables)
    missingvars = setdiff(allvars,fieldnames(tables{i}));
    for j=1:length(missingvars); tables{i}.(missingvars{j})=NaN; end
end

%attempt to vertcat
for i=1:length(tables)
    combotable = [combotable;tables{i}];
end
end

