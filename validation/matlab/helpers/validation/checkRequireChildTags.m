function [errors, errorTags] = checkRequireChildTags(Maps, original, ...
    canonical)
errors = '';
errorTags = {};
requireChildTags = Maps.requireChild;
checkTags(original, canonical, false);

    function checkTags(originalTags, formattedTags, isGroup)
        % Checks the tags that require children
        numTags = length(originalTags);
        for a = 1:numTags
            if ~ischar(originalTags{a})
                checkTags(originalTags{a}, formattedTags{a}, true);
                return;
            elseif requireChildTags.isKey(lower(formattedTags{a}))
                generateErrorMessages(originalTags, a, isGroup);
            end
        end
    end % checkTags

    function generateErrorMessages(originalTags, tagIndex, isGroup)
        % Generates require child tag errors if the require child tag is
        % present in the tag list
        tagString = originalTags{tagIndex};
        if isGroup
            tagString = [originalTags{tagIndex}, ' in group (' ,...
                vTagList.stringifyElement(originalTags),')'];
        end
        errors = [errors, generateErrorMessage('requireChild', '', ...
            tagString, '', '')];
        errorTags{end+1} = originalTags{tagIndex};
    end % generateErrorMessages

end % checkRequireChildTags