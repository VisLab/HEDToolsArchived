% This function checks for the capitalization of the provided HED tags. The
% first word of each tag must be capitalized and all subsequent words
% should be lowercase. Any tags not complying to these rules will generate
% a warning.
%
% Usage:
%
%   >>  [warnings, warningTags] = checkTagCaps(hedMaps, originalTags, ...
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
%                   the warnings found.
%
%   formattedTags
%                   A cell array of HED tags. These tags are used to do the
%                   validation.
%
% Output:
%
%   warnings
%                   A string containing the validation warnings.
%
%   warningTags
%                   A cell array containing validation warning tags.
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

function [warnings, warningTags] = checkTagCaps(hedMaps, originalTags, ...
    formattedTags)
numElements = findNumElements(originalTags);
warnings = '';
warningTags = cell(1, numElements);
warningsIndex = 1;
checkTagCaps(originalTags, formattedTags, false);

    function checkTagCaps(originalTags, formattedTags, isGroup)
        % Checks if the tags are capitalized correctly
        numTags = length(formattedTags);
        for a = 1:numTags
            if ~ischar(formattedTags{a})
                checkTagCaps(originalTags{a}, formattedTags{a}, true);
            elseif findCaps(formattedTags{a})
                generateWarnings(originalTags, a, isGroup);
            end
        end
        warningTags(cellfun('isempty', warningTags)) = [];
    end % checkTagCaps

    function generateWarnings(originalTags, tagIndex, isGroup)
        % Generates capitalization tag warnings if the tag isn't correctly
        % capitalized
        tagString = originalTags{tagIndex};
        if isGroup
            tagString = [originalTags{tagIndex}, ' in group (' ,...
                vTagList.stringifyElement(originalTags),')'];
        end
        warnings = [warnings, generateWarning('cap', '', tagString, '')];
        warningTags{warningsIndex} = originalTags{tagIndex};
        warningsIndex = warningsIndex + 1;
    end % generateWarnings

    function capsFound = findCaps(originalTag)
        % Returns true if the tag isn't correctly capitalized
        capsFound = false;
        slashPositions = strfind(originalTag, '/');
        if ~isempty(slashPositions)
            valueTag = [originalTag(1:slashPositions(end)) '#'];
            if hedMaps.takesValue.isKey(lower(valueTag))
                return;
            end
        end
        capExp = '^[a-z]|/[a-z]|[^|]\s+[A-Z]';
        if ~isempty(regexp(originalTag, capExp, 'once'))
            capsFound = true;
        end
    end % findCaps

    function numElements = findNumElements(originalTags)
        % Finds the number of elements in a nested cell array
        numElements = numel(originalTags);
        for a = 1:numElements
            if ~ischar(originalTags{a})
                numElements = numElements + (numel(originalTags{a})-1);
            end
        end
    end % findNumElements

end % checkTagCaps