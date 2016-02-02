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
%       tsvTagColumns
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
%       remap 
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

function [errors, warnings, extensions, remap] = ...
    validateTSVTags(tsvFile, tsvTagColumns, varargin)
p = parseArguments();
hedMaps = loadHEDMap();
mapVersion = hedMaps.version;
xmlVersion = getXMLHEDVersion(p.hedXML);
if ~strcmp(mapVersion, xmlVersion);
    hedMaps = mapHEDAttributes(p.hedXML);
end
[errors, warnings, extensions, remap] = ...
    parseTSVTags(hedMaps, p.tsvFile, p.tsvTagColumns, p.hasHeader, ...
    p.extensionAllowed);
if p.writeOutput
    writeOutputFiles();
end

    function hedMaps = loadHEDMap()
        % Loads a structure that contains Maps associated with the HED XML
        % tags
        Maps = load('hedMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHEDMap

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('tsvFile', @(x) (~isempty(x) && ischar(x)));
        p.addRequired('tsvTagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        p.addParamValue('hedXML', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x))); %#ok<NVREPL>
        p.addParamValue('extensionAllowed', true, ...
            @(x) validateattributes(x, {'logical'}, {})); %#ok<NVREPL>
        p.addParamValue('hasHeader', true, @islogical); %#ok<NVREPL>
        p.addParamValue('remapFile', '', @(x) (~isempty(x) && ...
            ischar(x))); %#ok<NVREPL>
        p.addParamValue('outputDirectory', fileparts(tsvFile), ...
            @(x) ischar(x) && 7 == exist(x, 'dir')); %#ok<NVREPL>
        p.addParamValue('writeOutput', false, @islogical); %#ok<NVREPL>
        p.parse(tsvFile, tsvTagColumns, varargin{:});
        p = p.Results;
    end % parseArguments

    function writeErrorFile(dir, file, ext)
        % Writes the errors to a file
        numErrors = length(errors);
        errorFile = fullfile(dir, [file '_err' ext]);
        fileId = fopen(errorFile,'w');
        for a = 1:numErrors
            fprintf(fileId, '%s\n', errors{a});
        end
        fclose(fileId);
    end % writeErrorFile

    function writeExtensionFile(dir, file, ext)
        % Writes the extensions to a file
        numExtensions = length(extensions);
        extensionFile = fullfile(dir, [file '_ext' ext]);
        fileId = fopen(extensionFile,'w');
        for a = 1:numExtensions
            fprintf(fileId, '%s\n', extensions{a});
        end
        fclose(fileId);
    end % writeExtensionFile

    function writeMapFile(dir, file, ext)
        % Writes the extensions to a file
        if isempty(p.remapFile)
            fileId = writeToNewMapFile(dir, file, ext);
        else
            fileId = writeToExistingMapFile(dir, ext);
        end
        fclose(fileId);
    end % writeMapFile

    function fileId = writeToNewMapFile(dir, file, ext)
        % Writes to a new map file
        numMapTags = size(remap, 1);
        remapFile = fullfile(dir, [file '_remap' ext]);
        fileId = fopen(remapFile,'w');
        for a = 1:numMapTags
            fprintf(fileId, '%s\n', remap{a});
        end
    end % writeToNewMapFile

    function fileId = writeToExistingMapFile(dir, ext)
        % Writes to an existing map file
        numMapTags = size(remap, 1);
        [mapFileDir, file]  = fileparts(p.remapFile);
        remapFile = fullfile(dir, [file ext]);
        mapTagMap = putMapFileInHash(remapFile);
        if ~strcmp(dir, mapFileDir)
            copyfile(p.remapFile, remapFile);
        end
        fileId = fopen(remapFile,'a');
        for a = 1:numMapTags
            if ~mapTagMap.isKey(lower(remap{a}))
                fprintf(fileId, '\n%s', remap{a});
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

    function writeOutputFiles()
        % Writes the errors, warnings, extension allowed warnings to
        % the output files
        dir = p.outputDirectory;
        [~, file] = fileparts(p.tsvFile);
        ext = '.txt';
        writeErrorFile(dir, file, ext);
        writeWarningFile(dir, file, ext);
        writeExtensionFile(dir, file, ext);
        writeMapFile(dir, file, ext);
    end % writeOutputFiles

    function writeWarningFile(dir, file, ext)
        % Writes the warnings to a file
        numWarnings = length(warnings);
        warningFile = fullfile(dir, [file '_wrn' ext]);
        fileId = fopen(warningFile,'w');
        for a = 1:numWarnings
            fprintf(fileId, '%s\n', warnings{a});
        end
        fclose(fileId);
    end % writeWarningFile

end % validateTSVTags