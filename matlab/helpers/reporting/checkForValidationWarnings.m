% This function validates a cell array of HED tags and reports any warnings
% that are found.
%
% Usage:
%
%   >>  warnings = checkForValidationWarnings(hedMaps, originalTags, ...
%       formattedTags);
%
% Input:
%
%       hedMaps
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
%       originalTags
%                   A cell array of HED tags. These tags are used to report
%                   the errors found. A formatted version is used to do the
%                   validation.
%
%       formattedTags
%                   A cell array of HED tags formatted by the vTagList class
%                   that is validated for errors. These tags are formatted
%                   so that they are in the same format that the tags
%                   contained in hedMaps are.
%
% Output:
%
%       warnings
%                   A string containing the validation warnings.
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function warnings = checkForValidationWarnings(hedMaps, originalTags, ...
    formattedTags)
warnings = '';
warnings = [warnings checkTagCaps(hedMaps, originalTags, formattedTags)];
warnings = [warnings checkTagSlashes(originalTags)];
[~, ~, takeValueWarnings] = checkTakeValueTags(hedMaps, originalTags, ...
    formattedTags);
warnings = [warnings takeValueWarnings];
end % checkForValidationWarnings