% This function merges two cell arrays containing HED tags based on the
% preserve prefix option.
%
% Usage:
%
%   >>  mergedList = merge_taglists(tList1, tList2, preservePrefix)
%
% Input:
%
%   Required:
%
%   tList1
%                    A cell array containing HED tags. A cell array within
%                    the cell array represents a tag group.
%
%   tList2
%                    A cell array containing HED tags. A cell array within
%                    the cell array represents a tag group.
%
%   preservePrefix
%                    If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
% Output:
%
%   mergedList
%                   A merged cell array consisting of tags from tList1 and
%                   tList2 based on the preserve prefix option.
%
% Notes:
%
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

function mergedList = merge_taglists(tList1, tList2, preservePrefix)
parseArguments(tList1, tList2, preservePrefix);
myMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
myMap = addList2Map(tList1, myMap);
myMap = addList2Map(tList2, myMap);
if ~preservePrefix
    myMap = undoPrefix(myMap);
end
mergedList = getMergedList(myMap);

    function mergedList = getMergedList(myMap)
        % Gets the merged list from the Map container
        mergedList = myMap.values();
        if isempty(mergedList)
            mergedList = '';
        elseif length(mergedList) == 1 && ischar(mergedList{1})
            mergedList = mergedList{1};
        end
    end % getMergedList

    function myMap = addList2Map(tList, myMap)
        % Add a cell array tag list to a Map container
        if ~isempty(tList) && ischar(tList)
            tList = {tList};
        end
        for k = 1:length(tList)
            if ~isempty(tList{k})
                item = strtrim(tList{k});
                itemKey = lower(item);
                if iscellstr(itemKey)
                    itemKey = ['(',strjoin(itemKey,','),')'];
                end
                if ~myMap.isKey(itemKey) && ~isempty(itemKey)
                    myMap(itemKey) = item;
                end
            end
        end
    end % addList2Map

    function p = parseArguments(tList1, tList2, preservePrefix)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('tList1', @(x) ischar(x) || iscell(x));
        parser.addRequired('tList2', @(x) ischar(x) || iscell(x));
        parser.addRequired('PreservePrefix', @islogical);
        parser.parse(tList1, tList2, preservePrefix);
        p = parser.Results;
    end % parseArguments

    function myMap = undoPrefix(myMap)
        % undo the prefix of the tags
        myKeys = keys(myMap);
        myKeys = sort(myKeys);
        for k = 1:length(myKeys) - 1
            if ~isempty(regexp(myKeys{k+1}, ['^' myKeys{k}], 'match'))
                remove(myMap, myKeys{k});
            end
        end
    end % undoPrefix

end % merge_taglists