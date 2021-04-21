function uca = nuca2uca(nuca)
%nuca2tbl: Attempt to combine non-uniform cell array of structs
%   Expects cell aray of structs of named numeric vars
%   Does NOT attempt to check types, missing replaced with NaNs

uca = [];
allvars = [];

%get all field names from all structs
for i=1:length(nuca); allvars = union(allvars,fieldnames(nuca{i})); end

%fill in missing with NaN
for i=1:length(nuca)
    missingvars = setdiff(allvars,fieldnames(nuca{i}));
    for j=1:length(missingvars); nuca{i}.(missingvars{j})=NaN; end
end

%attempt to horzcat
for i=1:length(nuca)
    uca = [uca,nuca{i}];
end

end

