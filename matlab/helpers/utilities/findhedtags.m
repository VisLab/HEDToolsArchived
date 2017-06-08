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

if isempty(p.queryTags)
    found = false;
    return;
end

% query contains only attribute tags and there are no attributes on
% top-level
if ~isempty(p.topLevelTags) && all(strncmp(p.attributePrefix, p.queryTags, length(p.attributePrefix))) ...
        && ~any(strncmp(p.attributePrefix, p.topLevelTags, length(p.attributePrefix)))
    found = false;
    return;
end

% Look in all tags if there are no attributes/exclusive tags
if ~any(ismember(p.exclusiveTags, p.allTags)) && ...
        ~any(strncmp(p.attributePrefix, p.allTags, length(p.attributePrefix))) ...
        && all(ismember(p.queryTags, p.allTags)) || all(cellfun(@(x) ...
        any(strncmp(p.allTags, x, length(x))), p.prefixQueryTags));
    found = true;
    return;
end

% Look in top-level tags, attributes/exclusive tags present
if foundInAndB(p.topLevelTags, p.queryTags, p.exclusiveTags) && ...
        (all(ismember(p.queryTags, p.topLevelTags)) || all(cellfun(@(x) ...
        any(strncmp(p.topLevelTags, x, length(x))), p.prefixQueryTags)))
    found = true;
    return;
end


% if ~isempty(p.groupTags)
%     found = all(matchesFound);
%     return;
% end

numGroups = length(p.groupTags);
matchesFound = zeros(1,numGroups);
for a = 1:numGroups
    matchesFound(a) = foundInAndB(p.groupTags{a}, p.queryTags, p.exclusiveTags) && ...
        (all(ismember(p.queryTags, p.groupTags{a})) || all(cellfun(@(x) ...
        any(strncmp(p.groupTags{a}, x, length(x))), p.prefixQueryTags)));
end
found = any(matchesFound);


    function found = foundInAndB(a, b, c)
        % Checks to see if all c elements found in a are also found b
        found = all(ismember(c(ismember(c, a)), b));
    end % foundInAButNotB

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

end % tagmatch