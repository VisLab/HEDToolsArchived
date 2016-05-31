% merge_tagstrings
% Returns a merged cell array of tags
%
% Usage:
%   >> mergedString = merge_tagstrings(string1, string2, preservePrefix)   
%    
% Description:
% mergedString = merge_tagstrings(string1, string2, preservePrefix) returns
% a merged cell array of tags
%
% Notes:
%  - Tags are of a path-like form: /a/b/c
%  - Merging is case insensitive, but the result preserves the case
%    of the first tag encountered (i.e., list 1 over list 2).
%  - Tags that are prefixes of other tags are preserved by default
%  - Whitespace is trimmed from outside of tags
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for merge_tagstrings:
%
%    doc merge_tagstrings
%
% See also: tageeg, tageeg_input, pop_tageeg
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
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
%
% $Log: merge_tagstrings.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function mergedString = merge_tagstrings(string1, string2, preservePrefix)
mergedString = '';
if nargin < 3
    warning('merge_tagstrings:NotEnoughArguments', ...
        'function must have at 3 arguments');
    return;
end
parsed1 = regexpi(string1, ',', 'split');
parsed2 = regexpi(string2, ',', 'split');
merged = merge_taglists(parsed1, parsed2, preservePrefix);
if isempty(merged)
    return;
elseif ischar(merged)
    mergedString = strtrim(merged);
    return;
end

mergedString = strtrim(merged{1});
for k = 2:length(merged)
    mergedString = [mergedString ',' merged{k}]; %#ok<AGROW>
end
end % merge_tagstrings