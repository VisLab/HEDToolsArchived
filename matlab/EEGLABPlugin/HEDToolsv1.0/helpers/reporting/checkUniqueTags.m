function [errors, errorTags] = checkUniqueTags(Maps, originalTags, ...
    formattedTags)
% Checks to see if a row of tags contain two or more tags that are
% descendants of a unique tag
errors = '';
errorTags = {};
uniqueTags = Maps.unique.values();
[originalEventTags, canonicalEventTags] = ...
    getEventTags(originalTags, formattedTags);
[originalGroupTags, canonicalGroupTags] = ...
    getGroupTags(originalTags, formattedTags);
checkUniqueTags(originalEventTags, canonicalEventTags, false);
originalGroupTagsLength = length(originalGroupTags);
for a = 1:originalGroupTagsLength
    checkUniqueTags(originalGroupTags{a}, canonicalGroupTags{a}, true);
end

    function checkUniqueTags(originalTags, formattedTags, isGroup)
        % Looks for two or more tags that are descendants of a unique tag
        numTags = length(uniqueTags);
        for uniqueTagsIndex = 1:numTags
            foundIndexes = strncmp(formattedTags, ...
                uniqueTags{uniqueTagsIndex}, ...
                size(uniqueTags{uniqueTagsIndex},2));
            if sum(foundIndexes) > 1
                foundIndexes = find(foundIndexes);
                generateErrorMessage(uniqueTagsIndex, foundIndexes, ...
                    originalTags, isGroup);
            end
        end
    end % findUniqueTags

    function generateErrorMessage(uniqueTagsIndex, foundIndexes, ...
            originalTags, isGroup)
        % Generates a unique tag error if two or more tags are descendants
        % of a unique tag
        numIndexes = length(foundIndexes);
        for foundIndex = 1:numIndexes
            tagString = originalTags{foundIndexes(foundIndex)};
            if isGroup
                tagString = [originalTags{foundIndexes(foundIndex)}, ...
                    ' in group (' ,...
                    vTagList.stringifyElement(originalTags),')'];
            end
            errors = [errors, generateerror('unique', '', ...
                tagString, uniqueTags{uniqueTagsIndex})];     %#ok<AGROW>
            errorTags{end+1} = uniqueTags{uniqueTagsIndex}; %#ok<AGROW>
        end
    end % generateErrorMessage

    function [originalEventTags, formattedEventTags] = ...
            getEventTags(originalTags, formattedTags)
        % Retrieves the event level tags for the original and canonical
        % tags
        originalEventTags = originalTags(cellfun(@isstr, originalTags));
        formattedEventTags = formattedTags(cellfun(@isstr, formattedTags));
    end % getEventTags

    function [originalGroupTags, canonicalGroupTags] = ...
            getGroupTags(originalTags, formattedTags)
        % Retrieves the tag groups for the original and canonical tags
        originalGroupTags = originalTags(~cellfun(@isstr, originalTags));
        canonicalGroupTags = formattedTags(~cellfun(@isstr, ...
            formattedTags));
    end % getGroupTags

end % checkUniqueTags