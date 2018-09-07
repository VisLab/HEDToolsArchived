% This function puts all the spreadsheet rows in a cell array.
%
% Usage:
%
%   >>  rowsArray = putSpreadSheetRowsInCellArray(spreadsheetPath)
%
%   >>  rowsArray = putSpreadSheetRowsInCellArray(...
%                         spreadsheetPath, varargin)
%
% Input:
%
%   spreadsheetPath
%                   The path to a spreadsheet containing HED tags in a
%                   single column or multiple columns.
%
% Input (Optional):
%
%   worksheetName
%                   The name of the worksheet if the spreadsheet is in an
%                   Excel workbook.
%
% Output:
%
%   rowsArray
%                   A cell array containing the rows in a spreadsheet.
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function rowsArray = putSpreadSheetRowsInCellArray(spreadsheetPath, ...
    varargin)

inputArgs = parseInputArguments(spreadsheetPath, varargin{:});
rowsArray = getRowsBasedOnFileExtension(inputArgs);

    function rowsArray = getRowsBasedOnFileExtension(inputArgs)
        % Gets the rows in a spreadsheet based on the extension
        hedFileExtension = HedFileExtension(inputArgs.spreadsheetPath);
        if hedFileExtension.hasExcelExtension
            rowsArray = putWorksheetRowsInCellArray(inputArgs);
        elseif hedFileExtension.hasTsvExtension
            rowsArray = putTsvRowsInCellArray(inputArgs);
        else
            rowsArray = {};
        end
    end % getRowsBasedOnFileExtension

    function inputArgs = parseInputArguments(spreadsheetPath, varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('spreadsheetPath', @ischar);
        parser.addParamValue('worksheetName', '', @ischar); %#ok<NVREPL>
        parser.parse(spreadsheetPath, varargin{:});
        inputArgs = parser.Results;
    end % parseInputArguments

    function rowsArray = putTsvRowsInCellArray(inputArgs)
        % Reads the tab-delimited file line by line and puts each row in a
        % cell array
        rowsArray = {};
        rowNumber = 1;
        try
            fileId = fopen(inputArgs.spreadsheetPath);
            currentRow = getNextRow(fileId);
            while ~isempty(currentRow)
                rowsArray(rowNumber,:) = currentRow;  %#ok<AGROW>
                currentRow = getNextRow(fileId);
                rowNumber = rowNumber + 1;
            end
            fclose(fileId);
        catch
            fclose(fileId);
            throw(MException('validateTsvHedTags:cannotRead', ...
                'Unable to read TSV file on line %d', rowNumber));
        end
    end % putTsvSpreadSheetRowsInCellArray

    function cellArray = putWorksheetRowsInCellArray(inputArgs)
        % Read workbook worksheet and put the data into a cell array.
        if isempty(inputArgs.worksheetName)
            [~, cellArray] = xlsread(inputArgs.spreadsheetPath);
        else
            [~, cellArray] = xlsread(inputArgs.spreadsheetPath, ...
                inputArgs.worksheetName);
        end
    end % putWorksheetDataInCellArray

    function nextRowArray = getNextRow(fileId)
        % Gets the next row string and puts it in a cell array
        nextRow = fgetl(fileId);
        nextRowArray = putNextRowInCellArray(nextRow);     
    end % getNextRow

    function nextRowArray = putNextRowInCellArray(nextRow)
        % Puts the next row in a cell array 
        nextRowArray = {};
        if ischar(nextRow)
            nextRowArray = textscan(nextRow, '%q', 'delimiter', '\t');
            nextRowArray = nextRowArray{:};
        end
    end % putNextRowInCellArray

end % putSpreadSheetRowsInCellArray