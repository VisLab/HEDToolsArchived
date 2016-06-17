% This function takes in a directory containing EEG datasets and validates
% the tags the against the latest HED schema. 
%
% Usage:
%   >>  validateDir(inDir);
%   >>  validateDir(inDir, varargin);
%
% Input:
%       inDir       
%                   A directory containing EEG datasets that will be
%                   validated.
%
%       Optional:
%
%       'DoSubDirs'     
%                   If true (default), the entire inDir directory tree is
%                   searched. If false, only the inDir directory is
%                   searched.
%
%       'tagField'
%                   The field in .event that contains the HED tags.
%                   The default field is .usertags.
%
%       'hedXML'
%                   The name or the path of the HED XML file containing
%                   all of the tags.
%
%       'outDir'
%                   The directory where the validation output will be
%                   written to if the 'writeOutput' argument is true.
%                   There will be three separate files generated, one
%                   containing the validation errors, one containing the
%                   validation  warnings, and one containing the extension
%                   allowed validation warnings. The default directory will
%                   be the directory that contains the tab-delimited text
%                  file.
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

function fPaths = validatedir(inDir, varargin)
p = parseArguments(inDir, varargin{:});
fPaths = validate(p);

    function hedMaps = getHEDMaps(p)
        % Gets a structure that contains Maps associated with the HED XML
        % tags
        hedMaps = loadHEDMaps();
        mapVersion = hedMaps.version;
        xmlVersion = getXMLHEDVersion(p.hedXML);
        if ~strcmp(mapVersion, xmlVersion);
            hedMaps = mapHEDAttributes(p.hedXML);
        end
    end % getHEDMaps

    function fPaths = validate(p)
        % Validates all .set files in the input directory
        p.hedMaps = getHEDMaps(p);
        fPaths = getfilelist(p.inDir, '.set', p.doSubDirs);
        numFiles = length(fPaths);
        for a = 1:numFiles
            p.eeg = pop_loadset(fPaths{a});
            p.fPath = fPaths{a};
            if isfield(p.eeg.event, p.tagField)
                [p.errorLog, p.warningLog, p.extensionLog] = ...
                    parseStructTags(p.hedMaps, p.eeg.event, p.tagField, ...
                    p.extensionAllowed);
                    createLogs(p);
            else
                fprintf(['The ''.%s'' field does not exist in the' ...
                    ' EEG events. Please tag the dataseet before' ...
                    ' running the validation.\n'], p.tagField);
            end
        end
    end % validate

    function hedMaps = loadHEDMaps()
        % Loads a structure that contains Maps associated with the HED XML
        % tags
        Maps = load('hedMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHEDMap

    function p = parseArguments(inDir, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('inDir', @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('doSubDirs', true, @islogical);
        p.addParamValue('errorLogOnly', true, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('extensionAllowed', true, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('tagField', 'usertags', ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('hedXML', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('outDir', pwd, ...
            @(x) ischar(x));
        p.parse(inDir, varargin{:});
        p = p.Results;
    end % parseArguments

    function createErrorLog(p)
        % Creates a error log
        numErrors = length(p.errorLog);
        errorFile = fullfile(p.dir, [p.file '_error_log' p.ext]);
        if ~exist(p.dir, 'dir')
            mkdir(p.dir);
        end
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
        p.dir = fileparts(strrep(p.fPath, p.inDir, p.outDir));
        [~, p.file] = fileparts(p.eeg.filename);
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

end % validateDir