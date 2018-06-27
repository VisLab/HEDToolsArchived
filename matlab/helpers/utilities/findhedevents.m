% This function looks to see if a query string partially or fully matches a
% HED string. If exlcusive tags are present in the HED string then matches
% to other tags are nullified if they are not specified in the query
% string.
%
% Usage:
%
%   >>  found = findhedevents(hedString, queryString)
%
% Input:
%
%   hedString
%                A string containing HED tags.
%
%   queryString
%                A comma separated list of HED tags that you want to search
%                for. All tags in the list must be present in the HED
%                string.
%
% Optional
%
%   exclusiveTags
%                A cell array of tags that nullify matches to other tags.
%                If these tags are present in both the query string and the
%                HED string then a match will be returned.
%                By default, this argument is set to
%                {'Attribute/Intended effect', 'Attribute/Offset',
%                'Attribute/Participant indication'}.
%
% Output:
%
%   matchFound
%                True, if the query string tags were found in the HED
%                string. False, if there was no match found.
%
% Examples:
%
%   Example 1:
%
%   Tags can be matched by prefix.
%
%   hedString = a/b/c
%
%   queryString = a/b
%
%   findhedevents(hedString, queryString) % returns True
%
%   Example 2:
%
%   Nullifying tags cannot be grouped the same way like other tags with
%   top-level tags.
%
%   hedString = (a/b, Attribute/Intended effect), c/d
%
%   queryString = c/d, Attribute/Intended effect
%
%   findhedevents(hedString, queryString) % returns False
%
%   Example 3:
%
%   When a nullifying tag is common across all groups, then it can be
%   matched.
%
%   hedString = (a/b, Attribute/Intended effect, Attribute/Offset), ...
%   (c/d, Attribute/Intended effect)
%
%   queryString = Attribute/Intended effect
%
%   findhedevents(hedString, queryString) % returns True
%
% Copyright (C) 2017
% Jeremy Cockfield jeremy.cockfield@gmail.com
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

function matchFound = findhedevents(hedString, queryString, varargin)
inputArguments = parseInputArguments(hedString, queryString, ...
    varargin{:});
tags = splitTagsIntoStructureCellArrays(inputArguments);
if specialCaseFound(tags)
    matchFound = false;
else
    matchFound = findMatch(tags);
