function [warnings, warningTags] = checkslashes(original)
warnings = '';
warningTags = {};
checkTagSlashes(original, false);

    function checkTagSlashes(original, isGroup)
        % Checks if the tags doesn't start with a slash or ends with a
        % slash
        for a = 1:length(original)
            if iscellstr(original{a})
                checkTagSlashes(original{a}, true);
            elseif (findSlashes(original{a}))
                generateWarnings(original, a, isGroup);
            end
        end
    end % checkTagCaps

    function generateWarnings(original, capIndex, isGroup)
        % Generates capitalization tag warnings if the tag doesn't start
        % with a slash or ends with a slash
        try
            tagString = original{capIndex};
            if isGroup
                tagString = [original{capIndex}, ' in group (' ,...
                    tagList.stringifyElement(original),')'];
            end
            warnings = [warnings, ...
                generatewarning('slash', '', tagString, '')];
            warningTags{end+1} = original{capIndex};
        catch
        end
    end % generateWarnings

    function slashesFound = findSlashes(slashTag)
        % Returns true if the tag doesn't start with a slash or ends with a
        % slash
        slashesFound = false;
        slashExp = '(^[^/~])?(/$)?';
        if ~isempty(regexp(slashTag, slashExp, 'once'))
            slashesFound = true;
        end
    end % findCaps

end