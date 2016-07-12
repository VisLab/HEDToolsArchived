% This function takes in a tab-delimited text file containing HED tags
% associated with a particular study and validates them based on the
% tags and attributes in the HED XML file.
%
% Usage:
%
%   >>  [errors, warnings, extensions] = ...
%        validateTSVTags(tsvFile, tsvTagColumns);
%
%   >>  [errors, warnings, extensions] = ...
%        validateTSVTags(tsvFile, tsvTagColumns, varargin);
%
% Input:
%
%       tsvFile
%                   The name or the path of a tab-delimited text file
%                   containing HED tags associated with a particular study.
%
%       columns
%                   The columns that contain the study or experiment HED
%                   tags. The columns can be a scalar value or a vector
%                   (e.g. 2 or [2,3,4]).
%
%       Optional:
%
%       'extensionAllowed'
%                   True(default) if descendants of extension allowed tags
%                   are accepted which will generate warnings, False if
%                   they are not accepted which will generate errors.
%
%       'hasHeader'
%                   True(default)if the tab-delimited file containing
%                   the HED study tags has a header. The header will be
%                   skipped and not validated. False if the file doesn't
%                   have a header.
%
%       'hedXML'
%                   The name or the path of the XML file containing
%                   all of the HED tags and their attributes.
%
%       'outputDirectory'
%                   A directory where the validation output is written to
%                   if the 'writeOuput' argument is true.
%                   There will be four separate files generated, one
%                   containing the validation errors, one containing the
%                   validation  warnings, one containing the extension
%                   allowed validation warnings, and a remap file. The
%                   default directory will be the directory that contains
%                   the tab-delimited 'tsvFile'.
%
%       'writeOutput'
%                  True if the validation output is written to the
%                  workspace and a set of files in the same directory,
%                  false (default) if the validation output is only written
%                  to the workspace.
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
%       uniqueErrorTags
%                   A cell array containing all of the unique validation
%                   error tags.
%
% Examples:
%                   To validate the HED study tags in file
%                   'LSIE_06_Outdoor_all_events.txt' in the third column
%                   using HED XML file 'HED2.026.xml' (default) to validate
%                   them with no header.
%
%                   validateTSVTags('LSIE_01_Indoor_all_events.txt', 3, ...
%                   'hasHeader', false);
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

function [errorLog, warningLog, extensionLog] = validatetsv(tsvFile, ...
    columns, varargin)
p = parseArguments(tsvFile, columns, varargin{:});
[success, p] = validate(p);
if ~success
    errorLog = '';
    warningLog = '';
    extensionLog = '';
    return;
