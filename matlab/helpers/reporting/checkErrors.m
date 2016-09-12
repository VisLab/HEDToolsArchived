% This function validates a cell array of HED tags and reports any errors
% that are found.
%
% Usage:
%
%   >>  [errors, errorTags] = checkErrors(hedMaps, originalTags, ...
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

function [errors, errorTags] = checkErrors(hedMaps, originalTags, ...
    formattedTags)
errors = '';
errors = [errors checkRequiredTags(hedMaps, formattedTags)];
errors = [errors checkRequireChildTags(hedMaps, originalTags, ...
    formattedTags)];
errors = [errors checkTakeValueTags(hedMaps, originalTags, formattedTags)];
errors = [errors checkGroupTildes(originalTags)];
errors = [errors checkUniqueTags(hedMaps, originalTags, formattedTags)];
[validationErrors, errorTags] = checkValidTags(hedMaps, originalTags, ...
    formattedTags, true);
errors = [errors validationErrors];
end % checkErrors