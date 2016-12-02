% Get key value arguments by the keys 
function  [keyvalues, values] = getkeyvalue(keys, varargin)
if ischar(keys)
    keys = {keys};
end
a = find(cellfun(@(x) matchStr(x, keys), varargin));
b = a + 1;
keyvalues = varargin(reshape([a;b], 1, []));
values = varargin(b);

    function match = matchStr(value, values)
        % Find string match in cell array
        match = false;
        if ischar(value)
           match = any(strcmpi(values, value)); 
        end       
    end % matchStr

end % getkeyvalue

