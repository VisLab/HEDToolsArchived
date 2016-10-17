% Sorts a HED string. The string is sorted so the tags that start with
% Event/Category appear first, Event/Label second, Event/Long name third,  
% Event/Description fourth, and all other tags following.
%
% Usage:
%
%   >>  sortedtags = sorttags(tags)
%
% Input:
%
%   Required:
%
%   tags
%                    A HED string. 
%
%
% Output:
%
%   sortedtags
%                    A sorted HED string. The string is sorted so the
%                    tags that start with Event/Category appear first,
%                    Event/Label second, Event/Long name third,  
%                    Event/Description fourth, and all other tags
%                    following.
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

function sortedtags = sorttags(tags)
tagList = vTagList.deStringify(tags);
groupPos = cellfun(@iscellstr, tagList);
groupTags = tagList(groupPos);
eventTags = tagList(~groupPos);
eventTagsPos = false(1, length(eventTags));
sortedEventTags = {};
sortedEventindex = 1;
[sortedEventTags, sortedEventindex, eventTagsPos] = ...
    findTags('category', eventTags, eventTagsPos, sortedEventTags, ...
    sortedEventindex);
[sortedEventTags, sortedEventindex, eventTagsPos] = findTags('label', ...
    eventTags, eventTagsPos, sortedEventTags, sortedEventindex);
[sortedEventTags, sortedEventindex, eventTagsPos] = ...
    findTags('longname', eventTags, eventTagsPos, sortedEventTags, ...
    sortedEventindex);
[sortedEventTags, ~, eventTagsPos] = findTags('description', eventTags, ...
    eventTagsPos, sortedEventTags, sortedEventindex);
leftOverTags = eventTags(~eventTagsPos);
allTags = [sortedEventTags leftOverTags groupTags];
sortedtags = vTagList.stringify(allTags);

    function [sortedEventTags, sortedEventindex, eventTagsPos] = ...
            findTags(type, eventTags, eventTagsPos, sortedEventTags, ...
            sortedEventindex)
        % Find tags that start with particular prefixes
        switch type
            case 'category'
                [found, pos] = findCategory(eventTags);
            case 'description'
                [found, pos] = findDescription(eventTags);
            case 'label'
                [found, pos] = findLabel(eventTags);
            case 'longname'
                [found, pos] = findLongname(eventTags);
            otherwise
                found = false;
        end
        if found
            numFound = sum(pos);
            sortedEventTags(sortedEventindex:sortedEventindex + ...
                (numFound - 1)) = eventTags(pos);
            sortedEventindex = sortedEventindex + numFound;
            eventTagsPos(pos) = true;
        end
    end % findTags

    function [found, pos] = findCategory(tags)
        % Looks for tags that start with Event/Category
        search = 'Event/Category';
        pos = strncmpi(tags, search, length(search));
        found = any(pos);
    end % findCategory

    function [found, pos] = findDescription(tags)
        % Looks for tags that start with Event/Description
        search = 'Event/Description';
        pos = strncmpi(tags, search, length(search));
        found = any(pos);
    end % findDescription

    function [found, pos] = findLabel(tags)
        % Looks for tags that start with Event/Label
        search = 'Event/Label';
        pos = strncmpi(tags, search, length(search));
        found = any(pos);
    end % findLabel

    function [found, pos] = findLongname(tags)
        % Looks for tags that start with Event/Long name
        search = 'Event/Long name';
        pos = strncmpi(tags, search, length(search));
        found = any(pos);
    end % findLongname

end % sorttags