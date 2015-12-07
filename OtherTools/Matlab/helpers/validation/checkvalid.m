function [errors, extensions, errorTags, extensionTags] = ...
    checkvalid(Maps, original, canonical, extensionAllowed)
errors = '';
extensions = '';
errorTags = {};
extensionTags = {};
takesValueTags = Maps.takesValue.values;
extensionAllowedTags = Maps.extensionAllowed.values;
allTags = Maps.tags;
checkValidTags(original, canonical, false);

    function checkValidTags(original, canonical, isGroup)
        % Checks if the tags are valid
        for a = 1:length(original)
            if iscellstr(original{a})
                checkValidTags(original{a}, canonical{a}, true);
                return;
            end
            try
                allTags(lower(canonical{a}));
            catch
                [isExtensionTag, extensionIndex] = ...
                    tagAllowExtensions(canonical{a});
                if extensionAllowed && isExtensionTag
                    generateExtensions(original, a, extensionIndex, ...
                        isGroup);
                elseif tagTakesValue(canonical{a})
                    generateErrors(original, a, isGroup);
                end
            end
        end
    end % checkValidTags

    function valueTag = convertToValueTag(tag)
        % Strips the tag name and replaces it with #
        valueTag = strsplit(tag, '/');
        valueTag = valueTag(1:end-1);
        valueTag = [strjoin(valueTag,'/'), '/#'];
    end % convertToValueTag

    function generateErrors(original, validIndex, isGroup)
        % Generates errors for tags that are not valid
        tagString = original{validIndex};
        if isGroup
            tagString = [original{validIndex}, ...
                ' in group (' ,...
                tagList.stringifyElement(original),')'];
        end
        errors = [errors, generateerror('valid', '', tagString, ...
            '','')];
        errorTags{end+1} = original{validIndex};
    end % generateErrors

    function generateExtensions(original, originalIndex, ...
            extensionIndex, isGroup)
        % Generates extension warnings for tags that are children of
        % extension allowed tags
        tagString = original{originalIndex};
        if isGroup
            tagString = [original{originalIndex}, ...
                ' in group (' ,...
                tagList.stringifyElement(original),')'];
        end
        extensions = [extensions, ...
            generateextension('extensionAllowed', '', tagString, ...
            extensionAllowedTags{extensionIndex})];
        extensionTags{end+1} = original{originalIndex};
    end % generateExtensions

    function [isExtensionTag, extensionIndex] = ...
            tagAllowExtensions(canonical)
        % Checks if the tags have the extensionAllowed attribute
        isExtensionTag = false;
        extensionIndex = 0;
        for a = 1:length(extensionAllowedTags)
            if ~isempty(regexpi(canonical, extensionAllowedTags{a}))
                isExtensionTag = true;
                extensionIndex = a;
                break;
            end
        end
    end % checkextensions

    function isValueTag = tagTakesValue(tag)
        % Checks to see if the tag takes a value
        isValueTag = false;
        valueTag = convertToValueTag(tag);
        takesValueIndexes = ~cellfun(@isempty, ...
            regexpi(takesValueTags, valueTag));
        if ~any(takesValueIndexes)
            isValueTag = true;
        end
    end % tagTakesValue

end % checkValid