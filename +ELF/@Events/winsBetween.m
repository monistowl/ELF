function Windows = winsBetween(Events,criteria1,criteria2)
%winsBetween Windows between events matching criteria1 and criteria2
% Events.winsBetween(Events,criteria1,criteria2)
%See also: winsAround
    if isempty(Events); Windows=ELF.Windows; return; end
    Windows=Events.winsAround(criteria1,'UntilNext',criteria2);

end

