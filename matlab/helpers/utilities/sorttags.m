function [ output_args ] = sorttags(tags)
tagList = vTagList.deStringify(tags);
groupPos = cellfun(@iscellstr, tagList);
groupTags = tagList(groupPos);
eventTags = tagList(~groupPos);
sortedEventTags = {};
index = 1;
[found, pos] = findCategory(tags);
if found
    numFound = sum(pos);
    sortedEventTags(index:numFound) = eventTags(pos);
    index = index + numFound;
end
[found, pos] = findLabel(tags);
if found
    sortedEventTags(index) = eventTags(pos);
    index = index + 1;
end
[found, pos] = findLongname(tags);
if found
    sortedEventTags(index) = eventTags(pos);
    index = index + 1;
end
[found, pos] = findDescription(tags);
if found
    sortedEventTags(index) = eventTags(pos);
    index = index + 1;
end



    function [found, pos] = findCategory(tags)
        search = 'Event/Category';
        pos = strncmpi(tags, search, length(search));
        found = any(pos);
    end

    function [found, pos] = findDescription(tags)
        search = 'Event/Description';
        pos = strncmpi(tags, search, length(search));
        found = any(pos);
    end

    function [found, pos] = findLabel(tags)
        search = 'Event/Label';
        pos = strncmpi(tags, search, length(search));
        found = any(pos);
    end

    function [found, pos] = findLongname(tags)
        search = 'Event/Long name';
        pos = strncmpi(tags, search, length(search));
        found = any(pos);
    end

end

