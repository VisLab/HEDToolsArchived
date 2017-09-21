% This function validates the HED tags in a Excel workbook worksheet
% against a HED schema.
%
% Usage:
%
%   >>  issues = validateworksheethedtags(workbook)
%
%   >>  issues = validateworksheethedtags(workbook, varargin)
%
% Input:
%
%   Required:
%
%   workbook
%                   The full path of an Excel Workbook file containing a
%                   worksheet with HED tags in a single column or multiple
%                   columns.
%
% Optional:
%
%   'addPrefixes'
%                   True (default) to add tag prefixes to columns with
%                   specific names. These columns names are 'Long name',
%                   'Description', 'Label', 'Category', ...
%                   'Event details', and 'Attribute' which are case
%                   insensitive. The 'Event/Long name/' prefix is
%                   added to the 'Long Name' column, the 
%                   'Event/Description/' prefix is added to the
%                   'Description' column, the 'Event/Label/' prefix is
%                   added to the 'Label' column, the 'Event/Category/'
%                   prefix is added to the 'Category' column, and the
%                   'Attribute/' prefix is added to the 'Attribute' column.
%
%   'generateWarnings'
%                   True to include warnings in the log file in addition
%                   to errors. If false (default) only errors are included
%                   in the log file.
%
%   'hasHeaders'
%                   True (default) if the workbook worksheet has headers.
%                   The first row will not be validated otherwise it will
%                   and this can generate errors.
%
%   'tagColumns'
%                   The column indices where the HED tags are in the
%                   workbook worksheet.
%
%   'worksheet'
%                   The name of the workbook worksheet that you want to
%                   validate. If no worksheet is specified then the first
%                   workbook worksheet will be validated. 
%
% Output:
%
%   issues
%                   A cell array containing all of the issues found through
%                   the validation. Each cell corresponds to the issues
%                   found on a particular line.
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

function issues = validateworksheethedtags(workbook, varargin)
COLUMN_NAMES = {'long name','description','label','category', ...
    'event details','attribute'};
TAG_PREFIXES = {'Event/Long name/','Event/Description/', ...
    'Event/Label/','Event/Category/', '', 'Attribute/'};
