% This function takes in a HED string or path to a spreadsheet and
% validates the HED tags.
%
% Usage:
%
%   >>  issues = validateHedTags(hedTagsInput)
%
%   >>  issues = validateHedTags(hedTagsInput, varargin)
%
% Input:
%
%   Required:
%
%   hedTagsInput
%                   A string or path to a spreadsheet containing HED tags
%                   that need to be validated.
%
% Optional:
%
%   'missingRequiredTagsAreErrors'
%                   If true, treat missing required tags as a warning. If
%                   false (default). treat missing required tags as a
%                   error.
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
%                   True (default) if the spreadsheet has headers.
%                   The first row will not be validated otherwise it will
%                   and this can generate errors.
%
%   'otherColumns'
%                   The other column indices where the HED tags are in the
%                   workbook worksheet.
%
%   'worksheetName'
%                   The name of the workbook worksheet that you want to
%                   validate. If no worksheet is specified then the first
%                   workbook worksheet will be validated.
%
% Output:
%
%   worksheetTags
%                   A cell array containing the HED tags in the Excel
%                   worksheet.
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

function issues = validateHedTags(hedTagsInput, varargin)
inputArgs = parseInputArguments(hedTagsInput, varargin{:});
hedMaps = getHedMaps(inputArgs.hedXml);
inputArgs.tagValidatorRunner = TagValidatorRunner(hedMaps);
hedFileExtension = HedFileExtension(inputArgs.hedTagsInput);
if hedFileExtension.hasSpreadsheetExtension
    issues = validateHedTagsInSpreadsheet(inputArgs);
else
    issues = validateHedTagsInString(inputArgs);
