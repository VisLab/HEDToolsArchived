% This function looks for a exact tag match in a list of tags.
%
% Usage:
%
%   >>  found = tagmatch(tags, search)
%
% Input:
%
%   tags         A cell array containing the event tags.
%
%   search       A search tag that is looked for amongst the event tags.
%
% Output:
%
%   found        True if a match was found. False if no match was found.
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

function found = findhedtags(hedString, query)
p = parseArguments(hedString, query);
found = false;

% hed string or query string is empty or query contains only attribute tags
% and there are no attributes on top-level
if hedOrQueryIsEmpty(p) || (queryContainsAllAttributes(p) && ...
        noTopLevelAttributesFound(p))
    return;
end

% Match found at top-level or all levels if there are no
% attribute/exclusive tags
if topLevelMatchFound(p) || (noAttributeOrExlcusiveTagsFound(p) && ...
        matchAnywhereFound(p))
    found = true;
    return;
end

% Finally look in groups, attribute/exclusive tags present
if ~isempty(p.groupTags)
    numGroups = length(p.groupTags);
    matchesFound = zeros(1,numGroups);
    for a = 1:numGroups
        if exclusiveTagsFoundInGroupNotQuery(p, a)
            break;
        elseif entireGroupMatchFound(p, a)
            found = true;
            return;
        else
            matchesFound(a) = partialGroupMatchFound(p, a);
        end
    end
    found = all(matchesFound);
end

    function found = exclusiveTagsFoundInGroupNotQuery(p, indx)
        % Returns true if there are exclusive tags in hed string group but
        % not the query string
        found = ~foundInAndB(p.groupTags{indx}, p.queryTags, ...
            p.exclusiveTags);
    end % exclusiveInGroupNotQuery

    function found = entireGroupMatchFound(p, indx)
        % Returns true if the query string matches the entire group
        found = length(p.groupTags{indx}) == length(p.queryTags) && ...
            all(ismember(p.groupTags{indx}, p.queryTags));
    end % entireGroupMatchFound

    function found = partialGroupMatchFound(p, indx)
        % Returns true if the query string matches part of the group
        found = all(ismember(p.queryTags, p.groupTags{indx}) | ...
            cellfun(@(x) any(strncmp(p.groupTags{indx}, x, length(x))), ...
            p.prefixQueryTags));
    end % partialGroupMatchFound

    function found = foundInAndB(a, b, c)
        % Checks to see if any c elements found in a are also found b
        found = true;
        cElementsFoundInA = c(ismember(c, a));
        if ~isempty(cElementsFoundInA)
            found = any(ismember(cElementsFoundInA, b));
        end
    end % foundInAndB

    function isEmpty = hedOrQueryIsEmpty(p)
        % Returns true if the hed or query string is empty
        isEmpty = isempty(p.queryTags) || isempty(p.allTags);
    end % emptyHedOrQueryString

    function notFound = noTopLevelAttributesFound(p)
        % Returns true if no attribute tags are found at the top level of
        % the hed string
        notFound = ~isempty(p.topLevelTags) && ...
            ~any(strncmp(p.attributePrefix, p.topLevelTags, ...
            length(p.attributePrefix)));
    end % noTopLevelAttributesFound

    function notFound = noAttributeOrExlcusiveTagsFound(p)
        % Returns true if no attribute or exclusive tags are found in
        % hed string
        notFound = ~any(ismember(p.exclusiveTags, ...
            p.allTags)) && ~any(strncmp(p.attributePrefix, p.allTags, ...
            length(p.attributePrefix)));
    end % noAttributeOrExlcusiveTagsFound

    function found = matchAnywhereFound(p)
        % Returns true if a match was found in any tags of the hed string
        found = all(ismember(p.queryTags, p.allTags) | ...
            cellfun(@(x) any(strncmp(p.allTags, x, length(x))), ...
            p.prefixQueryTags));
    end % matchAnywhereFound

    function found = topLevelMatchFound(p)
        % Returns true if a match was found in top-level tags of the hed
        % string
        found = foundInAndB(p.topLevelTags, p.queryTags, ...
            p.exclusiveTags) && ...
            (all(ismember(p.queryTags, p.topLevelTags) | ...
            cellfun(@(x) any(strncmp(p.topLevelTags, x, length(x))), ...
            p.prefixQueryTags)));
    end % topLevelMatchFound

    function p = parseArguments(hedString, query)
        % Parses the input arguments and returns the results
        p = inputParser();
        p.addRequired('hedString', @ischar);
        p.addRequired('query', @ischar);
        p.addOptional('exclusiveTags', {'attribute/intended effect', ...
            'attribute/offset'}, @iscellstr);
        p.parse(hedString, query);
        p = p.Results;
        p = parseHedAndQueryStrings(p, hedString, query);
        p.attributePrefix = 'attribute';
    end % parseArguments

    function p = parseHedAndQueryStrings(p, hedString, query)
        % Parse the hed and query strings and put the tags inside cell
        % arrays within a structure
        p.allTags = tagList.deStringify(lower(hedString));
        p.topLevelTags = p.allTags(cellfun(@ischar, p.allTags));
        p.groupTags = p.allTags(cellfun(@iscell, p.allTags));
        if ~iscellstr(p.allTags)
            p.allTags = [p.allTags{:}];
        end
        p.queryTags = tagList.deStringify(lower(query));
        p.prefixQueryTags = strcat(p.queryTags, '/');
    end % parseHedAndQueryTags

    function attributeOnly = queryContainsAllAttributes(p)
        % Returns true if the query string only contains attribute tags
        attributeOnly = all(strncmp(p.attributePrefix, ...
            p.queryTags, length(p.attributePrefix)));
    end % queryContainsAllAttributes

end % findhedtags