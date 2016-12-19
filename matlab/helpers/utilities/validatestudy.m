% This function takes in a directory containing EEG datasets and validates
% the tags the against the latest HED schema.
%
% Usage:
%
%   >>  validatestudy(study);
%
%   >>  validatestudy(study, 'key1', 'value1', ...);
%
% Input:
%
%   studyFile
%                   The full path to an EEG study file.
%
%   Optional:
%
%   'GenerateWarnings'
%                   True to include warnings in the log file in addition
%                   to errors. If false (default) only errors are included
%                   in the log file.
%
%   'HedXml'
%                   The full path to a HED XML file containing all of the
%                   tags. This by default will be the HED.xml file
%                   found in the hed directory.
%
%   'OutputFileDirectory'
%                   The directory where the log files are written to.
%                   There will be a log file generated for each study
%                   dataset validated. The default directory will be the
%                   current directory.
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function fPaths = validatestudy(studyFile, varargin)
p = parseArguments(studyFile, varargin{:});
fPaths = validate(p);

    function hedMaps = getHEDMaps(p)
        % Gets a structure that contains Maps associated with the HED XML
        % tags
        hedMaps = loadHEDMaps();
        mapVersion = hedMaps.version;
        xmlVersion = getxmlversion(p.HedXml);
        if ~isempty(xmlVersion) && ~strcmp(mapVersion, xmlVersion);
            hedMaps = mapHEDAttributes(p.HedXml);
        end
    end % getHEDMaps

    function fPaths = validate(p)
        % Validates all .set files in the input directory
        p.hedMaps = getHEDMaps(p);
        [~, fPaths] = loadstudy(p.studyFile);
        numFiles = length(fPaths);
        nonTaggedSets = {};
        nonTagedIndex = 1;
        for a = 1:numFiles
            p.EEG = pop_loadset(fPaths{a});
            p.fPath = fPaths{a};
            if isfield(p.EEG.event, 'usertags') || ...
                    isfield(p.EEG.event, 'hedtags')
                [p.issues, p.replaceTags] = parseeeg(p.hedMaps, ...
                    p.EEG.event, p.GenerateWarnings);
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
        if ~isempty(nonTaggedSets)
            printNonTaggedDatasets(nonTaggedSets);
        end
    end % validate

    function printNonTaggedDatasets(nonTaggedSets)
        % Prints all datasets in directory that are not tagged
        numFiles = length(nonTaggedSets);
        datasets = nonTaggedSets{1};
        for a = 2:numFiles
            datasets = [datasets sprintf('\n%s' , nonTaggedSets{a})];             %#ok<AGROW>
        end
        warning('Please tag the following dataset(s):\n%s', datasets);
    end % printNonTaggedDatasets

    function [s, fNames] = loadstudy(studyFile)
        % Set baseTags if tagsFile contains an tagMap object
        try
            t = load('-mat', studyFile);
            tFields = fieldnames(t);
            s = t.(tFields{1});
            sPath = fileparts(studyFile);
            fNames = getstudyfiles(s, sPath);
        catch ME %#ok<NASGU>
            warning('tagstudy:loadStudyFile', 'Invalid study file');
            s = '';
            fNames = '';
        end
    end % loadstudy

    function fNames = getstudyfiles(study, sPath)
        % Set baseTags if tagsFile contains an tagMap object
        datasets = {study.datasetinfo.filename};
        paths = {study.datasetinfo.filepath};
        validPaths = true(size(paths));
        fNames = cell(size(paths));
        for ik = 1:length(paths)
            fName = fullfile(paths{ik}, datasets{ik}); % Absolute path
            if ~exist(fName, 'file')  % Relative to stored study path
                fName = fullfile(study.filepath, paths{ik}, datasets{ik});
            end
            if ~exist(fName, 'file') % Relative to actual study path
                fName = fullfile(sPath, paths{ik}, datasets{ik});
            end
            if ~exist(fName, 'file') % Give up
                warning('tagstudy:getStudyFiles', ...
                    ['Study file ' fname ' doesn''t exist']);
                validPaths(ik) = false;
            end
            fNames{ik} = fName;
        end
        fNames(~validPaths) = [];  % Get rid of invalid paths
    end % getstudyfiles

    function hedMaps = loadHEDMaps()
        % Loads a structure that contains Maps associated with the HED XML
        % tags
        Maps = load('hedMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHEDMap

    function p = parseArguments(studyFile, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('studyFile', @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('GenerateWarnings', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('HedXml', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('OutputFileDirectory', pwd, ...
            @(x) ischar(x));
        p.parse(studyFile, varargin{:});
        p = p.Results;
    end % parseArguments

    function writeOutputFiles(p)
        % Writes the issues and replace tags found to a log file and a
        % replace file
        p.dir = p.OutputFileDirectory;
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
            else
                createLogFile(p, true);
            end
        catch
            throw(MException('validatestudy:cannotWrite', ...
                'Could not write log file'));
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

end % validatestudy