inputArguments = parseInputArguments(workbook, varargin{:});
issues = reportValidationIssues(inputArguments);

    function issues = reportValidationIssues(inputArguments)
        % Validate the HED tags in the file and report any issues
        hedMaps = loadHedTagMaps();
        worksheetTags = getWorksheetTagsForEachRow(inputArguments);
        numberOfWorksheetRows = size(worksheetTags, 1);
        issues = cell(1, numberOfWorksheetRows);
        rowNumber = getFirstRowNumberForValidation(inputArguments);
        for a = rowNumber:numberOfWorksheetRows
            issue = parsestr(hedMaps, worksheetTags{a}, ...
                inputArguments.generateWarnings);
            if ~isempty(issue)
                issues{a} = sprintf('Issues in row %d:\n%s', a, issue);
            end
        end
        issues = removeEmptyCellsInIssuesArray(issues);
    end % reportValidationIssues

    function issues = removeEmptyCellsInIssuesArray(issues)
        % Remove empty cells in issues cell array
        issues = issues(~cellfun(@isempty, issues));
    end % removeEmptyCellsInIssuesArray

    function rowNumber = getFirstRowNumberForValidation(inputArguments)
        % Gets the first row number for validation based on the file having
        % a header or not
        rowNumber = 1;
        if inputArguments.hasHeaders
            rowNumber = 2;
        end
    end % getFirstRowNumberForValidation
    
    function worksheetTags = getWorksheetTagsForEachRow(inputArguments)
        % Gets hed tags in excel worksheet for each row
        inputArguments.worksheetData = ...
            putWorksheetDataInCellArray(inputArguments);
        inputArguments.tagColumnIndices = ...
            getTagColumnIndices(inputArguments);
        if tagPrefixesNeedToBeAdded(inputArguments)
            inputArguments = addTagPrefixesToColumns(inputArguments);
        end
        worksheetTags = appendTagsTogetherInEachRow(inputArguments);
    end % getWorksheetTagsForEachRow

    function needToBeAppended = tagPrefixesNeedToBeAdded(inputArguments)
        % Returns true if tag prefixes need to be added to tag columns
        needToBeAppended = inputArguments.hasHeaders && ...
            inputArguments.addPrefixes;
    end % tagPrefixesNeedToBeAdded

    function tagColumnIndices = getTagColumnIndices(inputArguments)
        % Get the tag column indices from the number of columns actually
        % present in the worksheet
        if tagColumnsIsSpecified(inputArguments)
            tagColumnIndices = ...
                getTagColumnIndicesFromInputArgument(inputArguments);
        else
            tagColumnIndices = getDefaultTagColumnIndices(inputArguments);
        end
    end % getTagColumnIndices

    function tagColumnIndices = ...
            getTagColumnIndicesFromInputArgument(inputArguments)
        % Get tag indices from tag columns input argument. Any column
        % indices greater than the number of actual columns in the
        % worksheet will be removed.
        tagColumnIndices = ...
            ismember(1:size(inputArguments.worksheetData, 2), ...
            inputArguments.tagColumns);
    end % getTagColumnIndicesFromInputArgument

    function tagColumnIndices = getDefaultTagColumnIndices(inputArguments)
        % Get tag indices when no tag columns are specified. The indices
        % will be 2 to the number of columns in the worksheet.
        tagColumnIndices = [0, ones(1, ...
            size(inputArguments.worksheetData, 2)-1)];
    end % getDefaultTagColumnIndices

    function noneSpecified = tagColumnsIsSpecified(inputArguments)
        % Returns true if no columns are specified
        noneSpecified = ~isempty(inputArguments.tagColumns);
    end % tagColumnsIsSpecified

    function worksheetData = putWorksheetDataInCellArray(inputArguments)
        % Read workbook worksheet and put the data into a cell array.
        if isempty(inputArguments.worksheet)
            [~, worksheetData] = xlsread(inputArguments.workbook);
        else
            [~, worksheetData] = xlsread(inputArguments.workbook, ...
                inputArguments.worksheet);
        end
    end % putWorksheetDataInCellArray

    function worksheetTags = appendTagsTogetherInEachRow(inputArguments)
        % Append worksheet tags in tag columns together for each line
        numberOfRows = size(inputArguments.worksheetData,1);
        worksheetTags = cell(numberOfRows, 1);
        for rowNumber = 1:numberOfRows
            nonEmptyTagIndices = ...
                findNonEmptyTagIndicesInRow(inputArguments, rowNumber);
            worksheetTags{rowNumber} = appendTagsInRow(inputArguments, ...
                rowNumber, nonEmptyTagIndices);
        end
    end % appendTagsTogetherInEachRow

    function appendedTags = appendTagsInRow(inputArguments, rowNumber, ...
            nonEmptyTagIndices)
        % Append tags together in a particular worksheet row
        appendedTags = strjoin(inputArguments.worksheetData(rowNumber, ...
            nonEmptyTagIndices), ',');
    end % appendTagsInRow

    function nonEmptyTagIndices = ...
            findNonEmptyTagIndicesInRow(inputArguments, rowNumber)
        % Finds the non-empty tag indices in a particular worksheet row
        nonEmptyTagIndices = ~cellfun(@isempty, ...
            inputArguments.worksheetData(rowNumber, :)) & ...
            inputArguments.tagColumnIndices;
    end % findNonEmptyTagIndicesInRow

    function inputArguments = addTagPrefixesToColumns(inputArguments)
        % Add tag prefixes to columns that have specific names
        inputArguments = createTagColumnPrefixMap(inputArguments);
        inputArguments = findTagPrefixIndicesInWorksheet(inputArguments);
        numberOfPrefixMapKeyIndices = ...
            length(inputArguments.prefixMapKeyIndices);
        for keyIndice = 1:numberOfPrefixMapKeyIndices
            if inputArguments.prefixMapKeyIndices(keyIndice) > 0
                inputArguments = addTagPrefixesToColumn(inputArguments, ...
                    keyIndice);
            end
        end
        inputArguments = intersectTagAndPrefixTagIndices(inputArguments);
    end % addTagPrefixesToColumns

    function inputArguments = ...
            intersectTagAndPrefixTagIndices(inputArguments)
        % Intersect the tag column indices and the tag prefix column
        % indices
        inputArguments.tagColumnIndices = ...
            inputArguments.tagColumnIndices & ...
            inputArguments.prefixTagColumnIndices;
    end % intersectTagAndPrefixTagIndices

    function inputArguments = ...
            findTagPrefixIndicesInWorksheet(inputArguments)
        % Find tag prefix column indices in a workseet and in tag prefix 
        % Map
        [inputArguments.prefixTagColumnIndices, ...
            inputArguments.prefixMapKeyIndices] = ...
            ismember(lower(inputArguments.worksheetData(1,:)), ...
            inputArguments.tagColumnPrefixMapKeys);
    end % findTagPrefixIndicesInWorksheet

    function inputArguments = addTagPrefixesToColumn(inputArguments, ...
            keyIndice)
        % Add tag prefixes to a particular column in a worksheet
        tagPrefix = inputArguments.tagColumnPrefixMap(...
            inputArguments.tagColumnPrefixMapKeys{...
            inputArguments.prefixMapKeyIndices(keyIndice)});
        inputArguments.worksheetData = ...
            prependStrToCellstrColumn(inputArguments.worksheetData, ...
            tagPrefix, keyIndice);
    end % addTagPrefixesToColumn

    function cellArray = prependStrToCellstrColumn(cellArray, str, ...
            columnIndex)
        % Prepend a string to a particular column index in a cell string
        % array
        nonEmptyIndices = ~cellfun(@isempty, cellArray(:, columnIndex));
        cellArray(nonEmptyIndices, columnIndex) = strcat(str, ...
            cellArray(nonEmptyIndices, columnIndex));
    end % prependStrToCellstrColumn

    function hedMaps = loadHedTagMaps()
        % Loads a structure full of Maps containings all of the HED tags
        % and their attributes
        Maps = load('HEDMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHedTagMaps

    function inputArguments = createTagColumnPrefixMap(inputArguments)
        % Create a Map containing tag column to tag prefix pairs
        inputArguments.tagColumnPrefixMap = ...
            containers.Map(COLUMN_NAMES, TAG_PREFIXES);
        inputArguments.tagColumnPrefixMapKeys = ...
            inputArguments.tagColumnPrefixMap.keys();
    end % createTagColumnPrefixMap

    function inputArguments = parseInputArguments(hedtags, varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('workbook', @ischar);
        parser.addParamValue('addPrefixes', true, @islogical);
        parser.addParamValue('generateWarnings', false, @islogical);
        parser.addParamValue('hasHeaders', true, @islogical);
        parser.addParamValue('tagColumns', [], @isnumeric);
        parser.addParamValue('worksheet', '', @ischar);
        parser.parse(hedtags, varargin{:});
        inputArguments = parser.Results;
    end % parseInputArguments

end % validateworksheethedtags