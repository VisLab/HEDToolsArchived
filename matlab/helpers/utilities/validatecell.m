% This function takes in a cell array containing HED tags
% associated with a particular study and validates them based on the
% tags and attributes in the HED XML file.
%
% Usage:
%
%   >>  [errors, warnings, extensions] = validateCellTags(cells);
%
%   >>  [errors, warnings, extensions] = validateCellTags(cells, varargin);
%
% Input:
%
%       cells
%                   A cellstr containing HED tags that are validated.
%
%
%       Optional:
%
%       'extensionAllowed'
%                   True(default) if descendants of extension allowed tags
%                   are accepted which will generate warnings, False if
%                   they are not accepted which will generate errors.
%
%       'hedXML'
%                   The name or the path of the XML file containing
%                   all of the HED tags and their attributes.
%
%       'outDir'
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
%       errorLog
%                   A cell array containing the error log. Each cell is
%                   associated with the validation errors on a particular
%                   line.
%
%       warningLog
%                   A cell array containing the warning log. Each cell is
%                   associated with the validation warnings on a particular
%                   line.
%
%       extensionLog
%                   A cell array containing the extension log. Each cell is
%                   associated with the extension allowed validation
%                   warnings on a particular line.
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

function [errorLog, warningLog, extensionLog] = validatecell(cells, ...
    varargin)
p = parseArguments(cells, varargin{:});
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
        % Validates a cellstr
        success = false;
        p.hedMaps = getHEDMaps(p);
        if ~all(cellfun(@isempty, strtrim(p.cells)))
            [p.errorLog, p.warningLog, p.extensionLog] = ...
                parseCellTags(p.hedMaps, p.cells, p.extensionAllowed);
            if p.writeOutput
                createLogs();
            end
            success = true;
        end
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
        Maps = load('HEDMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHEDMap

    function p = parseArguments(cells, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('cells', @iscell);
        p.addParamValue('extensionAllowed', true, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('hedXML', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('outputDirectory', pwd, ...
            @(x) ischar(x) && 7 == exist(x, 'dir'));
        p.addParamValue('writeOutput', false, @islogical);
        p.parse(cells, varargin{:});
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

    function createLogs(p)
        % Creates the log files
        p.dir = p.outDir;
        [~, file] = fileparts(p.tsvFile);
        p.ext = '.txt';
        createErrorLog(p);
        if ~p.errorLogOnly
            createWarningLog(p);
            createExtensionLog(p);
        end
    end % createLogs

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

end % validatecell