end

    function matchFound = findMatch(tags)
        % Looks for a match, first at the top-level and then in the groups
        if topLevelMatchFound(tags)
            matchFound = true;
        elseif noAttributeOrExclusiveTagsFound(tags)
            matchFound = matchFoundAnywhere(tags);
        elseif ~isempty(tags.groupTags)
            matchFound = findMatchInGroup(tags);
        else
            matchFound = false;
        end
    end % findMatch

    function found = specialCaseFound(tags)
        % Returns true if special case is found
        found = hedOrQueryStringIsEmpty(tags) || ...
            attributesFoundInQueryNotHedTopLevel(tags);
    end % specialCaseFound

    function found = attributesFoundInQueryNotHedTopLevel(tags)
        % Returns true if there are attribute tags in the query string but
        % no attributes at the top level of the HED string
        found = queryContainsAllAttributes(tags) && ...
            ~isempty(tags.topLevelTags) && ...
            ~topLevelAttributesFound(tags);
    end % attributesFoundInQueryNotHedTopLevel

    function matchFound = findMatchInGroup(tags)
        % Finds a match in the HED string groups
        matchFound = matchFoundInAllGroups(tags);
    end % findMatchInGroup

    function matchFound = noQueryAttributesAndExclusiveTagsFound(tags)
        % Returns true if no attributes tags are found in the query string
        % and no exclusive tags are found in the HED string
        matchFound = queryContainsNoAttributes(tags) && ...
            ~exclusiveTagsFound(tags);
    end % noQueryAttributesOrExclusiveTagsFound

    function matchFound = noNonOnsetAttributesAndExclusiveTagsFound(tags)
        % Returns true if no non-onset attributes tags are found in the
        % HED string and no exclusive tags are found in the HED string
        matchFound = ~nonOnsetAttributeTagsFound(tags) && ...
            ~exclusiveTagsFound(tags);
    end % noNonOnsetAttributesOrExclusiveTagsFound

    function noAttributesFound = noAttributeOrExclusiveTagsFound(tags)
        % Returns true if no attributes are found in query string and no
        % attributes or exclusive tags are found in HED string
        noAttributesFound = ...
            noQueryAttributesAndExclusiveTagsFound(tags) || ...
            noNonOnsetAttributesAndExclusiveTagsFound(tags);
    end % noAttributeOrExclusiveTagsFound

    function matchFound = matchFoundInAllGroups(tags)
        % Find a match that is in all groups
        numGroups = length(tags.groupTags);
        groupMatchesFound = zeros(1, numGroups);
        for indx = 1:numGroups
            if exclusiveTagsFoundInGroupNotQuery(tags, indx)
                break;
            elseif entireGroupMatchFound(tags, indx)
                matchFound = true;
                return;
            else
                groupMatchesFound(indx) = ...
                    partialGroupMatchFound(tags, indx);
            end
        end
        matchFound = all(groupMatchesFound);
    end % matchFoundInAllGroups

    function found = entireGroupMatchFound(tags, indx)
        % Returns true if the query string matches the entire group
        found = length(tags.groupTags{indx}) == length(tags.queryTags) ...
            && all(ismember(tags.groupTags{indx}, tags.queryTags));
    end % entireGroupMatchFound

    function found = exclusiveTagsFoundInGroupNotQuery(tags, indx)
        % Returns true if there are exclusive tags in HED string group but
        % not the query string
        found = ~anyFoundInAndB(tags.groupTags{indx}, tags.queryTags, ...
            tags.exclusiveTags);
    end % exclusiveTagsFoundInGroupNotQuery

    function found = anyFoundInAndB(a, b, c)
        % Checks to see if any c elements found in a are also found in b
        found = true;
        cElementsFoundInA = c(ismember(c, a));
        if ~isempty(cElementsFoundInA)
            found = any(ismember(cElementsFoundInA, b));
        end
    end % anyFoundInAndB

    function isEmpty = hedOrQueryStringIsEmpty(tags)
        % Returns true if the HED or query string is empty
        isEmpty =  isempty(tags.allTags) || isempty(tags.queryTags);
    end % hedOrQueryStringIsEmpty

    function matchFound = matchFoundAnywhere(tags)
        % Returns true if a match is found anywhere. Top-level or groups
        matchFound = all(ismember(tags.queryTags, tags.allTags) | ...
            cellfun(@(x) any(strncmp(tags.allTags, x, length(x))), ...
            tags.prefixQueryTags));
    end % matchFoundAnywhere

    function attributesFound = nonOnsetAttributeTagsFound(tags)
        % Returns true if attribute tags that are not attribute/onset
        % are found in the HED string
        attributesFound = any(strncmp(tags.attributePrefix, ...
            tags.allTags, length(tags.attributePrefix)) & ...
            ~strncmp(tags.onsetTag, tags.allTags, ...
            length(tags.onsetTag)));
    end % nonOnsetAttributeTagsFound

    function matchFound = exclusiveTagsFound(tags)
        % Returns true if exlcusive tags are found in the HED string
        matchFound = any(ismember(tags.exclusiveTags, tags.allTags));
    end % exclusiveTagsFound

    function matchFound = topLevelAttributesFound(tags)
        % Returns true if attribute tags are found at the top level of
        % the HED string
        matchFound = any(strncmp(tags.attributePrefix, ...
            tags.topLevelTags, length(tags.attributePrefix)));
    end % noTopLevelAttributesFound

    function matchFound = partialGroupMatchFound(tags, indx)
        % Returns true if the query string matches part of the group
        matchFound = all(ismember(tags.queryTags, tags.groupTags{indx}) ...
            | cellfun(@(x) any(strncmp(tags.groupTags{indx}, x, ...
            length(x))), tags.prefixQueryTags));
    end % partialGroupMatchFound

    function matchFound = topLevelMatchFound(tags)
        % Returns true if a match was found in top-level tags of the HED
        % string
        matchFound = sameExclusiveTagsFoundInTopLevelAndQuery(tags) && ...
            topLevelExactOrPrefixMatchFound(tags);
    end % topLevelMatchFound

    function matchFound = topLevelExactOrPrefixMatchFound(tags)
        % Returns true if there is an exact or prefix match found in
        % top-level tags
        matchFound = all(exactTopLevelMatchIndices(tags) | ...
            prefixTopLevelMatchIndices(tags));
    end % topLevelExactOrPartialMatchFound

    function matchFound = sameExclusiveTagsFoundInTopLevelAndQuery(tags)
        % Returns true if all exclusive tags found at the top-level are also
        % found in the query tags
        matchFound = anyFoundInAndB(tags.topLevelTags, tags.queryTags, ...
            tags.exclusiveTags);
    end % topLevelExclusiveTagsFoundInQuery

    function matchIndices = exactTopLevelMatchIndices(tags)
        % Returns indices of exact top level matches found
        matchIndices = ismember(tags.queryTags, tags.topLevelTags);
    end % exactTopLevelMatchIndices

    function matchIndices = prefixTopLevelMatchIndices(tags)
        % Returns indices of prefix top level matches found
        matchIndices = cellfun(@(x) any(strncmp(tags.topLevelTags, x, ...
            length(x))), tags.prefixQueryTags);
    end % prefixTopLevelMatchIndices

    function inputArguments = parseInputArguments(hedString, ...
            queryString, varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('hedString', @ischar);
        parser.addRequired('queryString', @ischar);
        parser.addOptional('exclusiveTags', ...
            {'Attribute/Intended effect', 'Attribute/Offset', ...
            'Attribute/Participant indication'}, @iscellstr);
        parser.parse(hedString, queryString, varargin{:});
        inputArguments = parser.Results;
    end % parseInputArguments

    function tags = splitTagsIntoStructureCellArrays(inputArguments)
        % Split HED, query, and exclusive tags into cell arrays inside of a
        % structure
        tags = struct();
        tags.attributePrefix = 'attribute';
        tags.onsetTag = 'attribute/onset';
        tags.exclusiveTags = lower(inputArguments.exclusiveTags);
        tags = splitHedTagsIntoCellArraysByLevel(tags, ...
            inputArguments.hedString);
        tags = splitQueryTagsIntoCellArraysWithPrefix(tags, ...
            inputArguments.queryString);
    end % splitTagsIntoStructureCellArrays

    function tags = splitHedTagsIntoCellArraysByLevel(tags, hedString)
        % Split the HED string tags into cell arrays containing the
        % top-level tags, group tags, and all the tags within a structure
        hedStringDelimiter = HedStringDelimiter(hedString);
        tags.allTags = hedStringDelimiter.getFormattedUniqueTags();
        tags.topLevelTags = hedStringDelimiter.getFormattedTopLevelTags();
        tags.groupTags = hedStringDelimiter.getFormattedGroupTags();
    end % splitHedTagsIntoCellsByLevel

    function tags = splitQueryTagsIntoCellArraysWithPrefix(tags, ...
            queryString)
        % Put the query string tags inside cell arrays containing the
        % tags and the prefix version of them within a structure
        tags.queryTags = ...
            HedStringDelimiter.hedString2FormattedCell(queryString);
        tags.prefixQueryTags = strcat(tags.queryTags, '/');
    end % splitQueryTagsIntoCellArraysWithPrefix

    function containsAllAttributes = queryContainsAllAttributes(p)
        % Returns true if the query string only contains attribute tags
        containsAllAttributes = all(strncmp(p.attributePrefix, ...
            p.queryTags, length(p.attributePrefix)));
    end % queryContainsAllAttributes

    function containsNoAttributes = queryContainsNoAttributes(tags)
        % Returns true if the query string contains no attributes
        containsNoAttributes = ~any(strncmp(tags.attributePrefix, ...
            tags.queryTags, length(tags.attributePrefix)));
    end % queryContainsNoAttributes

end % findhedevents