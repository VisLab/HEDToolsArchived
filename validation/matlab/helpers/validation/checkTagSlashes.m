function [warnings, warningTags] = checkTagSlashes(originalTags)
numElements = findNumElements(originalTags);
warnings = '';
warningTags = cell(1, numElements);
warningsIndex = 1;
checkTagSlashes(originalTags, false);

    function checkTagSlashes(originalTags, isGroup)
        % Checks if the tags doesn't start with a slash or ends with a
        % slash
        numTags = length(originalTags);
        for a = 1:numTags
            if ~ischar(originalTags{a})
                checkTagSlashes(originalTags{a}, true);
            elseif findSlashes(originalTags{a})
                generateWarning(originalTags, a, isGroup);
            end
        end
        warningTags(cellfun('isempty', warningTags)) = [];
    end % checkTagCaps

    function generateWarning(originalTags, tagIndex, isGroup)
        % Generates capitalization tag warnings if the tag doesn't start
        % with a slash or ends with a slash
        try
            tagString = originalTags{tagIndex};
            if isGroup
                tagString = [originalTags{tagIndex}, ' in group (' ,...
                    vTagList.stringifyElement(originalTags),')'];
            end
            warnings = [warnings, ...
                generateWarningMessage('slash', '', tagString, '')];
            warningTags{warningsIndex} = originalTags{tagIndex};
            warningsIndex = warningsIndex + 1;
        catch
        end
    end % generateWarningMessageMessage

    function slashesFound = findSlashes(originalTag)
        % Returns true if the tag ends with a slash
        slashesFound = originalTag(end) == '/';
    end % findSlashes

    function numElements = findNumElements(originalTags)
        % Finds the number of elements in a nested cell array
        numElements = numel(originalTags);
        for a = 1:numElements
            if iscell(originalTags{a})
                numElements = numElements + (numel(originalTags{a})-1);
            end
        end
    end % findNumElements

end  % checkTagSlashes