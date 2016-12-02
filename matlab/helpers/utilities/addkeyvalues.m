% Get key value arguments by the keys 
function  z = addkeyvalues(keyvalues, varargin)
keyPos = 1:2:length(keyvalues)-1;
keys = varargin(keyPos);
a = find(cellfun(@(x) matchStr(x, keys), varargin));
b = a + 1;
values = varargin(b);
z =  varargin;
z(b) = deal 
keyvalues = varargin(reshape([a;b], 1, []));
z =1;

    function match = matchStr(value, values)
        % Find string match in cell array
        match = false;
        if ischar(value)
           match = any(strcmpi(values, value)); 
        end       
    end % matchStr

end % getkeyvalue

