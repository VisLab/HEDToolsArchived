% This function checks to see if the provided HED tags have the 
% 'requireChild' attribute. Tags with this attribute should not be
% present but instead have a tag that is a descendant of it. Tags found
% with the 'requireChild' attribute will generate an error. 

% Usage:
%
%   >>  [errors, errorTags] = checkrequirechildtags(hedMaps, original, ...
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

function [errors, errorTags] = checkrequirechild(hedMaps, original, ...
    canonical)
errors = '';
errorTags = {};
requireChildTags = hedMaps.requireChild;
checkTags(original, canonical, false);

    function checkTags(originalTags, formattedTags, isGroup)
        % Checks the tags that require children
        numTags = length(formattedTags);
        for a = 1:numTags
            if ~ischar(formattedTags{a})
                checkTags(originalTags{a}, formattedTags{a}, true);
                return;
            elseif requireChildTags.isKey(lower(formattedTags{a}))
                generateErrors(originalTags, a, isGroup);
            end
        end
    end % checkTags

    function generateErrors(originalTags, tagIndex, isGroup)
        % Generates require child tag errors if the require child tag is
        % present in the tag list
        tagString = originalTags{tagIndex};
        if isGroup
            tagString = [originalTags{tagIndex}, ' in group (' ,...
                vTagList.stringifyElement(originalTags),')'];
        end
        errors = [errors, generateerror('requireChild', '', tagString, ...
            '', '')];
        errorTags{end+1} = originalTags{tagIndex};
    end % generateErrors

end % checkrequirechild