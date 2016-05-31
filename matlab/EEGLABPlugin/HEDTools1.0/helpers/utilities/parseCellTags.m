% This function takes in a cell array of HED tags associated with a
% particular study and validates them based on the tags and attributes in
% the HED XML file.
%
% Usage:
%
%   >>  [errors, warnings, extensions] = parseCellTags(hedMaps, ...
%       extensionAllowed);
%
% Input:
%
%       hedMaps
%                   A structure that contains Maps associated with the HED
%                   XML tags. There is a map that contains all of the HED
%                   tags, a map that contains all of the unit class units,
%                   a map that contains the tags that take in units, a map
%                   that contains the default unit used for each unit
%                   class, a map that contains the tags that take in
%                   values, a map that contains the tags that are numeric,
%                   a map that contains the required tags, a map that
%                   contains the tags that require children, a map that
%                   contains the tags that are extension allowed, and map
%                   that contains the tags are are unique.
%
%       extensionAllowed
%                   True(default) if the validation accepts extension
%                   allowed tags. There will be warnings generated for each
%                   extension allowed tag that is present. If false, the
%                   validation will not accept extension allowed tags and
%                   errors will be generated for each tag present.
%
% Output:
%
%       errors
%                   A cell array containing all of the validation errors.
%                   Each cell is associated with the validation errors on a
%                   particular line.
%
%       warnings
%                   A cell array containing all of the validation warnings.
%                   Each cell is associated with the validation warnings on
%                   a particular line.
%
%       extensions
%                   A cell array containing all of the extension allowed
%                   validation warnings. Each cell is associated with the
%                   extension allowed validation warnings on a particular
%                   line.
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

function [errors, warnings, extensions, uniqueErrorTags] = ...
    parseCellTags(hedMaps, cells, extensionAllowed)
p = parseArguments();
errors = {};
warnings = {};
extensions = {};
uniqueErrorTags = {};
errorCount = 1;
warningCount = 1;
extensionCount = 1;
parseCells();

    function checkForCellErrors(originalTags, formattedTags, cellNumber)
        % Errors will be generated for the cell if found
        [cellErrors, cellErrorTags] = ...
            checkForValidationErrors(p.hedMaps, originalTags, ...
            formattedTags, p.extensionAllowed);
        if ~isempty(cellErrors)
            cellErrors = [generateErrorMessage('cell', cellNumber, ...
                '', '', ''), cellErrors];
            errors{errorCount} = cellErrors;
            uniqueErrorTags = union(uniqueErrorTags, cellErrorTags);
            errorCount = errorCount + 1;
        end
    end % checkForCellErrors

    function checkForCellExtensions(originalTags, formattedTags, ...
            cellNumber)
        % Errors will be generated for the cell if found
        cellExtensions = checkForValidationExtensions(p.hedMaps, ...
            originalTags, formattedTags, p.extensionAllowed);
        if ~isempty(cellExtensions)
            cellExtensions = [generateExtensionMessage('cell', ...
                cellNumber, '', ''), cellExtensions];
            extensions{extensionCount} = cellExtensions;
            extensionCount = extensionCount + 1;
        end
    end % checkForCellExtensions

    function checkForCellWarnings(originalTags, formattedTags, ...
            cellNumber)
        % Warnings will be generated for the cell if found
        cellWarnings = checkForValidationWarnings(p.hedMaps, ...
            originalTags, formattedTags);
        if ~isempty(cellWarnings)
            cellWarnings = [generateWarningMessage('cell', cellNumber, ...
                '', ''), cellWarnings];
            warnings{warningCount} = cellWarnings;
            warningCount = warningCount + 1;
        end
    end % checkForCellWarnings

    function [originalTags, formattedTags] = formatTSVTags(tags)
        % Converts the tags from a str to a cellstr and formats them
        originalTags = formatTags(tags, false);
        formattedTags = formatTags(tags, true);
    end % formatTSVTags

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedMaps', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('cells', @(x) (~isempty(x) && iscellstr(x)));
        parser.addRequired('extensionAllowed', @islogical);
        parser.parse(hedMaps, cells, extensionAllowed);
        p = parser.Results;
    end % parseArguments

    function parseCells()
        % Parses the tags in a cell array and validates them
        numCells = length(cells);
        for a = 1:numCells
            [originalTags, formattedTags] = formatTSVTags(cells{a});
            validateCellTags(originalTags, formattedTags, a);
        end
    end % parseCells

    function validateCellTags(originalTags, formattedTags, cellNumber)
        % This function validates the tags in a cell array
        if ~isempty(originalTags)
            checkForCellErrors(originalTags, formattedTags, cellNumber);
            checkForCellWarnings(originalTags, formattedTags, cellNumber);
            checkForCellExtensions(originalTags, formattedTags, ...
                cellNumber);
        end
    end % validateCellTags

end % parseCellTags