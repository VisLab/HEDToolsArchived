% Returns a merged string of HED tags.
%
% Usage:
%
%   >>  mergedString = mergetagstrings(string1, string2, preservePrefix)  
%    
%
% Input:
%
%   string1
%                    A string containing HED tags. Tags within parentheses
%                    represent a tag group.
%
%   string2
%                    A string containing HED tags. Tags within parentheses
%                    represent a tag group.
%
%   preservePrefix
%                    If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
% Output:
%
%   mergedString
%                   If true (default), the entire inDir directory tree is
%                   searched. If false, only the inDir directory is
%                   searched.
%
%   'tagField'
%
% Notes:
%  - Tags are of a path-like form: /a/b/c
%  - Merging is case insensitive, but the result preserves the case
%    of the first tag encountered (i.e., list 1 over list 2).
%  - Tags that are prefixes of other tags are preserved by default
%  - Whitespace is trimmed from outside of tags
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function mergedString = mergetagstrings(string1, string2, preservePrefix)
mergedString = '';
if nargin < 3
    warning('mergetagstrings:NotEnoughArguments', ...
        'function must have at 3 arguments');
    return;
end
list1 = vTagList.deStringify(string1);
list2 = vTagList.deStringify(string2);
mergedList = mergetaglists(list1, list2, preservePrefix);
if isempty(mergedList)
    return;
elseif ischar(mergedList)
    mergedString = strtrim(mergedList);
    return;
end
mergedString = vTagList.stringify(mergedList);
end % mergetagstrings