% Converts a cellstr into a str
function str = cellstr2str(value)
tmp = cellfun(@(x) ['''' x ''''], value, 'UniformOutput', false);
str = ['{' strjoin(tmp, ',') '}'];
end % cellstr2str