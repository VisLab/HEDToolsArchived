function tMap = extracttags(events, valueField)
% Extract a tagmap from the usertags in the event structure.
parseArguments();
tMap = tagMap();
positions = arrayfun(@(x) ~isempty(x.(valueField)), events);
values = {events(positions).(valueField)};
tags = {events(positions).('usertags')};
% if iscell(values)
values = cellfun(@num2str, values, 'UniformOutput', false);
% else
%     values = arrayfun(@num2str, values, 'UniformOutput', false);
% end
uniqueValues = unique(cellfun(@num2str, values, 'UniformOutput', false));
for k = 1:length(uniqueValues)
    if ~isempty(uniqueValues{k})
        theseValues = strcmpi(uniqueValues{k}, values);
        theseTags = tags(theseValues);
        myTagList = tagList(uniqueValues{k});
        if ~isempty(theseTags)
            myTagList.addString(theseTags{1});
            for j = 2:length(theseTags)
                newList = tagList(uniqueValues{k});
                newList.addString(theseTags{j});
                myTagList.intersect(newList);
            end
        end
        tMap.addValue(myTagList);
    end
end

    function p = parseArguments()
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('events', @(x) ~isempty(x) && isstruct(x));
        p.addRequired('valueField', @(x) ~isempty(x) && ischar(x));
    end % parseArguments

end % extracttags