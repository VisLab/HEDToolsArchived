function [errors, errorTags] = checkunique(Maps, original, canonical)
% Checks to see if a row of tags contain two or more tags that are
% descendants of a unique tag
errors = '';
errorTags = {};
uniqueTags = Maps.unique.values();
[originalEventTags, canonicalEventTags] = ...
    getEventTags(original, canonical);
[originalGroupTags, canonicalGroupTags] = ...
    getGroupTags(original, canonical);
checkUniqueTags(originalEventTags, canonicalEventTags, false);
for a = 1:length(originalGroupTags)
    checkUniqueTags(originalGroupTags{a}, canonicalGroupTags{a}, true);
end

    function checkUniqueTags(original, canonical, isGroup)
        % Looks for two or more tags that are descendants of a unique tag
        for uniqueTagsIndex = 1:length(uniqueTags)
            foundIndexes = ~cellfun(@isempty, ...
                regexpi(original,uniqueTags{uniqueTagsIndex}));
            if sum(foundIndexes) > 1
                foundIndexes = find(foundIndexes);
                generateErrors(uniqueTagsIndex, foundIndexes, ...
                    canonical, isGroup);
            end
        end
    end % findUniqueTags

    function generateErrors(uniqueTagsIndex, foundIndexes, canonical, ...
            isGroup)
        % Generates a unique tag error if two or more tags are descendants
        % of a unique tag
        for foundIndex = 1:length(foundIndexes)
            tagString = canonical{foundIndexes(foundIndex)};
            if isGroup
                tagString = [canonical{foundIndexes(foundIndex)}, ...
                    ' in group (' ,...
                    tagList.stringifyElement(canonical),')'];
            end
            errors = [errors, generateerror('unique', '', ...
                tagString, uniqueTags{uniqueTagsIndex})];     %#ok<AGROW>
            errorTags{end+1} = uniqueTags{uniqueTagsIndex}; %#ok<AGROW>
        end
    end % generateErrors

    function [originalEventTags, canonicalEventTags] = ...
            getEventTags(original, canonical)
        % Retrieves the event level tags for the original and canonical
        % tags
        originalEventTags = original(cellfun(@isstr, original));
        canonicalEventTags = canonical(cellfun(@isstr, canonical));
    end % getEventTags

    function [originalGroupTags, canonicalGroupTags] = ...
            getGroupTags(original, canonical)
        % Retrieves the tag groups for the original and canonical tags
        originalGroupTags = original(cellfun(@iscellstr, original));
        canonicalGroupTags = canonical(cellfun(@iscellstr, canonical));
    end % getGroupTags

end % checkUnique