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
%   'DoSubDirs'
%                   If true (default), the entire inDir directory tree is
%                   searched. If false, only the inDir directory is
%                   searched.
%
%   'generateWarnings'
%                   If true, include warnings in the log file in addition
%                   to errors. If false (default), only errors are included
%                   in the log file.
%
%   'hedXml'
%                   The full path to a HED XML file containing all of the
%                   tags. This by default will be the HED.xml file
%                   found in the hed directory.
%
%   'outputFileDirectory'
%                   The directory where the log files are written to.
%                   There will be a log file generated for each directory
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function fPaths = validatedir(inDir, varargin)
p = parseArguments(inDir, varargin{:});
fPaths = validate(p);

    function fPaths = validate(p)
        % Validates all .set files in the input directory
        fPaths = getfilelist(p.inDir, '.set', p.DoSubDirs);
        numFiles = length(fPaths);
        nonTaggedSets = {};
        nonTagedIndex = 1;
        for a = 1:numFiles
            p.EEG = pop_loadset(fPaths{a});
            p.fPath = fPaths{a};
            if isfield(p.EEG.event, 'usertags') || ...
                    isfield(p.EEG.event, 'hedtags')
                p.issues = ...
                    parseeeg(p.hedXml, p.EEG.event, p.generateWarnings);
                writeOutputFile(p);
            else
                if ~isempty(p.EEG.filename)
                    nonTaggedSets{nonTagedIndex} = ...
                        fullfile(p.EEG.filepath, p.EEG.filename); %#ok<AGROW>
                else
                    nonTaggedSets{nonTagedIndex} = ...
                        fullfile(p.EEG.filepath, p.EEG.setname); %#ok<AGROW>
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

    function p = parseArguments(inDir, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('inDir', @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('DoSubDirs', true, @islogical);
        p.addParamValue('generateWarnings', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('hedXml', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('outputFileDirectory', pwd, ...
            @(x) ischar(x));
        p.parse(inDir, varargin{:});
        p = p.Results;
    end % parseArguments

    function writeOutputFile(p)
        % Writes the issues found to a log file
        p.dir = p.outputFileDirectory;
        fPathLeftOver = strrep(p.fPath, p.inDir, '');
        leftOverDir = fileparts(fPathLeftOver);
        if length(leftOverDir) > 1
            p.dir = fullfile(p.dir, leftOverDir);
        end
        if ~isempty(p.EEG.filename)
            [~, p.file] = fileparts(p.EEG.filename);
        else
            [~, p.file] = fileparts(p.EEG.setname);
        end
        p.ext = '.txt';
        try
            if ~isempty(p.issues)
                createLogFile(p, false);
            else
                createLogFile(p, true);
            end
        catch ME
            throw(MException('validatedir:cannotWrite', ...
                'Could not write output file'));
        end
    end % writeOutputFiles

    function createLogFile(p, empty)
        % Creates a log file containing any issues found through the
        % validation
        numErrors = length(p.issues);
        errorFile = fullfile(p.dir, ['validated_' p.file p.ext]);
        if ~exist(p.dir, 'dir')
            mkdir(p.dir);
        end
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