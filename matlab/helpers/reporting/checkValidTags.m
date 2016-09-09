% This function checks to see if the provided HED tags are in the HED
% schema. Tags not in the HED schema will be checked to see if they are a
% descendant of a tag with the 'extensionAllowed' attribute. If they are
% not then an error will be generated.    
%
% Usage:
%
%   >>  [errors, errorTags] = checkUniqueTags(hedMaps, originalTags, ...
%       formattedTags)
%
% Input:
%
%   hedMaps
%                   A structure that contains Maps associated with the HED
%                   XML tags. There is a map that contains all of the HED
%                   tags, a map that contains all of the unit class units,
%                   a map that contains the tags that take in units, a map
%                   that contains the default unit used for each unit
%                   class, a map that contains the tags that take in
%                   values, a map that contains the tags that are numeric,
%                   a map that contains the required tags, a map that
%                   contains the tags that require children, a map that
%                   contains the tags that are extension allowed, and map
%                   that contains the tags are are unique.
%
%   originalTags
%                   A cell array of HED tags. These tags are used to report
%                   the errors found. 
%
%   formattedTags
%                   A cell array of HED tags. These tags are used to do the
%                   validation.
%
% Output:
%
%   errors
%                   A string containing the validation errors.
%
%   errorTags
%                   A cell array containing validation error tags.  
%
% Copyright (C) 2012-2016 Thomas Rognon tcrognon@gmail.com,
% Jeremy Cockfield jeremy.cockfield@gmail.com, and
% Kay Robbins kay.robbins@utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [errors, errorTags] = checkValidTags(hedMaps, originalTags, ...
    formattedTags)
errors = '';
errorTags = {};
errorsIndex = 1;
checkValidTags(originalTags, formattedTags, false);

    function checkValidTags(originalTags, formattedTags, isGroup)
        % Checks if the tags are valid
        numTags = length(formattedTags);
        for a = 1:numTags
            if ~ischar(formattedTags{a})
                checkValidTags(originalTags{a}, formattedTags{a}, true);
                return;
            end
            if isTilde(formattedTags{a}) || ...
                    tagTakesValue(formattedTags{a}) || ...
                    hedMaps.tags.isKey(lower(formattedTags{a}))
                continue;
            end
            if ~tagAllowExtensions(formattedTags{a})
                generateError(originalTags, a, isGroup);
            end
        end
        errorTags(cellfun('isempty', errorTags)) = [];
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

    function [isExtensionTag, extensionParentTag] = tagAllowExtensions(tag)
        % Checks if the tag has the extensionAllowed attribute
        isExtensionTag = false;
        extensionParentTag = '';
        slashIndexes = strfind(tag, '/');
        while size(slashIndexes, 2) > 1
            parent = tag(1:slashIndexes(end)-1);
            if hedMaps.extensionAllowed.isKey(lower(parent))
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
            if hedMaps.takesValue.isKey(lower(valueTag))
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