% This function looks through the events of a EEG strucutre and finds
% the events that contain a list of HED tags.
%
% Usage:
%
%   >> positions = findTagMatchEvents(EEG, tags);
%
% Inputs:
%
%   EEG          A EEG dataset structure. The dataset needs to have an .event
%                fieldThe .event structure is assumed to be tagged and has a .usertags field
%                containing the tags.
%
%   tags         A comma separated list of tags or a tag search string
%                consisting of tags to extract data epochs.
%                The tag search uses boolean operators (AND, OR, NOT) to
%                widen or narrow the search. Two tags separated by a comma
%                use the AND operator by default which will only return
%                events that contain both of the tags. The OR operator
%                looks for events that include either one or both tags
%                being specified. The NOT operator looks for events that
%                contain the first tag but not the second tag. To nest or
%                organize the search statements use square brackets.
%                Nesting will change the order in which the search
%                statements are evaluated. For example,
%                "/attribute/visual/color/green AND
%                [/item/2d shape/rectangle/square OR
%                /item/2d shape/ellipse/circle]"
%
% Outputs:
%
%   positions
%                A logical array containing the positions of the events
%                that found tag matches.
%
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

function positions = findTagMatchEvents(EEG, varargin)
p = parseArguments(EEG, varargin{:});
positions = [];
if ischar(p.data)
    p.userTags = readTSVLines(p);
else
    p.userTags = {p.data.event.usertags};
end
if isempty(p.tags)
    % Find all the unique tags in the events
    uniqueTags = finduniquetags(p.userTags);
    [canceled, p.tags] = hedsearch_input(uniqueTags);
    if canceled
        return;
    end
end
positions = processEvents(p);

    function positions = processEvents(p)
        % Process the events and look for matches
        positions = false(1,length(p.userTags));
        [uniqueHedStrings, ~, ids]= unique(p.userTags);
        for a = 1:length(uniqueHedStrings)
            [eventTags, eventNonGroupTags, eventGroupTags] = ...
                formatTags(uniqueHedStrings{a});
            str = createlogexp(length(eventGroupTags), p.tags);
            matchFound = evallogexp(str, eventTags, eventNonGroupTags, ...
                eventGroupTags);
            positions(ids == a) = matchFound;
        end
        positions = find(positions);
    end % processEvents

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

    function [tLine, currentRow, userTags] = checkForHeader(p)
        % Checks to see if the file has a header line
        userTags = {};
        currentRow = 1;
        tLine = fgetl(p.fileId);
        if p.header
            userTags{1} = '';
            tLine = fgetl(p.fileId);
            currentRow = 2;
        end
    end % checkForHeader

    function userTags = readTSVLines(p)
        % Parses the tags in a tab-delimited file line by line and
        % validates them
        try
            p.fileId = fopen(p.data);
            [tsvLine, lineNumber, userTags] = checkForHeader(p);
            while ischar(tsvLine)
                userTags{lineNumber} = parseTSVLineTags(tsvLine, ...
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
    end % parseTSVLines

    function lineTags = parseTSVLineTags(tLine, columns)
        % Reads the tag columns in a tab-delimited file and formats them
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
    end % readTSVLineTags

    function p = parseArguments(EEG, varargin)
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('data', @(x) ~isempty(x) && ...
            (ischar(x) ||isstruct(x)));
        p.addParamValue('columns', 2, @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        p.addParamValue('tags', '', @ischar);
        p.addParamValue('header', true, @islogical);
        p.parse(EEG, varargin{:});
        p = p.Results;
    end % parseArguments

end % findevents