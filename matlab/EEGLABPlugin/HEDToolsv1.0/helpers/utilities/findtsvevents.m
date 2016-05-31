% This function looks through the events of a tab-delimited file and finds
% the events that contain a list of HED tags.
%
% Usage:
%   >> [matchedEvents, matchedLatencies, latencies] =
%       findevents(events, tags)
%
%   >> [matchedEvents, matchedLatencies, latencies] =
%       findevents(events, tags, varargin)
%
% Inputs:
%
%   events       A tab-delimited file containing tagged EEG events. 
% 
%   tags         A comma separated list of tags or a tag search string
%                consisting of tags to extract data epochs.
%                The tag search uses boolean operators (AND, OR, NOT) to
%                widen or narrow the search. Two tags separated by a comma
%                use the AND operator by default which will only return
%                events that contain both of the tags. The OR operator
%                looks for events that include either one or both tags
%                being specified. The NOT operator looks for events that
%                contain the first tag but not the second tag. Groups can
%                also be searched for by enclosing the tags in parentheses.
%                The operators explained above also apply to tags in
%                groups. Please read below in the "groupmatch" section of
%                "Optional inputs" for further detail on how to search for
%                tags that are contained in event tag groups. To nest or
%                organize the search statements use square brackets.
%                Nesting will change the order in which the search
%                statements are evaluated. For example,
%                "/attribute/visual/color/green AND
%                [/item/2d shape/rectangle/square OR
%                /item/2d shape/ellipse/circle]"
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function [matchedEvents, matchedLatencies, allLatencies] = ...
    findtsvevents(events, tags, varargin)
p = parseArguments();
matchedEvents = [];
matchedLatencies = [];
readTabDelimitedEvents();


    function [queryMap, matchedIndecies] = createQueryMap(matchedIndecies)
        % This function creates a search query based on the number of
        % event groups in the first event and stores it in a Map which is
        % used to compute following event tag searches
        [eventTags, eventNonGroupTags, eventGroupTags] = ...
            formatTags(events(1).usertags);
        str = createlogexp(length(eventGroupTags), p.tags);
        queryMap = containers.Map('KeyType','double','ValueType','char');
        queryMap(length(eventGroupTags)) = str;
        matchFound = evallogexp(str, eventTags, eventNonGroupTags, ...
            eventGroupTags);
        if matchFound
            matchedIndecies(1) = true;
        end
    end % createQueryMap

    function [queryMap, matchedIndecies] = ...
            findTagMatch(queryMap, matchedIndecies, index)
        % This function searches for tags in the current event and returns
        % true if any matches are found
        [eventTags, eventNonGroupTags, eventGroupTags] = ...
            formatTags(events(index).usertags);
        try
            str = queryMap(length(eventGroupTags));
        catch
            str = createlogexp(length(eventGroupTags), p.tags);
            queryMap(length(eventGroupTags)) = str;
        end
        matchFound = evallogexp(str, eventTags, eventNonGroupTags, ...
            eventGroupTags);
        if matchFound
            matchedIndecies(index) = true;
        end
    end % findTagMatch

    function [tags, eventLevelTags, groupTags] = formatTags(tags)
        % Format the tags and puts them in a cellstr if they are in a
        % string
        tags = tagList.deStringify(tags);
        eventLevelTags = tags(cellfun(@ischar, tags));
        groupTags = tags(~cellfun(@ischar, tags));
        if ~iscellstr(tags)
            tags = [tags{:}];
        end
        tags =  tagList.getUnsortedCanonical(tags);
        eventLevelTags =  tagList.getUnsortedCanonical(eventLevelTags);
        for a = 1:length(groupTags)
            groupTags{a} =  tagList.getUnsortedCanonical(groupTags{a});
        end
    end % formatTags

    function p = parseArguments()
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('events', @(x) ~isempty(x) && isstruct(x));
        p.addRequired('tags', @(x) ischar(x));
        p.addParamValue('groupmatch', true, @islogical); %#ok<NVREPL>
        p.addParamValue('latencycolumn', 1, ...
            @(x) isnumeric(x) && numel(x) == 1) %#ok<NVREPL>
        p.addParamValue('tagcolumns', 2, ...
            @(x) isnumeric(x)) %#ok<NVREPL>
        p.parse(events, tags, varargin{:});
        p = p.Results;
    end % parseArguments

    function readTabDelimitedEvents()
        % This function reads a tab-delimited text file line by line
        % containing tagged EEG study events
        fid = fopen(p.events);
        tLine = fgetl(fid);
        events = [];
        allLatencies = [];
        matchedIndecies = logical([]);
        index = 1;
        while ischar(tLine)
            splitLine = strsplit(tLine, '\t');
            latency = strtrim(splitLine{p.latencycolumn});
            eventTags = ...
                formatTags(strjoin(strtrim(splitLine(p.tagcolumns)),','));
            str = createlogexp(p.matchtype, eventTags, p.tags);
            matchFound = eval(str);
            events(index).latency = str2double(latency);
            events(index).usertags = ...
                strjoin(strtrim(splitLine(p.tagcolumns)),',');
            allLatencies(end+1) = str2double(latency); %#ok<AGROW>
            if matchFound
                matchedIndecies(index) = true;
            else
                matchedIndecies(index) = false;
            end
            tLine = fgetl(fid);
            index = index + 1;
        end
        matchedEvents = events(matchedIndecies);
        matchedLatencies = allLatencies(matchedIndecies);
    end % readEvents

end % findtsvevents