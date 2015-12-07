function [errors, errorTags] = checkrequirechild(Maps, original, canonical)
errors = '';
errorTags = {};
requireChildTags = Maps.requireChild;
checkTags(original, canonical, false);

    function checkTags(original, canonical, isGroup)
        % Checks the tags that require children
        for a = 1:length(original)
            if iscellstr(original{a})
                checkTags(original{a}, canonical{a}, true);
                return;
            end
            generateErrors(original, canonical, a, isGroup);
        end
    end % checkTags

    function generateErrors(original, canonical, requireIndex, isGroup)
        % Generates require child tag errors if the require child tag is
        % present in the tag list
        try
            requireChildTags(lower(canonical{requireIndex}));
            tagString = original{requireIndex};
            if isGroup
                tagString = [original{requireIndex}, ' in group (' ,...
                    tagList.stringifyElement(original),')'];
            end
            errors = [errors, generateerror('requireChild', '', ...
                tagString, '', '')];
            errorTags{end+1} = original{requireIndex};
        catch
        end
    end % generateErrors

end % checkrequirechild