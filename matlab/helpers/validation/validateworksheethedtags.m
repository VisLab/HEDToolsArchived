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
%   'specificColumns'
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
%   'otherColumns'
%                   The other column indices where the HED tags are in the
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

function worksheetTags = validateworksheethedtags(workbook, varargin)

inputArgs = parseInputArguments(workbook, varargin{:});
worksheetTags = reportValidationIssues(inputArgs);

    function worksheetRows = reportValidationIssues(inputArgs)
        % Validate the HED tags in the file and report any issues
        %         hedMaps = loadHedTagMaps();
        
        %         inputArgs.tagColumns = getTagColumns(inputArgs);
        worksheetRows = getWorksheetRows(inputArgs);
        numberOfColumns = size(worksheetRows, 2);
        tagColumns = getSpreadsheetTagColumns(inputArgs.otherColumns, ...
            inputArgs.specificColumns, numberOfColumns);
        numberOfWorksheetRows = size(worksheetRows, 1);
        rowNumber = getFirstRowNumberForValidation(inputArgs.hasHeaders);
        for a = rowNumber:numberOfWorksheetRows
            if ~isempty(inputArgs.specificColumns)
                worksheetRows(a,:) = appendTagPrefixes(worksheetRows(a,:), ...
                    inputArgs.specificColumns);
            end
        end
        %         numberOfWorksheetRows = size(worksheetTags, 1);
        %         issues = cell(1, numberOfWorksheetRows);
        %         rowNumber = getFirstRowNumberForValidation(inputArguments);
        %         for a = rowNumber:numberOfWorksheetRows
        %             issue = parsehedstr(hedMaps, worksheetTags{a}, ...
        %                 inputArguments.generateWarnings);
        %             if ~isempty(issue)
        %                 issues{a} = sprintf('Issues in row %d:\n%s', a, issue);
        %             end
        %         end
        %         issues = removeEmptyCellsInIssuesArray(issues);
    end % reportValidationIssues

    function rowNumber = getFirstRowNumberForValidation(hasHeaders)
        % Gets the first validation row number. If there are headers this
        % row will be skipped.
        rowNumber = 1;
        if hasHeaders
            rowNumber = 2;
        end
    end % checkFileHeader

    function issues = removeEmptyCellsInIssuesArray(issues)
        % Remove empty cells in issues cell array
        issues = issues(~cellfun(@isempty, issues));
    end % removeEmptyCellsInIssuesArray

    function worksheetRows = getWorksheetRows(inputArguments)
        % Gets the worksheet rows
        %         inputArguments.worksheetData = putWorksheetDataInCellArray(...
        %             inputArguments);
        worksheetRows = putWorksheetDataInCellArray(inputArguments);
        %         if ~isempty(inputArguments.specificColumns)
        %             inputArguments = addTagPrefixesToColumns(inputArguments);
        %         end
        %         worksheetTags = appendTagsTogetherInEachRow(inputArguments);
    end % getWorksheetTagsForEachRow





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

    function nonEmptyTagIndices = findNonEmptyTagIndicesInRow(...
            inputArguments, rowNumber)
        % Finds the non-empty tag indices in a particular worksheet row
        nonEmptyTagIndices = ~cellfun(@isempty, ...
            inputArguments.worksheetData(rowNumber, :)) & ...
            inputArguments.tagColumns;
    end % findNonEmptyTagIndicesInRow

    function inputArguments = addTagPrefixesToColumns(inputArguments)
        % Add tag prefixes to columns that have specific names
        inputArguments = createSpecificColumnPrefixMap(inputArguments);
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
        inputArguments.tagColumns = ...
            inputArguments.tagColumns & ...
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

    function inputArguments = createSpecificColumnPrefixMap(inputArguments)
        % Create a Map containing specific column to prefix pairs
        inputArguments.tagColumnPrefixMap = ...
            containers.Map(SPECIFIC_COLUMN_NAMES, SPECIFIC_COLUMN_PREFIXES);
        inputArguments.tagColumnPrefixMapKeys = ...
            inputArguments.tagColumnPrefixMap.keys();
    end % createSpecificColumnPrefixMap

    function inputArguments = parseInputArguments(hedtags, varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('workbook', @ischar);
        parser.addParamValue('addPrefixes', true, @islogical);
        parser.addParamValue('generateWarnings', false, @islogical);
        parser.addParamValue('hasHeaders', true, @islogical);
        parser.addParamValue('otherColumns', [], @isnumeric);
        parser.addParamValue('specificColumns', [], @isstruct);
        parser.addParamValue('worksheet', '', @ischar);
        parser.parse(hedtags, varargin{:});
        inputArguments = parser.Results;
    end % parseInputArguments

end % validateworksheethedtags