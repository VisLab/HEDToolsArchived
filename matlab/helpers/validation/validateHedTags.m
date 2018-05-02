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
SPREADSHEET_FILE_EXTENSIONS = {'tsv', 'txt', 'xls', 'xlsx'};
EXCEL_FILE_EXTENSIONS = {'xls', 'xlsx'};
TSV_FILE_EXTENSIONS = {'tsv', 'txt'};
inputArgs = parseInputArguments(hedTagsInput, varargin{:});
[isValidSpreadsheet, extension] = isASpreadsheetWithValidExtension(...
    hedTagsInput, SPREADSHEET_FILE_EXTENSIONS);
if isValidSpreadsheet
    issues = validateHedTagsInSpreadsheet();
else
    issues = validateHedTagsInString();
end
hedTags = reportValidationIssues(inputArgs);

    function issues = validateHedTagsInSpreadsheet()
        % Validates the HED tags in a spreadsheet
    end % validateHedTagsInSpreadsheet

    function issues = getHedTagsBasedOnFileExtension(extension)
        % Gets the HED tags based on the spreadsheet file extension
        extension = isASpreadsheetWithValidExtension(...
    hedTagsInput, SPREADSHEET_FILE_EXTENSIONS);
    end % getHedTagsBasedOnFileExtensions

    function issues = validateHedTagsInString()
        % Validates the HED tags in a string
    end % validateHedTagsInString

    function [isValid, extension] = isASpreadsheetWithValidExtension(...
            hedTagsInput, validExtensions)
        % Returns true if the input is a spreadsheet with a valid
        % extension. False, if otherwise.
        splitInput = strsplit(hedTagsInput, '.');
        extension = lower(splitInput{end});
        isValid = ismember(extension, lower(validExtensions));
    end % isASpreadsheetWithValidExtension

    function inputArguments = parseInputArguments(hedtags, varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('hedTagsInput', @ischar);
        parser.addParamValue('generateWarnings', false, @islogical);
        parser.addParamValue('hasHeaders', true, @islogical);
        parser.addParamValue('otherColumns', [], @isnumeric);
        parser.addParamValue('specificColumns', [], @isstruct);
        parser.addParamValue('worksheet', '', @ischar);
        parser.parse(hedtags, varargin{:});
        inputArguments = parser.Results;
    end % parseInputArguments

end % validateworksheethedtags