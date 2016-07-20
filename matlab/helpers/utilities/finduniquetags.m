function uniquetags = finduniquetags(tags)
uniquetags = getUniqueTags(tags);

    function uniquetags = getUniqueTags(tags)
        uniquetags = {};
        numEvents = length(tags);
        for a = 1:numEvents
            uniquetags = union(uniquetags, formatTags(tags{a}));
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