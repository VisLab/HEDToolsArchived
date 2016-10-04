% This function takes in a directory containing EEG datasets and validates
% the tags against the latest HED schema.
%
% Usage:
%
%   >>  validateDir(inDir);
%
%   >>  validateDir(inDir, 'key1', 'value1', ...);
%
% Input:
%
%   inDir
%                   A directory containing EEG datasets that will be
%                   validated.
%
%   Optional (key/value):
%
%   'doSubDirs'
%                   If true (default), the entire inDir directory tree is
%                   searched. If false, only the inDir directory is
%                   searched.
%
%   'generateWarnings'
%                   If true, include warnings in the log file in addition
%                   to errors. If false (default), only errors are included
%                   in the log file.
%
%   'hedXML'
%                   The full path to a HED XML file containing all of the
%                   tags. This by default will be the HED.xml file
%                   found in the hed directory.
%
%   'outDir'
%                   The directory where the log files are written to.
%                   There will be a log file generated for each directory
%                   dataset validated. The default directory will be the
%                   current directory. 
%
%   'tagField'
%                   The field in .event that contains the HED tags.
%                   The default field is .usertags.
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

function fPaths = validatedir(inDir, varargin)
p = parseArguments(inDir, varargin{:});
fPaths = validate(p);

    function hedMaps = getHEDMaps(p)
        % Gets a structure that contains Maps associated with the HED XML
        % tags
        hedMaps = loadHEDMaps();
        mapVersion = hedMaps.version;
        xmlVersion = getxmlversion(p.hedXML);
        if ~strcmp(mapVersion, xmlVersion);
            hedMaps = mapHEDAttributes(p.hedXML);
        end
    end % getHEDMaps

    function fPaths = validate(p)
        % Validates all .set files in the input directory
        p.hedMaps = getHEDMaps(p);
        fPaths = getfilelist(p.inDir, '.set', p.doSubDirs);
        numFiles = length(fPaths);
        nonTaggedSets = {};
        nonTagedIndex = 1;
        for a = 1:numFiles
            p.EEG = pop_loadset(fPaths{a});
            p.fPath = fPaths{a};
            if isfield(p.EEG.event, p.tagField)
                [p.issues, p.replaceTags] = ...
                    parseeeg(p.hedMaps, p.EEG.event,  p.tagField, ...
                    p.generateWarnings);
                    writeOutputFiles(p);
            else
                if ~isempty(p.EEG.filename)
                    nonTaggedSets{nonTagedIndex} = p.EEG.filename; %#ok<AGROW>
                else
                    nonTaggedSets{nonTagedIndex} = p.EEG.setname; %#ok<AGROW>
                end
                nonTagedIndex = nonTagedIndex + 1;
            end
        end
        printNonTaggedDatasets(p, nonTaggedSets);
    end % validate

    function printNonTaggedDatasets(p, nonTaggedSets)
        % Prints all datasets in directory that are not tagged
        numFiles = length(nonTaggedSets);
        for a = 1:numFiles
            fprintf(['Dataset %s: The ''.%s'' field does not exist in' ...
                ' the events. Please tag the dataset before' ...
                ' running the validation.\n'], nonTaggedSets{a}, ...
                p.tagField);
        end
    end % printNonTaggedDatasets

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
        % Writes the issues found to a log file
        p.dir = p.outDir;
        if ~isempty(p.EEG.filename)
            [~, p.file] = fileparts(p.EEG.filename);
        else
            [~, p.file] = fileparts(p.EEG.setname);
        end
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
            throw(MException('validatedir:cannotWrite', ...
                'Could not write output file'));
        end
    end % writeOutputFiles

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

end % validatedir