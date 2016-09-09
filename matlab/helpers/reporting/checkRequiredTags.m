% This function checks to see if the provided tags contain all of the
% tags with the 'required' attribute. 
%
% Usage:
%
%   >>  [errors, errorTags] = checkRequireChildTags(hedMaps, original, ...
%       canonical)
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

function [errors, errorTags] = checkRequiredTags(hedMaps, formattedTags)
% Checks if all required tags are present in the tag list
errors = '';
errorTags = {};
requiredTags = hedMaps.required.values();
eventLevelTags = formattedTags(cellfun(@isstr, formattedTags));
checkRequiredTags();

    function checkRequiredTags()
        % Checks the tags that are required
        numTags = length(requiredTags);
        for a = 1:numTags
            requiredIndexes = strncmpi(eventLevelTags, requiredTags{a}, ...
                length(requiredTags{a}));
            if sum(requiredIndexes) == 0
                generateErrorMessages(a);
            end
        end
    end % checkRequiredTags

    function generateErrorMessages(requiredIndex)
        % Generates a required tag errors if the required tag isn't present
        % in the tag list
        errors = [errors, generateErrorMessage('required', '', ...
            requiredTags{requiredIndex}, '')];
        errorTags{end+1} = requiredTags{requiredIndex};
    end % generateErrorMessages

end % checkRequiredTags