end
errorLog = p.errorLog;
warningLog = p.warningLog;
extensionLog = p.extensionLog;

    function [success, p] = validate(p)
        % Validates a tsv file
        p.hedMaps = getHEDMaps(p);
        [p.errorLog, p.warningLog, p.extensionLog, p.uniqueErrorTags] = ...
            parseTSVTags(p.hedMaps, p.tsvFile, p.columns, ...
            p.hasHeader, p.extensionAllowed);
        if p.writeOutput
            writeOutputFiles(p);
        end
        success = true;
    end % validate

    function hedMaps = getHEDMaps(p)
        % Gets a structure that contains Maps associated with the HED XML
        % tags
        hedMaps = loadHEDMap();
        mapVersion = hedMaps.version;
        xmlVersion = getXMLHEDVersion(p.hedXML);
        if ~strcmp(mapVersion, xmlVersion);
            hedMaps = mapHEDAttributes(p.hedXML);
        end
    end % getHEDMaps

    function hedMaps = loadHEDMap()
        % Loads a structure that contains Maps associated with the HED XML
        % tags
        Maps = load('hedMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHEDMap

    function p = parseArguments(tsvFile, columns, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('tsvFile', @(x) (~isempty(x) && ischar(x)));
        p.addRequired('columns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        p.addParamValue('errorLogOnly', true, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('hedXML', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('extensionAllowed', true, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('hasHeader', true, @islogical);
        p.addParamValue('remapFile', '', @(x) (~isempty(x) && ...
            ischar(x)));
        p.addParamValue('outDir', fileparts(tsvFile), ...
            @(x) ischar(x) && 7 == exist(x, 'dir'));
        p.addParamValue('writeOutput', false, @islogical);
        p.parse(tsvFile, columns, varargin{:});
        p = p.Results;
    end % parseArguments

    function createErrorLog(p)
        % Creates a error log
        numErrors = length(p.errorLog);
        errorFile = fullfile(p.dir, [p.file '_error_log' p.ext]);
        fileId = fopen(errorFile,'w');
        for a = 1:numErrors
            fprintf(fileId, '%s\n', p.errorLog{a});
        end
        fclose(fileId);
    end % createErrorLog

    function createExtensionLog(p)
        % Creates a extension log
        numExtensions = length(p.extensionLog);
        extensionFile = fullfile(p.dir, [p.file '_extension_log' p.ext]);
        fileId = fopen(extensionFile,'w');
        for a = 1:numExtensions
            fprintf(fileId, '%s\n', p.extensionLog{a});
        end
        fclose(fileId);
    end % createExtensionLog

    function writeRemapFile(p)
        % Writes a remap file
        if isempty(p.remapFile)
            fileId = writeToNewMapFile(p);
        else
            fileId = writeToExistingMapFile(p);
        end
        fclose(fileId);
    end % writeRemapFile

    function fileId = writeToNewMapFile(p)
        % Writes to a new map file
        numMapTags = length(p.uniqueErrorTags);
        remapFile = fullfile(p.dir, [p.file '_remap' p.mapExt]);
        fileId = fopen(remapFile,'w');
        for a = 1:numMapTags
            fprintf(fileId, '%s\n', p.uniqueErrorTags{a});
        end
    end % writeToNewMapFile

    function fileId = writeToExistingMapFile(p)
        % Writes to an existing map file
        numMapTags = size(p.uniqueErrorTags, 1);
        [mapFileDir, file]  = fileparts(p.remapFile);
        remapFile = fullfile(p.dir, [p.file p.ext]);
        mapTagMap = putMapFileInHash(remapFile);
        if ~strcmp(dir, mapFileDir)
            copyfile(p.remapFile, remapFile);
        end
        fileId = fopen(remapFile,'a');
        for a = 1:numMapTags
            if ~mapTagMap.isKey(lower(p.uniqueErrorTags{a}))
                fprintf(fileId, '\n%s', p.uniqueErrorTags{a});
            end
        end
    end % writeToExistingMapFile

    function mapTagMap = putMapFileInHash(remapFile)
        % Put map file tags in a hash map
        mapTagMap = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        lineNumber = 1;
        try
            fileId = fopen(remapFile);
            tsvLine = fgetl(fileId);
            while ischar(tsvLine)
                mapTagMap(lower(tsvLine)) = tsvLine;
                lineNumber = lineNumber + 1;
                tsvLine = fgetl(fileId);
            end
            fclose(fileId);
        catch ME
            fclose(fileId);
            throw(MException('ValidateTags:cannotParse', ...
                'Unable to parse TSV file on line %d', lineNumber));
        end
    end % putMapTagsInHash

    function writeOutputFiles(p)
        % Writes the errors, warnings, extension allowed warnings to
        % the output files
        p.dir = p.outDir;
        [~, p.file] = fileparts(p.tsvFile);
        p.ext = '.txt';
        p.mapExt = '.tsv';
        createErrorLog(p);
        writeRemapFile(p);
        if ~p.errorLogOnly
            createWarningLog(p);
            createExtensionLog(p);
        end
    end % writeOutputFiles

    function createWarningLog(p)
        % Creates a warning log
        numWarnings = length(p.warningLog);
        warningFile = fullfile(p.dir, [p.file '_warning_log' p.ext]);
        fileId = fopen(warningFile,'w');
        for a = 1:numWarnings
            fprintf(fileId, '%s\n', p.warningLog{a});
        end
        fclose(fileId);
    end % createWarningLog

end % validatetsv