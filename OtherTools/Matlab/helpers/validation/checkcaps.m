function [warnings, warningTags] = checkcaps(original)
warnings = '';
warningTags = {};
checkTagCaps(original, false);

    function checkTagCaps(original, isGroup)
        % Checks if the tags are capitalized correctly
        for a = 1:length(original)
            if iscellstr(original{a})
                checkTagCaps(original{a}, true);
            elseif(findCaps(original{a}))
                generateWarnings(original, a, isGroup);
            end
        end
    end % checkTagCaps

    function generateWarnings(original, capIndex, isGroup)
        % Generates capitalization tag warnings if the tag isn't correctly
        % capitalized
        try
            tagString = original{capIndex};
            if isGroup
                tagString = [original{capIndex}, ' in group (' ,...
                    tagList.stringifyElement(original),')'];
            end
            warnings = [warnings, ...
                generatewarning('cap', '', tagString, '')];
            warningTags{end+1} = original{capIndex};
        catch
        end
    end % generateWarnings

    function capsFound = findCaps(capTag)
        % Returns true if the tag isn't correctly capitalized
        capsFound = false;
        splitTags = strsplit(capTag, '/');
        capExp = '(^[a-z])?(\s+[A-Z])*';
        for a = 1:length(splitTags)
            if ~isempty(regexp(splitTags{a}, capExp, 'once'))
                capsFound = true;
                break;
            end
        end
    end % findCaps

end