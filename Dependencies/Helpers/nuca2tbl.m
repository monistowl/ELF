function tbl = nuca2tbl(nuca)
%nuca2tbl: Attempt to combine non-uniform cell array of structs into a table
%   Expects cell aray of structs of named numeric vars
%   Does NOT attempt to check types, missing replaced with NaNs

tbl = struct2table(nuca2uca(nuca));
end

