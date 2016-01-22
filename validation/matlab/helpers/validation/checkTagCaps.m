function [warnings, warningTags] = checkTagCaps(hedMaps, originalTags, ...
    formattedTags)
numElements = findNumElements(originalTags);
warnings = '';
warningTags = cell(1, numElements);
warningsIndex = 1;
checkTagCaps(originalTags, formattedTags, false);

    function checkTagCaps(originalTags, formattedTags, isGroup)
        % Checks if the tags are capitalized correctly
        numTags = size(originalTags, 2);
        for a = 1:numTags
            if ~ischar(originalTags{a})
                checkTagCaps(originalTags{a}, formattedTags{a}, true);
            elseif findCaps(formattedTags{a})
                generateWarnings(originalTags, a, isGroup);
            end
        end
        warningTags(cellfun('isempty', warningTags)) = [];
    end % checkTagCaps

    function generateWarnings(originalTags, tagIndex, isGroup)
        % Generates capitalization tag warnings if the tag isn't correctly
        % capitalized
        try
            tagString = originalTags{tagIndex};
            if isGroup
                tagString = [originalTags{tagIndex}, ' in group (' ,...
                    vTagList.stringifyElement(originalTags),')'];
            end
            warnings = [warnings, ...
                generateWarningMessage('cap', '', tagString, '')];
            warningTags{warningsIndex} = originalTags{tagIndex};
            warningsIndex = warningsIndex + 1;
        catch
        end
    end % generateWarnings

    function capsFound = findCaps(originalTag)
        % Returns true if the tag isn't correctly capitalized
        capsFound = false;
        slashPositions = strfind(originalTag, '/');
        if ~isempty(slashPositions)
            valueTag = [originalTag(1:slashPositions(end)) '#'];
            if hedMaps.takesValue.isKey(valueTag)
                return;
            end
        end
        capExp = '(/[a-z])|([^|]\s+[A-Z])*';
        if ~isempty(regexp(originalTag, capExp, 'once'))
            capsFound = true;
        end
    end % findCaps

    function numElements = findNumElements(originalTags)
        % Finds the number of elements in a nested cell array
        numElements = numel(originalTags);
        for a = 1:numElements
            if ~ischar(originalTags{a})
                numElements = numElements + (numel(originalTags{a})-1);
            end
        end
    end % findNumElements

end % checkTagCaps