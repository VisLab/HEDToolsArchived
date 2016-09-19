% This function checks to see if the provided tags end with a slash. If
% found at the end a warning will be generated.
%
% Usage:
%
%   >>  [warnings, warningTags] = checkslashes(originalTags)
%
% Input:
%
%   originalTags
%                   A cell array of HED tags. These tags are used to report
%                   the warnings found.
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

function [warnings, warningTags] = checkslashes(originalTags)
numElements = findNumElements(originalTags);
warnings = '';
warningTags = cell(1, numElements);
warningsIndex = 1;
checkTagSlashes(originalTags, false);

    function checkTagSlashes(originalTags, isGroup)
        % Checks if the tags ends with a slash
        numTags = length(originalTags);
        for a = 1:numTags
            if ~ischar(originalTags{a})
                checkTagSlashes(originalTags{a}, true);
            elseif findSlashes(originalTags{a})
                generateWarnings(originalTags, a, isGroup);
            end
        end
        warningTags(cellfun('isempty', warningTags)) = [];
    end % checkTagCaps

    function generateWarnings(originalTags, tagIndex, isGroup)
        % Generates tag warnings if the tag ends with a slash
        tagString = originalTags{tagIndex};
        if isGroup
            tagString = [originalTags{tagIndex}, ' in group (' ,...
                vTagList.stringifyElement(originalTags),')'];
        end
        warnings = [warnings, generatewarning('slash', '', tagString, '')];
        warningTags{warningsIndex} = originalTags{tagIndex};
        warningsIndex = warningsIndex + 1;
    end % generateWarnings

    function slashesFound = findSlashes(originalTag)
        % Returns true if the tag ends with a slash
        slashesFound = originalTag(1) == '/' || originalTag(end) == '/';
    end % findSlashes

    function numElements = findNumElements(originalTags)
        % Finds the number of elements in a nested cell array
        numElements = numel(originalTags);
        for a = 1:numElements
            if iscell(originalTags{a})
                numElements = numElements + (numel(originalTags{a})-1);
            end
        end
    end % findNumElements

end  % checkslashes