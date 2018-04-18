% This function takes in a tab-separated file containing HED tags
% and validates them against a HED schema. The validatetsv function calls
% this function to parse the tab-separated file and generate any issues
% found through the validation.
%
% Usage:
%
%   >>  issues, replaceTags = validateTsvHedTags(hedMaps, tsvFile, ...
%       tagColumns, hasHeader, generateWarnings)
%
% Input:
%
%   hedMaps
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
%   tsvFile
%                   The name or the path of a tab-separated file
%                   containing HED tags in a single column or multiple
%                   columns.
%
%   tagColumns
%                   The columns in the tab-separated file that contains the
%                   HED tags. The columns are either a scalar value or a
%                   vector (e.g. 2 or [2,3,4]).
%
%   hasHeader
%                   True (default) if the the tab-separated input file has
%                   a header. The first row will not be validated otherwise
%                   it will and this can generate issues.
%
%   generateWarnings
%                   True to include warnings in the log file in addition
%                   to errors. If false (default) only errors are included
%                   in the log file.
%
% Output:
%
%   issues
%                   A cell array containing all of the issues found through
%                   the validation. Each cell corresponds to the issues
%                   found on a particular line.
%
%   replaceTags
%                   A cell array containing all of the tags that generated
%                   issues. These tags will be written to a replace file.
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

function issues = validateTsvHedTags(tsvFile, varargin)
inputArgs = parseInputArguments(tsvFile, varargin{:});
issues = validateTags(inputArgs);

    function [tsvRow, lineNumber] = getFirstRowForValidation(hasHeader, ...
            fileId)
        % Gets the first validation row. If there are headers this row will
        % be skipped.
        lineNumber = 1;
        tsvRow = getNextRow(fileId);
        if hasHeader
            tsvRow = getNextRow(fileId);
            lineNumber = 2;
        end
    end % checkFileHeader

    function inputArguments = parseInputArguments(tsvFile, varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('tsvFile', @ischar);
        parser.addParamValue('generateWarnings', false, @islogical);
        parser.addParamValue('hasHeaders', true, @islogical);
        parser.addParamValue('otherColumns', [], @isnumeric);
        parser.addParamValue('specificColumns', [], @isstruct);
        parser.parse(tsvFile, varargin{:});
        inputArguments = parser.Results;
    end % parseInputArguments

    function issues = validateTags(inputArgs)
        % Reads the tab-delimited file line by line and validates the tags
        issues = {};
        rowNumber = 1;
        %         try
        fileId = fopen(inputArgs.tsvFile);
        [tsvRow, rowNumber] = getFirstRowForValidation(...
            inputArgs.hasHeaders, fileId);
        while ~isempty(tsvRow)
            if ~isempty(inputArgs.specificColumns)
                tsvRow = appendTagPrefixes(tsvRow, ...
                    inputArgs.specificColumns);
            end
            tsvRow = getNextRow(fileId);
            rowNumber = rowNumber + 1;
        end
        fclose(fileId);
        %         catch
        %             fclose(fileId);
        %             throw(MException('validateTsvHedTags:cannotRead', ...
        %                 'Unable to read TSV file on line %d', rowNumber));
        %         end
    end % readLines

    function rowTags = getNextRow(fileId)
        % Gets the next row
        row = fgetl(fileId);
        fprintf([row '\n']);
        rowTags = {};
        if ischar(row)
            rowTags = textscan(row, '%q', 'delimiter', '\t');
            rowTags = rowTags{:};
        end
    end

    function combinedTags = combineRowTags(row, tagColumns)
        % Reads the tag columns in a tab-delimited file and formats them
        numberOfRowColumns = size(row{1},1);
        numCols = size(tagColumns, 2);
        % clean this up later
        if ~all(cellfun(@isempty, strtrim(delimitedLine))) && ...
                tagColumns(1) <= numberOfRowColumns
            splitTags = delimitedLine{1}{tagColumns(1)};
            for a = 2:numCols
                if tagColumns(a) <= numberOfRowColumns
                    splitTags = [splitTags, ',', ...
                        delimitedLine{1}{tagColumns(a)}]; %#ok<AGROW>
                end
            end
        end
    end % getLineTags
end % parsetags