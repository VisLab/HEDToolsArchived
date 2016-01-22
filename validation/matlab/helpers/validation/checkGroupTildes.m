function [errors, errorTags] = checkGroupTildes(original)
errors = '';
errorTags = {};
checkTildeTags(original);

    function checkTildeTags(originalTags)
        % Checks if the tags in the group have no more than 2 tildes
        numTags = size(originalTags, 2);
        for a = 1:numTags
            if ~ischar(originalTags{a}) && ...
                    sum(strncmp('~',originalTags{a}, 1)) > 2
                generateErrorMessages(originalTags, a);
            end
        end
    end % checkTags

    function generateErrorMessages(original, groupIndex)
        % Generates errors when there are more than 2 tildes in a group
        tagString = vTagList.stringifyElement(original{groupIndex});
        errors = [errors, ...
            generateErrorMessage('tilde', '', tagString, '', ...
            '')];
        errorTags{end+1} = original{groupIndex};
    end % generateErrorMessages

end % checkGroupTildes