function flat_t = flattenT(stacked_t,prefix)
%flattenT: put everything in one row
%   Prefixes duplicate varnames
if nargin<2
    prefix = 'row';
end
flat_t = table();
colnames = stacked_t.Properties.VariableNames;
for i=1:height(stacked_t)
    for j=1:length(colnames)
        flat_t.(sprintf('%s%d_%s',prefix,i,colnames{j})) = stacked_t.(colnames{j})(i);
    end
end
end

