% Converts the key/value optional arguments to a string
function str = keyvalue2str(varargin)
numArgs = length(varargin);
if numArgs < 1
    str = '';
    return;
end
str = getKeyValue(1, varargin{:});
for a = 3:2:numArgs
    str = [str ', ' getKeyValue(a, varargin{:})]; %#ok<AGROW>
end

    function str = getKeyValue(index, varargin)
        % Append argument to string
        name = ['''' varargin{index} ''''];
        if ischar(varargin{index+1})
            value = ['''' varargin{index+1} ''''];
        elseif islogical(varargin{index+1})
            value = logical2str(varargin{index+1});
        elseif iscellstr(varargin{index+1})
            value = cellstr2str(varargin{index+1});
        else
            value = vector2str(varargin{index+1});
        end
        str = [name ', ' value];
    end

end % keyvalue2str