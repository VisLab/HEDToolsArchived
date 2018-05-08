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
%                   True (default) if the workbook worksheet has headers.
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

    function validateRowHedTags(rowHedTags, rowNumber, tagColumns)
        numTagColumns = length(tagColumns);
        for tagColumnIndex = 1:numTagColumns
            
            
        end
    end

    function validateRowColumnHedTags()
        
    end


    function issues = validateHedTagsInSpreadsheet(inputArgs)
        % Validates the HED tags in a spreadsheet
        rowsArray = putSpreadSheetRowsInCellArray(inputArgs.hedTagsInput, ...
            inputArgs.worksheet);
        rowCount = size(rowsArray, 1);
        columnCount = size(rowsArray, 2);
        tagColumns = getSpreadsheetTagColumns(inputArgs.otherColumns, ...
            inputArgs.specificColumns, columnCount);
        for rowIndex = 1:rowCount
            
        end
    end % validateHedTagsInSpreadsheet

    function tags = splitHedTagsIntoCellArraysByLevel(tags, hedString)
        % Split the HED string tags into cell arrays containing the
        % top-level tags, group tags, and all the tags within a structure
        tags.allTags = hed2cell(lower(hedString), true);
        tags.topLevelTags = tags.allTags(cellfun(@ischar, tags.allTags));
        tags.groupTags = tags.allTags(cellfun(@iscell, tags.allTags));
        if ~iscellstr(tags.allTags)
            tags.allTags = [tags.allTags{:}];
        end
    end % splitHedTagsIntoCellsByLevel

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
        end
    end % validateHedTagsInString

    function issues = validateTopLevelTags(inputArgs, ...
            hedStringDelimiter, issues)
        % Validates the top-level tags
        formattedTopLevelTags = ...
            hedStringDelimiter.getFormattedTopLevelTags();
        issues = [issues ...
            inputArgs.tagValidatorRunner.runTopLevelValidators(...
            formattedTopLevelTags, inputArgs.missingRequiredTagsAreErrors)];
    end % validateTopLevelTags

    function issues = validateTagGroups(inputArgs, hedStringDelimiter, issues)
        % Validates the top-level tags
        groupTags = hedStringDelimiter.getGroupTags();
        issues = [issues ...
            inputArgs.tagValidatorRunner.runTagGroupValidators(...
            groupTags)];
    end % validateTagGroups

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
        parser.addParamValue('otherColumns', [], @isnumeric);
        parser.addParamValue('missingRequiredTagsAreErrors', false, ...
            @islogical);
        parser.addParamValue('specificColumns', [], @isstruct);
        parser.addParamValue('worksheetName', '', @ischar);
        parser.parse(hedtags, varargin{:});
        inputArguments = parser.Results;
    end % parseInputArguments

end % validateworksheethedtags