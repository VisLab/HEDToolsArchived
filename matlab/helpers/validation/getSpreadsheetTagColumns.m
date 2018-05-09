% Gets the tag columns. These consist of the other columns and specific
% columns.
%
% Usage:
%
%   >>  tagColumns = getSpreadsheetTagColumns(otherColumns, ...
%       specificColumns, spreadsheetColumnCount)
%
% Input:
%
%   Required:
%
%   otherColumns
%                   An integer array consisting of column indices that
%                   contain the other columns.
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
%   Optional:
%
%   spreadsheetColumnCount
%                   The spreadsheet column count. Any other columns and
%                   specific columns greater than this count will be
%                   excluded.
%
% Output:
%
%   tagPrefixMap
%                   A dictionary containing a mapping of specific tag
%                   column indices to tag prefixes.
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

function tagColumns = getSpreadsheetTagColumns(otherColumns, ...
    specificColumns, spreadsheetColumnCount)
inputArguments = parseInputArguments(otherColumns, specificColumns, ...
    spreadsheetColumnCount);
tagColumns = 2;
if tagColumnsAreSpecified(otherColumns, specificColumns)
    tagColumns = getTagColumnsFromInputArguments(inputArguments);
end


    function inputArguments = parseInputArguments(otherColumns, ...
            specificColumns, spreadsheetColumnCount)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('otherColumns', @isnumeric);
        parser.addRequired('specificColumns', @isstruct);
        parser.addOptional('spreadsheetColumnCount', [], @isnumeric);
        parser.parse(otherColumns, specificColumns, ...
            spreadsheetColumnCount);
        inputArguments = parser.Results;
    end % parseInputArguments

    function tagColumnIndices = getTagColumnsFromInputArguments(...
            inputArguments)
        % Get tag indices from tag columns input argument. Any column
        % indices greater than the number of actual columns in the
        % spreadsheet will be removed.
        specificColumnIndices = ...
            getSpecificColumnsFromInputArguments(inputArguments);
        tagColumnIndices = ...
            [inputArguments.otherColumns specificColumnIndices];
        if ~isempty(inputArguments.spreadsheetColumnCount)
            tagColumnIndices = ...
                find(ismember(1:inputArguments.spreadsheetColumnCount, ...
                [inputArguments.otherColumns specificColumnIndices]));
        end
    end % getTagColumnIndicesFromInputArgument

    function specificColumns = getSpecificColumnsFromInputArguments(...
            inputArguments)
        % Get specific indices from tag columns input argument.
        specificColumnNames = fieldnames(inputArguments.specificColumns);
        numberOfSepecificColumns = length(specificColumnNames);
        specificColumns = zeros(1, numberOfSepecificColumns);
        for a = 1:numberOfSepecificColumns
            specificColumns(a) = ...
                inputArguments.specificColumns.(specificColumnNames{a});
        end
    end % getSpecificColumnsFromInputArguments

    function specified = tagColumnsAreSpecified(otherColumns, ...
            specificColumns)
        % Returns true if no columns are specified
        specified = ~isempty(otherColumns) || ...
            ~isempty(fieldnames(specificColumns));
    end % tagColumnsAreSpecified

end % getSpreadsheetTagColumns
