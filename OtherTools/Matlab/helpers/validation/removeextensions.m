function [warnings, extensionTags, nonExtensionTags] = ...
    removeextensions(Maps, original)
warnings = '';
extensionAllowedTags = Maps.extensionAllowed.values;
eventLevelTags = original(cellfun(@isstr, original));
extensionTags = {};
groupTagPositions = find(cellfun(@iscellstr, original));
groupTags = original(cellfun(@iscellstr, original));
nonExtensionTags = checkextensions(eventLevelTags, false);
for a = 1:length(groupTags)
    group = checkextensions(groupTags{a}, true);
    if ~isempty(group)
        groupTagPosition = groupTagPositions(a);
        if groupTagPosition > length(nonExtensionTags)
            nonExtensionTags{end+1} = group; %#ok<AGROW>
        else
            nonExtensionTags = insertCell(nonExtensionTags, group, ...
                groupTagPosition);
        end
    end
end

    function original = checkextensions(original, isGroup)
        % Checks if the tags have the extensionAllowed attribute
        for b = 1:length(extensionAllowedTags)
            extensionIndecies = ...
                find(~cellfun(@isempty,regexpi(original, ...
                extensionAllowedTags{b}, 'once')));
            for c = 1:length(extensionIndecies)
                tagString = original{extensionIndecies(c)};
                if isGroup
                    tagString = [original{extensionIndecies(c)}, ...
                        ' in group (' ,...
                        tagList.stringifyElement(original),')'];
                end
                warnings = [warnings, ...
                    generatewarning('extensionAllowed', '', tagString, ...
                    extensionAllowedTags{b}, '')]; %#ok<AGROW>
                extensionTags{end+1} = ...
                    original{extensionIndecies(c)}; %#ok<AGROW>
                original{extensionIndecies(c)} = [];
            end
            original = original(~cellfun(@isempty,original));
        end
    end % checkextensions

    function cellArray = insertCell(cellArray,element,index)
        % Inserts a cell into a cell array and shifts the elements
        cellArray = [cellArray(1:index-1) {element} cellArray(index:end)];
    end % insertCell

end % removeextensions