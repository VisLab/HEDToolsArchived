function uniquetags = finduniquetags(events)
% tagMap = containers.Map('KeyType','char','ValueType','char');
uniquetags = {};
getUniqueTags();

    function getUniqueTags()
        numEvents = length(events);
        for a = 1:numEvents
            uniquetags = union(uniquetags, formatTags(events(a).usertags));
        end
    end

    function tags = formatTags(tags)
        % Format the tags and puts them in a cellstr if they are in a
        % string
        tags = tagList.deStringify(tags);
        if ~iscellstr(tags)
            tags = [tags{:}];
        end
        tags =  tagList.getUnsortedCanonical(tags);
    end % formatTags
end