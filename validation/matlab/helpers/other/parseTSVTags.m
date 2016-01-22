% This function takes in a tab-delimited text file containing HED tags
% associated with a particular study and validates them based on the
% tags and attributes in the HED XML file.
%
% Usage:
%
%   >>  [errors, warnings, extensions] = parseTSVTags(hedMaps, tsvFile, ...
%       tsvTagColumns, hasHeaderRow, extensionAllowed);
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
%       tsvFile
%                   The name or the path of a tab-delimited text file
%                   containing HED tags associated with a particular study.
%
%       tsvTagColumns
%                   The columns that contain the HED study tags. The
%                   columns can be a scalar value or a vector (e.g. 1 or
%                   [1,2,3]).
%
%       hasHeaderRow
%                   True(default)if the tab-delimited text file containing
%                   the HED study tags has a header row. This row will be
%                   skipped and not validated. False if the file doesn't
%                   have a header row.
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

function [errors, warnings, extensions, mapTags] = ...
    parseTSVTags(hedMaps, tsvFile, tsvTagColumns, hasHeaderRow, ...
    extensionAllowed)
p = parseArguments();
errors = {};
warnings = {};
extensions = {};
mapTags = {};
errorCount = 1;
warningCount = 1;
extensionCount = 1;
extensionAllowedTags = p.hedMaps.extensionAllowed.values;
takesValueTags = p.hedMaps.takesValue.values;
parseTSVLines();

    function [tLine, currentRow] = checkForHeader(fileId)
        % Checks to see if the file has a header line
        currentRow = 1;
        tLine = fgetl(fileId);
        if hasHeaderRow
            tLine = fgetl(fileId);
            currentRow = 2;
        end
    end % checkForHeader

    function checkForTSVLineErrors(originalTags, formattedTags, lineNumber)
        % Errors will be generated for the line if found
        [lineErrors, lineMapTags] = ...
            checkForValidationErrors(p.hedMaps, originalTags, ...
            formattedTags, p.extensionAllowed, extensionAllowedTags, ...
            takesValueTags);
        if ~isempty(lineErrors)
            lineErrors = [generateErrorMessage('line', lineNumber, ...
                '', '', ''), lineErrors];
            errors{errorCount} = lineErrors;
            mapTags = union(mapTags, lineMapTags);
            errorCount = errorCount + 1;
        end
    end % checkForTSVLineErrors

    function checkForTSVLineExtensions(originalTags, formattedTags, ...
            lineNumber)
        % Errors will be generated for the line if found
        lineExtensions = checkForValidationExtensions(p.hedMaps, ...
            originalTags, formattedTags, p.extensionAllowed, ...
            extensionAllowedTags, takesValueTags);
        if ~isempty(lineExtensions)
            lineExtensions = [generateExtensionMessage('line', ...
                lineNumber, '', ''), lineExtensions];
            extensions{extensionCount} = lineExtensions;
            extensionCount = extensionCount + 1;
        end
    end % checkForTSVLineExtensions

    function checkForTSVLineWarnings(originalTags, formattedTags, ...
            lineNumber)
        % Warnings will be generated for the line if found
        lineWarnings = checkForValidationWarnings(p.hedMaps, ...
            originalTags, formattedTags);
        if ~isempty(lineWarnings)
            lineWarnings = [generateWarningMessage('line', lineNumber, ...
                '', ''), lineWarnings];
            warnings{warningCount} = lineWarnings;
            warningCount = warningCount + 1;
        end
    end % checkForTSVLineWarnings

    function [originalTags, formattedTags] = formatTSVTags(tags)
        % Converts the tags from a str to a cellstr and formats them
        originalTags = formatTags(tags, false);
        formattedTags = formatTags(tags, true);
    end % formatTSVTags

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedMaps', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('tsvFile', @(x) (~isempty(x) && ischar(x)));
        parser.addRequired('tsvTagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        parser.addRequired('hasHeaderRow', @islogical);
        parser.addRequired('extensionAllowed', @islogical);
        parser.parse(hedMaps, tsvFile, tsvTagColumns, hasHeaderRow, ...
            extensionAllowed);
        p = parser.Results;
    end % parseArguments

    function parseTSVLines()
        % Parses the tags in a tab-delimited file line by line and
        % validates them
        try
            fileId = fopen(p.tsvFile);
            [tsvLine, lineNumber] = checkForHeader(fileId);
            while ischar(tsvLine)
                [originalTags, formattedTags] = ...
                    readTSVLineTags(tsvLine, p.tsvTagColumns);
                validateTSVLineTags(originalTags, formattedTags, ...
                    lineNumber);
                tsvLine = fgetl(fileId);
                lineNumber = lineNumber + 1;
            end
            fclose(fileId);
        catch ME
            fclose(fileId);
            throw(MException('ParseTags:cannotParse', ...
                'Unable to parse TSV file on line %d', lineNumber));
        end
    end % parseTSVLines

    function [originalTags, formattedTags] = readTSVLineTags(tLine, ...
            tagColumns)
        % Reads the tag columns in a tab-delimited file and formats them
        originalTags = {};
        formattedTags = {};
        splitLine = textscan(tLine, '%s', 'delimiter', '\t', ...
            'multipleDelimsAsOne', 1)';
        numLineCols = size(splitLine{1},1);
        numCols = size(tagColumns, 2);
        % clean this up later
        if ~all(cellfun(@isempty, strtrim(splitLine))) && ...
                tagColumns(1) <= numLineCols
            splitTags = splitLine{1}{tagColumns(1)};
            for a = 2:numCols
                if tagColumns(a) <= numLineCols
                    splitTags  = [splitTags, ',', ...
                        splitLine{1}{tagColumns(a)}]; %#ok<AGROW>
                end
            end
            [originalTags, formattedTags] = formatTSVTags(splitTags);
        end
    end % readTSVLineTags

    function validateTSVLineTags(originalTags, formattedTags, lineNumber)
        % This function validates the tags on a line in a tab-delimited
        % file
        if ~isempty(originalTags)
            checkForTSVLineErrors(originalTags, formattedTags, lineNumber);
            checkForTSVLineWarnings(originalTags, formattedTags, ...
                lineNumber);
            checkForTSVLineExtensions(originalTags, formattedTags, ...
                lineNumber);
        end
    end % validateTSVLineTags

end % parsetags