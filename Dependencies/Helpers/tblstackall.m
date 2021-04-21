function combotable = tblstackall(tct)
%tblstackall Attempt to vertcat all vars in a table of cells of tables
%See also: tblstack
combotable = table;
names = tct.Properties.VariableNames;
for i=1:length(names)
    combotable = [combotable, tblstack(tct.(names{i}))];
end
end

