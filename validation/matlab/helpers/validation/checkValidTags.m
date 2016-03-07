function [errors, errorTags, extensions, extensionTags] = ...
    checkValidTags(Maps, originalTags, formattedTags, extensionAllowed)
errors = '';
extensions = '';
errorTags = {};
extensionTags = {};
errorsIndex = 1;
extensionsIndex = 1;
checkValidTags(originalTags, formattedTags, false);

    function checkValidTags(originalTags, formattedTags, isGroup)
        % Checks if the tags are valid
        numTags = length(originalTags);
        for a = 1:numTags
            if ~ischar(originalTags{a})
                checkValidTags(originalTags{a}, formattedTags{a}, true);
                return;
            end
            if isTilde(formattedTags{a}) || ...
                    tagTakesValue(formattedTags{a}) || ...
                    Maps.tags.isKey(lower(formattedTags{a}))
                continue;
            end
            [isExtensionTag, extensionParentTag] = ...
                tagAllowExtensions(formattedTags{a});
            if extensionAllowed && isExtensionTag
                generateExtensions(originalTags, a, extensionParentTag, ...
                    isGroup);
            else
                generateError(originalTags, a, isGroup);
            end
        end
        errorTags(cellfun('isempty', errorTags)) = [];
        extensionTags(cellfun('isempty', extensionTags)) = [];
    end % checkValidTags

    function tilde = isTilde(tag)
        % Returns true if the tag cell array is a tilde
        tilde = strcmp('~', tag);
    end % isTilde

    function valueTag = convertToValueTag(tag)
        % Strips the tag name and replaces it with #
        valueTag = '/#';
        slashPositions = strfind(tag, '/');
        if ~isempty(slashPositions)
            valueTag = [tag(1:slashPositions(end)) '#'];
        end
    end % convertToValueTag

    function generateError(originalTags, tagIndex, isGroup)
        % Generates errors for tags that are not valid
        tagString = originalTags{tagIndex};
        if isGroup
            tagString = [originalTags{tagIndex}, ...
                ' in group (' ,...
                vTagList.stringifyElement(originalTags),')'];
        end
        errors = [errors, generateErrorMessage('valid', '', tagString, ...
            '','')];
        errorTags{errorsIndex} = originalTags{tagIndex};
        errorsIndex = errorsIndex + 1;
    end % generateErrorMessages

    function generateExtensions(originalTags, tagIndex, ...
            extensionParentTag, isGroup)
        % Generates extension warnings for tags that are children of
        % extension allowed tags
        tagString = originalTags{tagIndex};
        if isGroup
            tagString = [originalTags{tagIndex}, ' in group (' ,...
                vTagList.stringifyElement(originalTags),')'];
        end
        extensions = [extensions, ...
            generateExtensionMessage('extensionAllowed', '', tagString, ...
            extensionParentTag)];
        extensionTags{extensionsIndex} = originalTags{tagIndex};
        extensionsIndex = extensionsIndex + 1;
    end % generateExtensions

    function [isExtensionTag, extensionParentTag] = tagAllowExtensions(tag)
        % Checks if the tag has the extensionAllowed attribute
        isExtensionTag = false;
        extensionParentTag = '';
        slashIndexes = strfind(tag, '/');
        while size(slashIndexes, 2) > 1
            parent = tag(1:slashIndexes(end)-1);
            if Maps.extensionAllowed.isKey(lower(parent))
                extensionParentTag = parent;
                isExtensionTag = true;
                break;
            end
            slashIndexes = strfind(parent, '/');
        end
    end % tagAllowExtensions

    function isValueTag = tagTakesValue(tag)
        % Checks to see if the tag takes a value
        isValueTag = false;
        valueTag = convertToValueTag(tag);
        while ~strncmp(valueTag, '/#', 2)
            if Maps.takesValue.isKey(lower(valueTag))
                isValueTag = true;
                break;
            end
            slashPositions = strfind(valueTag, '/');
            if size(slashPositions, 2) < 2
                break;
            end
            valueTag = valueTag(1:slashPositions(end)-1);
            valueTag = convertToValueTag(valueTag);
        end
    end % tagTakesValue

end % checkValidTags