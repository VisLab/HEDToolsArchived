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
%       Required:
%
%       tsvFile
%                   The name or the path of a tab-separated file
%                   containing HED tags in a single column or multiple
%                   columns.
%
%       tagColumns
%                   The columns in the tab-separated file that contains the
%                   HED tags. The columns are either a scalar value or a
%                   vector (e.g. 2 or [2,3,4]).
%
%       Optional (key/value):
%
%       'generateWarnings'
%                   True to include warnings in the log file in addition
%                   to errors. If false (default) only errors are included
%                   in the log file.
%
%       'hasHeader'
%                   True (default) if the the tab-separated input file has
%                   a header. The first row will not be validated otherwise
%                   it will and this can generate issues.
%
%       'hedXML'
%                   A XML file containing every single HED tag and its
%                   attributes. This by default will be the HED.xml file
%                   found in the hed directory.
%
%       'outputDirectory'
%                   The directory where the validation output will be
%                   written to if the 'writeOutput' argument is set to
%                   true. There will be log file containing any issues that
%                   were found while validating the HED tags. If there were
%                   issues found then a replace file will be created in
%                   addition to the log file if an optional one isn't
%                   already provided. The default output directory will be
%                   the current directory.
%
%       'replaceFile'
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
%       'writeOutput'
%                  True if the validation output is written to a log file
%                  in addition to the workspace. False (default) if the
%                  validation output is only written to the workspace.
%
% Output:
%
%       issues
%                   A cell array containing all of the issues found through
%                   the validation. Each cell corresponds to the issues
%                   found on a particular line.
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

function issues = validatetsv(tsvFile, tagColumns, varargin)
p = parseArguments(tsvFile, tagColumns, varargin{:});
issues = validate(p);

    function issues = validate(p)
        % Validates the HED tags in the tab-separated file
        p.hedMaps = getHEDMaps(p);
        [p.issues, p.replaceTags, success] = parsetsv(p.hedMaps, ...
            p.tsvFile, p.tagColumns, p.hasHeader, p.generateWarnings);
        issues = p.issues;
        if success && p.writeOutput
            writeOutputFiles(p);
        end
    end % validate

    function hedMaps = getHEDMaps(p)
        % Gets a structure full of Maps containings all of the HED tags and
        % their attributes
        hedMaps = loadHEDMap();
        mapVersion = hedMaps.version;
        xmlVersion = getXMLHEDVersion(p.hedXML);
        if ~strcmp(mapVersion, xmlVersion);
            hedMaps = mapHEDAttributes(p.hedXML);
        end
    end % getHEDMaps

    function hedMaps = loadHEDMap()
        % Loads a structure full of Maps containings all of the HED tags
        % and their attributes
        Maps = load('hedMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHEDMap

    function p = parseArguments(tsvFile, tagColumns, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('tsvFile', @(x) (~isempty(x) && ischar(x)));
        p.addRequired('tagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        p.addParamValue('generateWarnings', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('hedXML', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('hasHeader', true, @islogical);
        p.addParamValue('replaceFile', '', @(x) (~isempty(x) && ...
            ischar(x)));
        p.addParamValue('outputDirectory', pwd);
        p.addParamValue('writeOutput', false, @islogical);
        p.parse(tsvFile, tagColumns, varargin{:});
        p = p.Results;
    end % parseArguments

    function createLogFile(p, empty)
        % Creates a log file containing any issues found through the
        % validation
        numErrors = length(p.issues);
        errorFile = fullfile(p.dir, [p.file '_log' p.ext]);
        fileId = fopen(errorFile,'w');
        if ~empty
            fprintf(fileId, '%s', p.issues{1});
            for a = 2:numErrors
                fprintf(fileId, '\n%s', p.issues{a});
            end
        else
            fprintf(fileId, 'No issues were found.');
        end
        fclose(fileId);
    end % createLogFile

    function createReplaceFile(p)
        % Creates a replace file containing all unique tags that generated
        % issues
        if isempty(p.replaceFile)
            fileId = write2ReplaceFile(p);
        else
            fileId = append2ReplaceFile(p);
        end
        fclose(fileId);
    end % createReplaceFile

    function fileId = write2ReplaceFile(p)
        % Creates and writes to a new replace file
        numReplaceTags = length(p.replaceTags);
        replaceFile = fullfile(p.dir, [p.file '_remap' p.mapExt]);
        fileId = fopen(replaceFile,'w');
        fprintf(fileId, '%s', p.replaceTags{1});
        for a = 2:numReplaceTags
            fprintf(fileId, '\n%s', p.replaceTags{a});
        end
    end % write2ReplaceFile

    function fileId = append2ReplaceFile(p)
        % Appends to an existing replace file
        numMapTags = size(p.replaceTags, 1);
        [replaceFileDir, file]  = fileparts(p.replaceFile);
        replaceFile = fullfile(p.dir, [p.file p.ext]);
        replaceMap = replaceFile2Map(replaceFile);
        if ~strcmp(dir, replaceFileDir)
            copyfile(p.replaceFile, replaceFile);
        end
        fileId = fopen(replaceFile,'a');
        for a = 1:numMapTags
            if ~replaceMap.isKey(lower(p.replaceTags{a}))
                fprintf(fileId, '\n%s', p.replaceTags{a});
            end
        end
    end % append2ReplaceFile

    function replaceMap = replaceFile2Map(replaceFile)
        % Puts the replace file tags in a Map container
        replaceMap = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
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
            throw(MException('validatetsv:cannotParse', ...
                'Unable to parse TSV file on line %d', lineNumber));
        end
    end % replaceFile2Map

    function writeOutputFiles(p)
        % Writes the issues and replace tags found to a log file and a
        % replace file
        p.dir = p.outputDirectory;
        [~, p.file] = fileparts(p.tsvFile);
        p.ext = '.txt';
        p.mapExt = '.tsv';
        try
            if ~isempty(p.issues)
                createLogFile(p, false);
                createReplaceFile(p);
            else
                createLogFile(p, true);
            end
        catch
            throw(MException('validatetsv:cannotWrite', ...
                'Could not write output files'));
        end
    end % writeOutputFiles

end % validatetsv