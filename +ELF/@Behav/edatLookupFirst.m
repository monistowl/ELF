function targetval = edatLookupFirst(B,target_col,lookup_col,lookup_val)
%edatLookupFirst: dumb loop for looking up corresponding values
%   Gets the first instance of lookup_val in lookup_col, returns
%   corresponding val from target_col, NaN if not found
%   TODO Rewrite to use tables properly
    
    targetcol = B.trials.(sprintf(target_col));
    lookupcol = B.trials.(sprintf(lookup_col));
    
    for(i=1:length(lookupcol))
        if(strcmp(lookupcol{i},lookup_val))
            targetval = targetcol{i};
            return;
        end
    end
    targetval = NaN;
end

