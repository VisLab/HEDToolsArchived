% This function takes in a tab-delimited text file containing HED tags
% associated with a particular study and validates them based on the
% tags and attributes in the HED XML file.
%
% Usage:
%
%   >>  [errors, warnings, extensions] = parseTSVTags(hedMaps, tsvFile, ...
%       tsvTagColumns, hasHeaderRow, extensionAllowed);
%
% Inputs:
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
% Outputs:
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
%       uniqueErrorTags
%                   A cell array containing all of the unique validation
%                   error tags.
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

function [issues, remapTags, success] = parsetsv(hedMaps, tsvFile, ...
    tagColumns, hasHeader, generateWarnings)
p = parseArguments(hedMaps, tsvFile, tagColumns, hasHeader, ...
    generateWarnings);
[issues, remapTags, success] = readLines(p);

    function [line, lineNumber] = checkFileHeader(hasHeader, fileId)
        % Checks to see if the file has a header line
        lineNumber = 1;
        line = fgetl(fileId);
        if hasHeader
            line = fgetl(fileId);
            lineNumber = 2;
        end
    end % checkFileHeader

    function p = findErrors(p)
        % Errors will be generated for the line if found
        [p.lineErrors, lineRemapTags] = checkForValidationErrors(p.hedMaps, ...
            p.cellTags, p.formattedCellTags);
        p.remapTags = union(p.remapTags, lineRemapTags);
    end % findErrors

    function p = findWarnings(p)
        % Warnings will be generated for the line if found
        p.lineWarnings = checkForValidationWarnings(p.hedMaps, ...
            p.cellTags, p.formattedCellTags);
    end % findWarnings

    function [cellTags, formattedCellTags] = tags2cell(strTags)
        % Converts the tags from a str to a cellstr and formats them
        cellTags = formatTags(strTags, false);
        formattedCellTags = formatTags(strTags, true);
    end % tags2cell

    function p = parseArguments(hedMaps, file, tagColumns, hasHeader, ...
            generateWarnings)
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedMaps', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('tsvFile', @(x) (~isempty(x) && ischar(x)));
        parser.addRequired('tagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        parser.addRequired('hasHeader', @islogical);
        parser.addRequired('generateWarnings', @islogical);
        parser.parse(hedMaps, file, tagColumns, hasHeader, ...
            generateWarnings);
        p = parser.Results;
    end % parseArguments

    function [issues, remapTags, success] = readLines(p)
        % Reads the tab-delimited file line by line and validates the tags
        p.issues = {};
        p.remapTags = {};
        p.issueCount = 1;
        try
            fileId = fopen(p.tsvFile);
            [line, p.lineNumber] = checkFileHeader(p.hasHeader, fileId);
            while ischar(line)
                [p.cellTags, p.formattedCellTags] = getLineTags(line, ...
                    p.tagColumns);
                p = validateLineTags(p);
                line = fgetl(fileId);
                p.lineNumber = p.lineNumber + 1;
            end
            fclose(fileId);
            issues = p.issues;
            remapTags = p.remapTags;
            success = true;
            handleEmptyOutput(p);
        catch ME
            fclose(fileId);
            warning('Unable to parse TSV file on line %d', p.lineNumber);
            issues = '';
            remapTags = {};
            success = false;
        end
    end % readLines

    function [cellTags, formattedCellTags] = getLineTags(line, tagColumns)
        % Reads the tag columns in a tab-delimited file and formats them
        cellTags = {};
        formattedCellTags = {};
        delimitedLine = textscan(line, '%s', 'delimiter', '\t', ...
            'multipleDelimsAsOne', 1)';
        numLineCols = size(delimitedLine{1},1);
        numCols = size(tagColumns, 2);
        % clean this up later
        if ~all(cellfun(@isempty, strtrim(delimitedLine))) && ...
                tagColumns(1) <= numLineCols
            splitTags = delimitedLine{1}{tagColumns(1)};
            for a = 2:numCols
                if tagColumns(a) <= numLineCols
                    splitTags = [splitTags, ',', ...
                        delimitedLine{1}{tagColumns(a)}]; %#ok<AGROW>
                end
            end
            [cellTags, formattedCellTags] = tags2cell(splitTags);
        end
    end % getLineTags

    function p = validateLineTags(p)
        % This function validates the tags on a line in a tab-delimited
        % file
        if ~isempty(p.cellTags)
            p = findErrors(p);
            p.lineIssues = p.lineErrors;
            if(p.generateWarnings)
                p = findWarnings(p);
                p.lineIssues = [p.lineErrors p.lineWarnings];
            end
            if ~isempty(p.lineIssues)
                p.issues{p.issueCount} = ...
                    [sprintf('Issues on line %d:\n', p.lineNumber), ...
                    p.lineIssues];
                p.issueCount = p.issueCount + 1;
            end
        end
    end % validateLineTags

    function handleEmptyOutput(p)
        % Handles empty output
        if isempty(p.issues)
            p.issues{1} = sprintf('No issues were found.');
        end
    end % handleEmptyOutput

end % parsetags