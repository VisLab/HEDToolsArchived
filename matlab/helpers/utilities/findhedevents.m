% This function looks through the events of a EEG structure and finds
% the events that contain a list of HED tags.
%
% Usage:
%
%   >> positions = findhedevents(data);
%
%   >> positions = findhedevents(eData, 'key1', 'value1', ...)
%
% Input:
%
%   data         A EEG dataset structure or a tab-separated file containing
%                event HED tags. If a EEG dataset is passed in then it
%                needs to have an .event field. The .event structure is
%                assumed to be present and has a .usertags or .hedtags
%                field containing HED tags. If a tab-separated file is
%                passed in then it needs to have at least one column that
%                contains HED tags. The default tag column will be the
%                second column.
%
%   Optional (key/value):
%
%   tags         A comma separated list of tags or a tag search string
%                used to extract event positions that found a match. If no
%                tags are passed in then a pop-up menu will appear allowing
%                you to specify the tags. The tag search uses boolean
%                operators (AND, OR, NOT) to widen or narrow the search.
%                Two tags separated by a comma use the AND operator by
%                default which will only return events that contain both of
%                the tags. The OR operator looks for events that include
%                either one or both tags being specified. The NOT operator
%                looks for events that contain the first tag but not the
%                second tag. To nest or organize the search statements use
%                square brackets. Nesting will change the order in which
%                the search statements are evaluated. For example,
%                "/attribute/visual/color/green AND
%                [/item/2d shape/rectangle/square OR
%                /item/2d shape/ellipse/circle]".
%
%  header
%                True (the default), if the tab-separated file has a
%                header. False, if the tab-separated file doesn't have a
%                header.
%
% Outputs:
%
%   positions
%                An array containing the positions of the events
%                that found tag matches.
%
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

function positions = findhedevents(data, varargin)
p = parseArguments(data, varargin{:});
positions = [];
if ischar(p.data)
    p.allTags = getTSVTags(p);
else
    p.allTags = arrayfun(@concattags, data.event, 'UniformOutput', false);
end
if isempty(p.tags)
    % Find all the unique tags in the events
    uniqueTags = finduniquetags(p.allTags);
    [canceled, p.tags] = hedsearch_input(uniqueTags);
    if canceled
        return;
    end
end
positions = findMatches(p);

    function positions = findMatches(p)
        % Process the events and look for matches
        positions = false(1,length(p.allTags));
        [uniqueHedStrings, ~, ids]= unique(p.allTags);
        for a = 1:length(uniqueHedStrings)
            [eventTags, eventNonGroupTags, eventGroupTags] = ...
                formatTags(uniqueHedStrings{a});
            str = createlogexp(length(eventGroupTags), p.tags);
            matchFound = evallogexp(str, eventTags, eventNonGroupTags, ...
                eventGroupTags);
            positions(ids == a) = matchFound;
        end
        positions = find(positions);
    end % findMatches

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
        eventLevelTags = tagList.getUnsortedCanonical(eventLevelTags);
        for a = 1:length(groupTags)
            groupTags{a} = tagList.getUnsortedCanonical(groupTags{a});
        end
    end % formatTags

    function [tLine, currentRow, allTags] = checkForHeader(p)
        % Checks to see if the file has a header line
        allTags = {};
        currentRow = 1;
        tLine = fgetl(p.fileId);
        if p.header
            allTags{1} = '';
            tLine = fgetl(p.fileId);
            currentRow = 2;
        end
    end % checkForHeader

    function allTags = getTSVTags(p)
        % Parses the tags in a tab-separated file line by line and
        % validates them
        try
            p.fileId = fopen(p.data);
            [tsvLine, lineNumber, allTags] = checkForHeader(p);
            while ischar(tsvLine)
                allTags{lineNumber} = getLineTags(tsvLine, ...
                    p.columns);
                tsvLine = fgetl(p.fileId);
                lineNumber = lineNumber + 1;
            end
            fclose(p.fileId);
        catch ME
            fclose(p.fileId);
            throw(MException('findTagMatchEvents:cannotParse', ...
                'Unable to parse TSV file on line %d', lineNumber));
        end
    end % getTSVTags

    function lineTags = getLineTags(tLine, columns)
        % Reads the tag columns in a tab-separated file and formats them
        lineTags = '';
        splitLine = textscan(tLine, '%s', 'delimiter', '\t', ...
            'multipleDelimsAsOne', 1)';
        numLineCols = size(splitLine{1},1);
        numCols = size(columns, 2);
        % clean this up later
        if ~all(cellfun(@isempty, strtrim(splitLine))) && ...
                columns(1) <= numLineCols
            lineTags = splitLine{1}{columns(1)};
            for a = 2:numCols
                if columns(a) <= numLineCols
                    lineTags  = [lineTags, ',', ...
                        splitLine{1}{columns(a)}]; %#ok<AGROW>
                end
            end
        end
    end % getLineTags

    function p = parseArguments(data, varargin)
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('data', @(x) ~isempty(x) && ...
            (ischar(x) ||isstruct(x)));
        p.addParamValue('columns', 2, @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        p.addParamValue('tags', '', @ischar);
        p.addParamValue('header', true, @islogical);
        p.parse(data, varargin{:});
        p = p.Results;
    end % parseArguments

end % findevents