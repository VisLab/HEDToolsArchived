% merge_taglists
% Returns a merged cell array of tags conforming to preservePrefix
%
% Usage:
%   >> mergedList = merge_taglists(tList1, tList2, preservePrefix)
%
% Description:
% mergedList = merge_taglists(tList1, tList2, preservePrefix) returns a
% merged cell array of tags conforming to preservePrefix
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
% documentation for merge_taglists:
%
%    doc merge_taglists
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
% $Log: merge_taglists.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function mergedList = merge_taglists(tList1, tList2, preservePrefix)
mergedList = '';
if nargin < 3
    warning('merge_taglists:NotEnoughArguments', ...
        'function must e arguments');
    return;
end
myMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

if ~isempty(tList1) && ischar(tList1)
    tList1 = {tList1};     % Convert string to cellstring
end
for k = 1:length(tList1)
    if ~isempty(tList1{k})
        item = strtrim(tList1{k});
        itemKey = lower(item);  % Key is lower case
        if iscellstr(itemKey)
            itemKey = ['(',strjoin(itemKey,','),')'];
        end
        if ~myMap.isKey(itemKey) && ~isempty(itemKey)
            myMap(itemKey) = item;
        end
    end
end

if ~isempty(tList2) && ischar(tList2)
    tList2 = {tList2};     % Convert string to cellstring
end
for k = 1:length(tList2)
    if ~isempty(tList2{k})
        item = strtrim(tList2{k});
        itemKey = lower(item);  % Key is lower case
        if iscellstr(itemKey)
            itemKey = ['(',strjoin(itemKey,','),')'];
        end
        if ~myMap.isKey(itemKey) && ~isempty(itemKey)
            myMap(itemKey) = item;
        end
    end
end
if ~preservePrefix
    myKeys = keys(myMap);
    myKeys = sort(myKeys);
    for k = 1:length(myKeys) - 1
        if ~isempty(regexp(myKeys{k+1}, ['^' myKeys{k}], 'match'))
            remove(myMap, myKeys{k});
        end
    end
end
mergedList = myMap.values();
if isempty(mergedList)
    mergedList = '';
elseif length(mergedList) == 1 && ischar(mergedList{1})
    mergedList = mergedList{1};
end
end % merge_taglists