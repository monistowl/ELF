function is_bool = isbool(input)
%isbool False if input would throw error if used as boolean
% (True for anything that *can be interpreted* as true or false)
% isbool(true) %true
% isbool(0) %true
% isbool(15) %true
% isbool({1, 5}) %false

is_bool = input==false || input==true;

end

