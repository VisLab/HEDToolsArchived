% Appends tag prefixes to a cell array of character vectors containing
% HED tags.
%
% Usage:
%
%   >>  tagPrefixMap = appendTagPrefixesToSpecificColumns(hedTagArray, ...
%    specificColumns)
%
% Input:
%
%   Required:
%
%   rowsArray
%                   A cell array containing the rows in a spreadsheet.
%
%   specificColumns
%                   A scalar structure used to specify the specific tag
%                   columns. The fieldnames need to be category
%                   corresponding to Event/Category, description
%                   corresponding to Event/Description, label corresponding
%                   to Event/Label, long corresponding to Event/ Long name.
%                   The field values are the column indices that contain
%                   the specific tags.
%
%                   Example:
%                   specificColumns.long = 2;
%                   specificColumns.description = 3;
%                   specificColumns.label = 4;
%
% (Optional)
%
%   'hasHeaders'
%                   True (default) if the spreadsheet has headers.
%                   The first row will not be validated otherwise it will
%                   and this can generate errors.
%
% Output:
%
%   hedTagArray
%                   A cell array of character vectors containing HED tags
%                   with prefixes prepended to them if needed.
%
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function rowsArray = appendHedTagPrefixes(rowsArray, specificColumns, ...
    varargin)
SPECIFIC_COLUMN_NAMES = {'long','description','label','category'};
SPECIFIC_COLUMN_PREFIXES = {'Event/Long name/','Event/Description/', ...
    'Event/Label/','Event/Category/'};
inputArgs = parseInputArguments(rowsArray, specificColumns, varargin{:});
tagPrefixMap = createTagPrefixMap(specificColumns);
rowsArray = appendPrefixesToSpecificColumns(inputArgs, rowsArray, ...
    tagPrefixMap);

    function rowsArray = appendPrefixesToSpecificColumns(inputArgs, ...
            rowsArray, tagPrefixMap)
        % Appends HED tag prefixes to specific columns that do not begin
        % with them.
        numRows = size(rowsArray, 1);
        numColumns = size(rowsArray, 2);
        startingRow = getStartingRow(inputArgs);
        for rowIndex = startingRow:numRows
            for columnIndex = 1:numColumns
                if columnNeedsPrefix(tagPrefixMap, columnIndex)
                    columnTags = rowsArray{rowIndex, columnIndex};
                    if ~isempty(columnTags)
                        prefix = tagPrefixMap(columnIndex);
                        splitColumnTags = appendPrefixToEveryColumnTag(...
                            columnTags, prefix);
                        rowsArray{rowIndex, columnIndex} = ...
                            strjoin(splitColumnTags, ',');
                    end
                end
            end
        end
    end % appendPrefixesToSpecificColumns

    function needsPrefix = columnNeedsPrefix(tagPrefixMap, columnIndex)
        % True if the column needs a prefix. False, if otherwise.
        needsPrefix = isKey(tagPrefixMap, columnIndex);
    end % columnNeedsPrefix

    function splitColumnTags = appendPrefixToEveryColumnTag(columnTags, ...
            prefix)
        % Appends the tag prefix to every tag in a particular column
        hedMaps = getHedMaps();
        prefixWithoutEndingPound = lower([prefix, '#']);
        if hedMaps.takesValue.isKey(prefixWithoutEndingPound)
            splitColumnTags{1} = [prefix, columnTags];
            return;
        end
        splitColumnTags = strsplit(columnTags, ',');
        numberOfColumnTags = length(splitColumnTags);
        for b = 1:numberOfColumnTags
            columnTag = splitColumnTags{b};
            if ~strncmpi(columnTag, prefix, length(columnTag))
                splitColumnTags{b} = [prefix, columnTag];
            end
        end
    end % appendPrefixToEveryColumnTag

    function tagPrefixMap = createTagPrefixMap(specificColumns)
        % Creates a dictionary containing a mapping of specific tag column
        % indices to tag prefixes.
        tagPrefixMap = containers.Map('KeyType', 'double', ...
            'ValueType', 'char');
        specificColumnNames = fieldnames(specificColumns);
        populateTagPrefixMap(tagPrefixMap, specificColumnNames, ...
            specificColumns);
    end % createTagPrefixMap

    function tagPrefixMap = populateTagPrefixMap(tagPrefixMap, ...
            specificColumnNames, specificColumns)
        % Populates the tag prefix Map
        numberOfSepecificColumns = length(specificColumnNames);
        for a = 1:numberOfSepecificColumns
            specificColumnIndex = find(strcmpi(SPECIFIC_COLUMN_NAMES, ...
                specificColumnNames{a}), 1);
            if ~isempty(specificColumnIndex)
                tagPrefixMap(specificColumns.(specificColumnNames{a})) = ...
                    SPECIFIC_COLUMN_PREFIXES{specificColumnIndex};
            end
        end
    end % populateTagPrefixMap

    function startingRow = getStartingRow(inputArgs)
        % Gets the starting row number for validation. If headers are
        % present then the validation skips the first row. 
        startingRow = 1;
        if inputArgs.hasHeaders
          startingRow = 2;  
        end
    end % getStartingRow

    function parsedArguments = parseInputArguments(rowsArray, ...
            specificColumns, varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('rowsArray', @iscell);
        parser.addRequired('specificColumns', @isstruct);
        parser.addParamValue('hasHeaders', true, @islogical);
        parser.parse(rowsArray, specificColumns, varargin{:});
        parsedArguments = parser.Results;
    end % parseInputArguments

end % appendHedTagPrefixes