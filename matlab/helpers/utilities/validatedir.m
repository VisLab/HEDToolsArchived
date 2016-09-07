% This function takes in a directory containing EEG datasets and validates
% the tags the against the latest HED schema.
%
% Usage:
%
%   >>  validateDir(inDir);
%   >>  validateDir(inDir, varargin);
%
% Input:
%
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
%                   The directory where the validation files are written
%                   to. The default output directory will be the current
%                   directory
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
                [p.issues, p.replaceTags, success] = ...
                    parseeeg(p.hedMaps, p.eeg.event,  p.tagField, ...
                    p.generateWarnings);
                if success
                    writeOutputFiles(p);
                end
            else
                fprintf(['The ''.%s'' field does not exist in the' ...
                    ' EEG events. Please tag the dataset before' ...
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
        p.addParamValue('generateWarnings', false, ...
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

    function writeOutputFiles(p)
        % Writes the errors, warnings, extension allowed warnings to
        % the output files
        p.dir = p.outDir;
        [~, p.file] = fileparts(p.eeg.filename);
        p.ext = '.txt';
        p.mapExt = '.tsv';
        try
            if ~isempty(p.issues)
                createLogFile(p, false);
            else
                createLogFile(p, true);
            end
        catch
            throw(MException('validatetsv:cannotWrite', ...
                'Could not write output files'));
        end
    end % writeOutputFiles

    function createLogFile(p, empty)
        % Creates a log file containing any issues
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

end % validatedir