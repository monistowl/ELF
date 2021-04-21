function is_func = isfunc(input)
%isfuncs True if input is a function handle
% isfuncs(@mean) %true
%See also: 

is_func=isa(input,'function_handle');
end

