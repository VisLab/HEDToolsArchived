% This function validates the HED tags in a tab-separated file against a
% HED schema.
%
% Usage:
%
%   >>  issues = validatetsv(tsvFile, tagColumns);
%
%   >>  issues = validatetsv(tsvFile, tagColumns, 'key1', 'value1', ...);
%
% Input:
%
%   Required:
%
%   tsvFile
%                   The full path of a tab-separated file containing HED
%                   tags in a single column or multiple columns.
%
%   tagColumns
%                   The columns in the tab-separated file that contains the
%                   HED tags. The columns are either a scalar value or a
%                   vector (e.g. 2 or [2,3,4]).
%
%   Optional (key/value):
%
%   'generateWarnings'
%                   True to include warnings in the log file in addition
%                   to errors. If false (default) only errors are included
%                   in the log file.
%
%   'hasHeader'
%                   True (default) if the the tab-separated input file has
%                   a header. The first row will not be validated otherwise
%                   it will and this can generate issues.
%
%   'hedXml'
%                   The full path to a HED XML file containing all of the
%                   tags. This by default will be the HED.xml file
%                   found in the hed directory.
%
%   'outDir'
%                   The directory where the validation output will be
%                   written to if the 'writeOutput' argument is set to
%                   true. There will be log file containing any issues that
%                   were found while validating the HED tags. If there were
%                   issues found then a replace file will be created in
%                   addition to the log file if an optional one isn't
%                   already provided. The default output directory will be
%                   the current directory.
%
%   'replaceFile'
%                   A optional two column tab-separated file used to find
%                   and replace the HED tags in the input file. The first
%                   column will be the HED tags to find and the second
%                   column will be HED tags that will replace them. If a
%                   replace file is provided then any HED tags not already
%                   in the first column of this file that generate issues
%                   from the validation will be appended to the end of it.
%                   Reusing a replace file comes in handy when you have
%                   multiple tab-separated files that have the same HED
%                   tags or you simply want to consolidate all of the
%                   changes in one file instead of several.
%
%   'writeOutput'
%                  True if the validation output is written to a log file
%                  in addition to the workspace. False (default) if the
%                  validation output is only written to the workspace.
%
% Output:
%
%   issues
%                   A cell array containing all of the issues found through
%                   the validation. Each cell corresponds to the issues
%                   found on a particular line.
%
%   success
%                   True if the validation finishes without throwing any
%                   exceptions. False if otherwise.
%
% Copyright (C) 2012-2016 Thomas Rognon tcrognon@gmail.com,
% Jeremy Cockfield jeremy.cockfield@gmail.com, and
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

function issues = validatetsv(tsvFile, tagColumns, varargin)
p = parseArguments(tsvFile, tagColumns, varargin{:});
issues = validate(p);

    function issues = validate(p)
        % Validates the HED tags in the tab-separated file
        [p.issues, p.replaceTags] = parsetsv(p.hedXml, ...
            p.tsvFile, p.tagColumns, p.hasHeader, p.generateWarnings);
        issues = p.issues;
        if p.writeOutput
            writeOutputFiles(p);
        end
    end % validate

    function p = parseArguments(tsvFile, tagColumns, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('tsvFile', @(x) (~isempty(x) && ischar(x)));
        p.addRequired('tagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        p.addParamValue('generateWarnings', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('hedXml', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('hasHeader', true, @islogical);
        p.addParamValue('replaceFile', '', @(x) (~isempty(x) && ...
            ischar(x)));
        p.addParamValue('outDir', pwd);
        p.addParamValue('writeOutput', false, @islogical);
        p.parse(tsvFile, tagColumns, varargin{:});
        p = p.Results;
    end % parseArguments

    function createLogFile(p, empty)
        % Creates a log file containing any issues found through the
        % validation
        numErrors = length(p.issues);
        logFile = fullfile(p.outDir, [p.file '_log' p.ext]);
        try
            fileId = fopen(logFile,'w');
            if ~empty
                for a = 1:numErrors-1
                    fprintf(fileId, '%s\n', p.issues{a});
                end
                fprintf(fileId, '%s', strtrim(p.issues{numErrors}));
            else
                fprintf(fileId, 'No issues were found.');
            end
            fclose(fileId);
        catch
            throw(MException('validatetsv:cannotWrite', ...
                'Cannot write log file'));
        end
    end % createLogFile

    function createReplaceFile(p)
        % Creates a replace file containing all unique tags that generated
        % issues
        if isempty(p.replaceFile)
            write2ReplaceFile(p);
        else
            append2ReplaceFile(p);
        end
    end % createReplaceFile

    function fileId = write2ReplaceFile(p)
        % Creates and writes to a new replace file
        numReplaceTags = length(p.replaceTags);
        if (numReplaceTags > 0)
            replaceFile = fullfile(p.outDir, ...
                [p.file '_replace' p.replaceExt]);
            try
                fileId = fopen(replaceFile,'w');
                fprintf(fileId, '%s', p.replaceTags{1});
                for a = 2:numReplaceTags
                    fprintf(fileId, '\n%s', p.replaceTags{a});
                end
                fclose(fileId);
            catch
                if (fileId ~= 1)
                    fclose(fileId);
                end
                throw(MException('validatetsv:cannotWrite', ...
                    'Cannot write to replace file'));
            end
        end
    end % write2ReplaceFile

    function fileId = append2ReplaceFile(p)
        % Appends to an existing replace file
        numMapTags = size(p.replaceTags, 1);
        replaceFileDir  = fileparts(p.replaceFile);
        replaceFile = fullfile(p.dir, [p.file p.ext]);
        replaceMap = replaceFile2Map(replaceFile);
        if ~strcmp(dir, replaceFileDir)
            copyfile(p.replaceFile, replaceFile);
        end
        try
            fileId = fopen(replaceFile,'a');
            for a = 1:numMapTags
                if ~replaceMap.isKey(lower(p.replaceTags{a}))
                    fprintf(fileId, '\n%s', p.replaceTags{a});
                end
            end
            fclose(fileId);
        catch
            if (fileId ~= 1)
                fclose(fileId);
            end
            throw(MException('validatetsv:cannotWrite', ...
                'Cannot write to replace file'));
        end
    end % append2ReplaceFile

    function replaceMap = replaceFile2Map(replaceFile)
        % Puts the replace file tags in a Map container
        replaceMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
        lineNumber = 1;
        try
            fileId = fopen(replaceFile);
            tsvLine = fgetl(fileId);
            while ischar(tsvLine)
                replaceMap(lower(tsvLine)) = tsvLine;
                lineNumber = lineNumber + 1;
                tsvLine = fgetl(fileId);
            end
            fclose(fileId);
        catch ME
            fclose(fileId);
            throw(MException('validatetsv:cannotRead', ...
                'Unable to read replace file %d', lineNumber));
        end
    end % replaceFile2Map

    function writeOutputFiles(p)
        % Writes the issues and replace tags found to a log file and a
        % replace file
        [~, p.file] = fileparts(p.tsvFile);
        p.ext = '.txt';
        p.replaceExt = '.tsv';
        if ~isempty(p.issues)
            createLogFile(p, false);
            createReplaceFile(p);
        else
            createLogFile(p, true);
        end
    end % writeOutputFiles

end % validatetsv