end

    function issues = validateRowHedTags(inputArgs, rowHedString, ...
            rowNumber)
        % Validates the HED tags in a spreadsheet row.
        issues = '';
        hedStringDelimiter = HedStringDelimiter(rowHedString);
        issues = validateTopLevelTags(inputArgs, hedStringDelimiter, ...
            issues);
        issues = validateTagLevelTags(inputArgs, hedStringDelimiter, ...
            issues);
        if ~isempty(issues)
            issues = generateRowIssueMessage(rowNumber, issues);
        end
    end % validateRowHedTags

    function issues = validateRowColumnHedTags(inputArgs, ...
            rowColumnHedString, rowNumber, columnNumber)
        % Validates the HED tags in a spreadsheet row.
        hedStringDelimiter = HedStringDelimiter(rowColumnHedString);
        issues = inputArgs.tagValidatorRunner.runHedStringValidator(...
            inputArgs.hedTagsInput);
        if isempty(issues)
            issues = validateIndividualTags(inputArgs, ...
                hedStringDelimiter, issues);
            issues = validateTagGroups(inputArgs, hedStringDelimiter, ...
                issues);
            if ~isempty(issues)
                issues = generateRowColumnIssueMessage(rowNumber, ...
                    columnNumber, issues);
            end
        end
    end % validateRowHedTags

    function issue = generateRowIssueMessage(rowNumber, issues)
        % Generates a row issue
        issue = [errorReporter('row', 'errorRow', rowNumber) issues];
    end % generateRowIssueMessage

    function issue = generateRowColumnIssueMessage(rowNumber, ...
            columnNumber, issues)
        % Generates a row issue
        issue = [errorReporter('column', 'errorRow', rowNumber, ...
            'errorColumn', columnNumber) issues];
    end % generateRowIssueMessage

    function issues = validateHedTagsInSpreadsheet(inputArgs)
        % Validates the HED tags in a spreadsheet
        rowsArray = putSpreadSheetRowsInCellArray(...
            inputArgs.hedTagsInput, 'worksheetName', ...
            inputArgs.worksheetName);
        rowsArray = appendHedTagPrefixes(rowsArray, ...
            inputArgs.specificColumns);
        columnCount = size(rowsArray, 2);
        tagColumns = getSpreadsheetTagColumns(inputArgs.otherColumns, ...
            inputArgs.specificColumns, columnCount);
        issues = validateHedTagsInSpreadsheetRows(inputArgs, rowsArray, ...
            tagColumns);
    end % validateHedTagsInSpreadsheet

    function startingRow = getStartingRow(inputArgs)
        % Gets the starting row number for validation. If headers are
        % present then the validation skips the first row. 
        startingRow = 1;
        if inputArgs.hasHeaders
          startingRow = 2;  
        end
    end % getStartingRow

    function issues = validateHedTagsInSpreadsheetRows(inputArgs, ...
            rowsArray, tagColumns)
        % Validates the HED tags in each row of the spreadsheet.
        issues = '';
        rowCount = size(rowsArray, 1);
        tagColumnCount = length(tagColumns);
        startingRow = getStartingRow(inputArgs);
        for rowIndex = startingRow:rowCount
            rowHedString = concatHedTagsInCellArray(...
                rowsArray(rowIndex, :), tagColumns);
            if ~isempty(rowHedString)
                issues = [issues ...
                    validateRowHedTags(inputArgs, rowHedString, rowIndex)];
                for tagColumnIndex = 1:tagColumnCount
                    rowColumnHedString = rowsArray{rowIndex, ...
                        tagColumns(tagColumnIndex)};
                    issues = [issues validateRowColumnHedTags(...
                        inputArgs, rowColumnHedString, rowIndex, ...
                        tagColumns(tagColumnIndex))];
                end
            end
        end
    end % validateHedTagsInSpreadsheetRows

    function issues = validateHedTagsInString(inputArgs)
        % Validates the HED tags in a string
        hedStringDelimiter = HedStringDelimiter(inputArgs.hedTagsInput);
        issues = inputArgs.tagValidatorRunner.runHedStringValidator(...
            inputArgs.hedTagsInput);
        if isempty(issues)
            issues = validateTopLevelTags(inputArgs, ...
                hedStringDelimiter, issues);
            issues = validateTagLevelTags(inputArgs, ...
                hedStringDelimiter, issues);
            issues = validateTagGroups(inputArgs, hedStringDelimiter, ...
                issues);
            issues = validateIndividualTags(inputArgs, ...
                hedStringDelimiter, issues);
        end
    end % validateHedTagsInString

    function issues = validateTopLevelTags(inputArgs, ...
            hedStringDelimiter, issues)
        % Validates the top-level tags
        formattedTopLevelTags = ...
            hedStringDelimiter.getFormattedTopLevelTags();
        issues = [issues ...
            inputArgs.tagValidatorRunner.runTopLevelValidators(...
            formattedTopLevelTags, inputArgs.generateWarnings, ...
            inputArgs.missingRequiredTagsAreErrors)];
    end % validateTopLevelTags

    function issues = validateTagGroups(inputArgs, hedStringDelimiter, ...
            issues)
        % Validates the top-level tags
        tagGroups = hedStringDelimiter.getGroupTags();
        numGroups = length(tagGroups);
        for groupIndex = 1:numGroups
            issues = [issues ...
                inputArgs.tagValidatorRunner.runTagGroupValidators(...
                tagGroups{groupIndex})];
        end
    end % validateTagGroups

    function issues = validateIndividualTags(inputArgs, ...
            hedStringDelimiter, issues)
        % Validates the top-level tags
        tags = hedStringDelimiter.getUniqueTags();
        formattedTags = hedStringDelimiter.getFormattedUniqueTags();
        numTags = length(tags);
        for tagIndex = 1:numTags
            previousOriginalTag = getPreviousTag(tags, tagIndex);
            previousFormattedTag = getPreviousTag(formattedTags, tagIndex);
            issues = [issues ...
                inputArgs.tagValidatorRunner.runIndividualTagValidators(...
                tags{tagIndex}, formattedTags{tagIndex}, ...
                previousOriginalTag, previousFormattedTag, ...
                inputArgs.generateWarnings)];
        end
    end % validateTagGroups

    function previousTag = getPreviousTag(tags, currentIndex)
        % Gets the previous tag. 
        previousTag = '';
        if currentIndex > 1
            previousTag = tags{currentIndex-1};
        end       
    end % getPreviousTag

    function issues = validateTagLevelTags(inputArgs, ...
            hedStringDelimiter, issues)
        % Validates tags at each level
        topLevelTags = ...
            hedStringDelimiter.getTopLevelTags();
        formattedTopLevelTags = ...
            hedStringDelimiter.getFormattedTopLevelTags();
        issues = [issues ...
            inputArgs.tagValidatorRunner.runTagLevelValidators(...
            topLevelTags, formattedTopLevelTags)];
        groupTags = ...
            hedStringDelimiter.getGroupTags();
        formattedGroupTags = ...
            hedStringDelimiter.getFormattedGroupTags();
        numGroup = length(groupTags);
        for groupIndex = 1:numGroup
            issues = [issues ...
                inputArgs.tagValidatorRunner.runTagLevelValidators(...
                groupTags{groupIndex}, formattedGroupTags{groupIndex})];
        end
    end % validateTopLevelTags

    function inputArguments = parseInputArguments(hedtags, varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('hedTagsInput', @ischar);
        parser.addParamValue('generateWarnings', false, @islogical);
        parser.addParamValue('hasHeaders', true, @islogical);
        parser.addParamValue('hedXml',  '', @(x) ~isempty(x) && ischar(x));
        parser.addParamValue('leafExtensions', false, @islogical);
        parser.addParamValue('otherColumns', [], @isnumeric);
        parser.addParamValue('missingRequiredTagsAreErrors', true, ...
            @islogical);
        parser.addParamValue('specificColumns', struct, @isstruct);
        parser.addParamValue('worksheetName', '', @ischar);
        parser.parse(hedtags, varargin{:});
        inputArguments = parser.Results;
    end % parseInputArguments

end % validateworksheethedtags