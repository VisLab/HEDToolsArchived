% This function takes in a tab-separated file containing HED tags
% and validates them against a HED schema. The validatetsv function calls
% this function to parse the tab-separated file and generate any issues
% found through the validation.
%
% Usage:
%
%   >>  [issues, replaceTags] = parsetsv(hedMaps, tsvFile, ...
%       tagColumns, hasHeader, generateWarnings)
%
% Input:
%
%   'hedXml'
%                   The full path to a HED XML file containing all of the
%                   tags. This by default will be the HED.xml file
%                   found in the hed directory.
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

function [issues, replaceTags] = parsetsv(hedXml, tsvFile, ...
    tagColumns, hasHeader, generateWarnings)
p = parseArguments(hedXml, tsvFile, tagColumns, hasHeader, ...
    generateWarnings);
[issues, replaceTags] = readLines(p);

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
        [p.lineErrors, lineReplaceTags] = checkerrors(p.hedMaps, ...
            p.cellTags, p.formattedCellTags);
        p.replaceTags = union(p.replaceTags, lineReplaceTags);
    end % findErrors

    function p = findWarnings(p)
        % Warnings will be generated for the line if found
        p.lineWarnings = checkwarnings(p.hedMaps, p.cellTags, ...
            p.formattedCellTags);
    end % findWarnings

    function p = parseArguments(hedXml, file, tagColumns, hasHeader, ...
            generateWarnings)
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedXml', @(x) (~isempty(x) && ischar(x)));
        parser.addRequired('tsvFile', @(x) (~isempty(x) && ischar(x)));
        parser.addRequired('tagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        parser.addRequired('hasHeader', @islogical);
        parser.addRequired('generateWarnings', @islogical);
        parser.parse(hedXml, file, tagColumns, hasHeader, ...
            generateWarnings);
        p = parser.Results;
    end % parseArguments

    function [issues, replaceTags] = readLines(p)
        % Reads the tab-delimited file line by line and validates the tags
        p.issues = {};
        p.replaceTags = {};
        p.issueCount = 1;
        try
            fileId = fopen(p.tsvFile);
            [p.line, p.lineNumber] = checkFileHeader(p.hasHeader, fileId);
            while ischar(p.line)
                [p.cellTags, p.formattedCellTags, p.hedString] = ...
                    getLineTags(p.line, p.tagColumns);
                p = validateLineTags(p);
                p.line = fgetl(fileId);
                p.lineNumber = p.lineNumber + 1;
            end
            fclose(fileId);
            issues = p.issues;
            replaceTags = p.replaceTags;
        catch
            fclose(fileId);
            throw(MException('parsetsv:cannotRead', ...
                'Unable to read TSV file on line %d', p.lineNumber));
        end
    end % readLines

    function [cellTags, formattedCellTags, splitTags] = ...
            getLineTags(line, tagColumns)
        % Reads the tag columns in a tab-delimited file and formats them
        cellTags = {};
        formattedCellTags = {};
        delimitedLine = textscan(line, '%q', 'delimiter', '\t')';
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
            cellTags = hed2cell(splitTags, false);
            formattedCellTags = hed2cell(splitTags, true);
        end
    end % getLineTags

    function issues = validateHEDString(p)
        % Validate the entire HED string
        issues = validateHedTags(p.hedString, ...
            'hedXml', p.hedXml, 'generateWarnings', p.generateWarnings);
    end % validateHEDString

    function p = validateLineTags(p)
        % This function validates the tags on a line in a tab-delimited
        % file
        p.lineIssues = validateHEDString(p);
        if isempty(p.lineIssues)
            p = findErrors(p);
            p.lineIssues = p.lineErrors;
            if(p.generateWarnings)
                p = findWarnings(p);
                p.lineIssues = [p.lineErrors p.lineWarnings];
            end
        end
        if ~isempty(p.lineIssues)
            p.issues{p.issueCount} = ...
                [sprintf('Issues on line %d:\n', p.lineNumber), ...
                p.lineIssues];
            p.issueCount = p.issueCount + 1;
        end
    end % validateLineTags

end % parsetags