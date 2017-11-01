% Reads in a tab-separated file and stores the events and associated tags
% in a tagMap object.
%
% Usage:
%
%   >>  tsvMap = tsvhed2map(tsvfile)
%
%   >>  tsvMap = tsvhed2map(tsvfile, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   tsvfile
%                    The full path of a tab-separated file containing tags
%                    associated with the EEG dataset.
%
%   Optional (key/value):
%
%   EventsTsvTagField
%                    The field name in the EEG structure that is associated
%                    with the values in a tab-separated file. The default
%                    field name is 'type'.
%
%   TsvAttributeColumn
%                    The column in the tab-separated file reserved for the
%                    attribute tag. If the column value doesn't start with
%                    the prefix Attribute/ then it will be prepended to the
%                    column value.
%
%   TsvCategoryColumn
%                    The column in the tab-separated file reserved for the
%                    category tags. If the column values don't start with
%                    the prefix Event/Category/ then it will be prepended
%                    to the column values.
%
%   TsvDescriptionColumn
%                    The column in the tab-separated file reserved for the
%                    description tag. If the column value doesn't start
%                    with the prefix Event/Description/ then it will be
%                    prepended to the column value.
%
%   TsvEventColumn
%                    The column in the tab-separated file used to identify
%                    the events in the EEG structure. This is a
%                    scalar integer. The default is 1 which is the first
%                    column.
%
%   TsvFileHasHeader
%                   True, which is the default if the the tab-separated
%                   file has a header.
%
%   TsvLabelColumn
%                    The column in the tab-separated file reserved for the
%                    label tag. If the column value doesn't start
%                    with the prefix Event/Label/ then it will be
%                    prepended to the column value.
%
%   TsvLongnameColumn
%                    The column in the tab-separated file reserved for the
%                    longname tag. If the column value doesn't start
%                    with the prefix Event/Long name/ then it will be
%                    prepended to the column value.
%
%   TsvTagColumns
%                    The tag column(s) in the tab-separated file. This can
%                    be a scalar integer or an integer vector. The default
%                    is 2 which is the second column.
%
% Output:
%
%   tsvMap
%                    A tagMap object containing the events and associated
%                    tags from the tab-separated file.
%
% Examples:
%
%  Store a tab-separated file 'BCI Data Specification.tsv' with event types
%  in column '1' and HED tags in columns '3','4','5','6' in a tagMap
%  'tsvMap' as field 'type'.
%
%  tsvMap = tagtsv('BCI Data Specification.tsv', 'EventsTsvTagField',
%  'type', 'TsvEventColumn', 1, 'TsvTagColumns', [3,4,5,6])
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

function tsvMap = tsvhed2map(tsvfile, varargin)
p = parseArguments(tsvfile, varargin{:});
tsvMap = tagMap('Field', p.EventsTsvTagField);
lineNumber = 1;
try
    fileId = fopen(p.tsvfile);
    [line, lineNumber] = checkFileHeader(p.TsvFileHasHeader, fileId);
    while ischar(line)
        event = getLineValues(p, line, p.TsvEventColumn, false);
        tags = getLineValues(p, line, p.TsvTagColumns, true);
        if ~isempty(event)
            addTags2Map(tsvMap, event, tags);
        end
        lineNumber = lineNumber + 1;
        line = fgetl(fileId);
    end
    fclose(fileId);
catch ME
    if fileId ~= -1
        fclose(fileId);
    end
    throw(MException(ME.identifier, ...
        sprintf('Line %d : %s', lineNumber, ME.message)));
end

    function addTags2Map(tsvMap, event, tags)
        % Adds tags to a TagMap
        tList = tagList(event);
        tList.addString(tags);
        tsvMap.addValue(tList);
    end % addTags2Map

    function [line, lineNumber] = checkFileHeader(tsvFileHasHeader, fileId)
        % Checks to see if the file has a header and skips it if it does
        lineNumber = 1;
        line = fgetl(fileId);
        if tsvFileHasHeader
            line = fgetl(fileId);
            lineNumber = 2;
        end
    end % checkFileHeader

    function values = getLineValues(p, line, column, areTagColumns)
        % Reads the column values on a tab-delimited line
        delimitedLine = textscan(line, '%s', 'delimiter', '\t');
        delimitedLine{1} = strtrim(strrep(delimitedLine{1}, '"', ''));
        if areTagColumns
            [delimitedLine{1}, column] = getSpecificColumns(p, ...
                delimitedLine{1});
        end
        delimitedLineCount = 1:length(delimitedLine{1});
        availableColumns = intersect(delimitedLineCount, column);
        nonemptyColumns = availableColumns(~cellfun(@isempty, ...
            delimitedLine{1}(availableColumns)));
        values = strjoin(delimitedLine{1}(nonemptyColumns)', ', ');
    end % getLineValues

    function [delimitedLine, column] = getSpecificColumns(p, delimitedLine)
        % Gets specific tag columns and appends the appropriate prefix to
        % it if it's not present
        numColumns =  length(delimitedLine);
        column = p.TsvTagColumns;
        if ~isempty(p.TsvAttributeColumn) && numColumns >= ...
                p.TsvAttributeColumn
            delimitedLine{p.TsvAttributeColumn} = ...
                prependPrefix(delimitedLine{p.TsvAttributeColumn}, ...
                'Attribute/');
            column = union(column, p.TsvAttributeColumn);
        end
        if ~isempty(p.TsvCategoryColumn) && numColumns >= ...
                p.TsvCategoryColumn
            delimitedLine{p.TsvCategoryColumn} = ...
                prependPrefix(delimitedLine{p.TsvCategoryColumn}, ...
                'Event/Category/');
            column = union(column, p.TsvCategoryColumn);
        end
        if ~isempty(p.TsvDescriptionColumn) && numColumns >= ...
                p.TsvDescriptionColumn
            delimitedLine{p.TsvDescriptionColumn} = ...
                prependPrefix(delimitedLine{p.TsvDescriptionColumn}...
                , 'Event/Description/');
            column = union(column, p.TsvDescriptionColumn);
        end
        if ~isempty(p.TsvLabelColumn) && numColumns >= p.TsvLabelColumn
            delimitedLine{p.TsvLabelColumn} = ...
                prependPrefix(delimitedLine{p.TsvLabelColumn}, ...
                'Event/Label/');
            column = union(column, p.TsvLabelColumn);
        end
        if ~isempty(p.TsvLongnameColumn) && numColumns >= ...
                p.TsvLongnameColumn
            delimitedLine{p.TsvLongnameColumn} = ...
                prependPrefix(delimitedLine{p.TsvLongnameColumn}, ...
                'Event/Long name/');
            column = union(column, p.TsvLongnameColumn);
        end
    end % getSpecificColumns

    function specificLine = prependPrefix(specificLine, specificStr)
        % Appends a prefix to a tag column if it isn't present
        if ~isempty(specificLine)
            specificTags = textscan(specificLine, '%s', 'delimiter', ',');
            pos = ~strncmpi(specificTags{1}, specificStr, ...
                length(specificStr));
            specificTags{1}(pos) = strcat(specificStr, ...
                specificTags{1}(pos));
            specificLine = strjoin(specificTags{1}, ', ');
        end
    end % prependPrefix

    function p = parseArguments(tsvfile, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('tsvfile', @(x) ~isempty(x) && ...
            ischar(tsvfile));
        parser.addParamValue('EventsTsvTagField', 'type', @(x) ...
            ~isempty(x) && ischar(x));
        parser.addParamValue('TsvAttributeColumn', [], @(x) ~isempty(x) ...
            && isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvCategoryColumn', [], @(x) ~isempty(x) ...
            && isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvDescriptionColumn', [], @(x) ...
            ~isempty(x) && isnumeric(x) && length(x) == 1 && ...
            rem(x,1) == 0);
        parser.addParamValue('TsvEventColumn', 1, @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvFileHasHeader', true, @islogical);
        parser.addParamValue('TsvLabelColumn', [], @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvLongnameColumn', [], @(x) ~isempty(x) ...
            && isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvTagColumns', 2, @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) >= 1 && all(rem(x,1) == 0));
        parser.parse(tsvfile, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tsvhed2map