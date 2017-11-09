% This function checks to see if the provided HED tags have two or more
% tags that are a descendant of a tag with the 'unique' attribute. Two or
% more tags found will generate an error.
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

function [errors, errorTags] = checkunique(hedMaps, originalTags, ...
    formattedTags)
% Checks to see if a row of tags contain two or more tags that are
% descendants of a unique tag
errors = '';
errorTags = {};
uniqueTags = hedMaps.unique.values();
checkUniqueTags(originalTags, formattedTags);

    function checkUniqueTags(originalTags, formattedTags)
        % Looks for two or more tags that are descendants of a unique tag
        numTags = length(uniqueTags);
        for uniqueTagsIndex = 1:numTags
            foundIndexes = strncmpi(formattedTags, ...
                uniqueTags{uniqueTagsIndex}, ...
                size(uniqueTags{uniqueTagsIndex},2));
            if sum(foundIndexes) > 1
                foundIndexes = find(foundIndexes);
                generateErrors(uniqueTagsIndex, foundIndexes, ...
                    originalTags);
            end
        end
        numTags = length(originalTags);
        for a = 1:numTags
            if ~ischar(originalTags{a})
                checkUniqueTags(originalTags{a}, formattedTags{a})
            end
        end
    end % checkUniqueTags

    function generateErrors(uniqueTagsIndex, foundIndexes, ...
            originalTags)
        % Generates a unique tag error if two or more tags are descendants
        % of a unique tag
        numIndexes = length(foundIndexes);
        for foundIndex = 1:numIndexes
            tagString = originalTags{foundIndexes(foundIndex)};
            errors = [errors, generateerror('unique', '', tagString, ...
                uniqueTags{uniqueTagsIndex}, '')];     %#ok<AGROW>
            errorTags{end+1} = uniqueTags{uniqueTagsIndex}; %#ok<AGROW>
        end
    end % generateErrors

end % checkunique