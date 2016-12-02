% Get key value arguments by the keys 
function  keyvalues = updatekeyvalue(key, value, varargin)
a = find(cellfun(@(x) matchStr(x, key), varargin));
b = a + 1;
varargin{b} = value;
keyvalues = varargin;

    function match = matchStr(key1, key2)
        % Find string match in cell array
        match = false;
        if ischar(key1)
           match = strcmpi(key1, key2); 
        end       
    end % matchStr

end % getkeyvalue

