function myMap = addListToMap(myMap, list)
% Recursively adds tag list to Map
for a = 1:length(list)
    if iscell(list{a})
        myMap = addListToMap(myMap, list{a});
    else
        myMap = addValue(myMap, list{a});
    end
end

    function myMap = addValue(myMap, value)
        value = strtrim(value);
        itemKey = lower(value);  % Key is lower case
        if ~myMap.isKey(itemKey) && ~isempty(itemKey)
            myMap(itemKey) = value;
        end
    end
end

