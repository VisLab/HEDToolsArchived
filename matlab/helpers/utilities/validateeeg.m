% This function validates the HED tags in a EEG dataset structure against
% a HED schema.
%
% Usage:
%
%   >>  issues = validateeeg(EEG)
%
%   >>  issues = validateeeg(EEG, 'key1', 'value1', ...)
%
% Input:
%
%   EEG         
%                   A EEG dataset structure containing HED tags.
%
%   Optional (key/value):
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
%                   The directory where the validation output is written 
%                   to. There will be a log file generated for each study
%                   dataset validated.
%
%   'WriteOutputToFile'
%                   If true (default), write the validation issues to a
%                   log file in addition to the workspace. If false only
%                   write the issues to the workspace. 
%
% Output:
%
%   issues
%                   A cell array containing all of the issues found through
%                   the validation. Each cell corresponds to the issues
%                   found on a particular line.
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

function issues = validateeeg(EEG, varargin)
p = parseArguments(EEG, varargin{:});
issues = validate(p);

    function issues = validate(p)
        % Validates the eeg structure
        p.hedMaps = getHEDMaps(p);
        if isfield(p.EEG.event, 'usertags') || ...
                isfield(p.EEG.event, 'hedtags')
            [p.issues, p.replaceTags] = parseeeg(p.hedMaps, ...
                p.EEG.event, p.GenerateWarnings);
            issues = p.issues;
            if p.WriteOutputToFile
                writeOutputFiles(p);
            end
        else
            issues = '';
            fprintf(['The usertags and hedtags fields do not exist in' ...
                ' the events. Please tag this dataset before' ...
                ' running the validation.\n']);
        end
    end % validate

    function hedMaps = getHEDMaps(p)
        % Gets a structure that contains Maps associated with the HED XML
        % tags
        hedMaps = loadHEDMap();
        mapVersion = hedMaps.version;
        xmlVersion = getxmlversion(p.HedXml);
        if ~isempty(xmlVersion) && ~strcmp(mapVersion, xmlVersion)
            hedMaps = mapHEDAttributes(p.HedXml);
        end
    end % getHEDMaps

    function hedMaps = loadHEDMap()
        % Loads a structure that contains Maps associated with the HED XML
        % tags
        Maps = load('hedMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHEDMap

    function p = parseArguments(EEG, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('EEG', @(x) (~isempty(x) && isstruct(x)));
        p.addParamValue('GenerateWarnings', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('HedXml', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('OutputFileDirectory', pwd, @ischar);
        p.addParamValue('WriteOutputToFile', true, @islogical);
        p.parse(EEG, varargin{:});
        p = p.Results;
    end % parseArguments

    function writeOutputFiles(p)
        % Writes the issues to the log file
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
            throw(MException('validateeeg:cannotWrite', ...
                'Could not write log file'));
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

end % validateeeg