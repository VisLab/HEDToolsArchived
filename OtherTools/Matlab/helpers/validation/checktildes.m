function [errors, errorTags] = checktildes(original)
errors = '';
errorTags = {};
checkTildeTags(original);

    function checkTildeTags(original)
        % Checks if the tags in the group have no more than 2 tildes
        for a = 1:length(original)
            if iscellstr(original{a})
                if sum(~cellfun(@isempty, regexpi(original{a}, '~'))) > 2
                    generateErrors(original, a);
                end
            end
        end
    end % checkTags

    function generateErrors(original, groupIndex)
        % Generates errors when there are more than 2 tildes in a group
        tagString = tagList.stringifyElement(original{groupIndex});
        errors = [errors, ...
            generateerror('tilde', '', tagString, '', ...
            '')];
        errorTags{end+1} = original{groupIndex};
    end % generateErrors

end % checkTildes