% Allows a user to validate the HED tags in a EEGLAB study and its
% associated .set files using a GUI.
%
% Usage:
%
%   >>  [fPaths, com] = pop_validatestudy()
%
%   >>  [fPaths, com] = pop_validatestudy(studyFile)
%
%   >>  [fPaths, com] = pop_validatestudy(studyFile, 'key1', value1 ...)
%
% Input:
%
%   Optional:
%
%   UseGui
%                    If true (default), use a series of menus to set
%                    function arguments.
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
%                   The directory where the log files are written to.
%                   There will be a log file generated for each study
%                   dataset validated. The default directory will be the
%                   current directory.
%
%   'StudyFile'
%                   The full path to an EEG study file.
%
% Output:
%
%   fPaths           A list of full file names of the datasets to be
%                    validated.
%
%   com
%                  String containing call to tagstudy with all parameters
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

function [fPaths, com] = pop_validatestudy(varargin)
fPaths = '';
com = '';

p = parseArguments(varargin{:});

% Call function with menu
if p.UseGui
    menuInputArgs = getkeyvalue({'GenerateWarnings', 'HedXml', 'InDir', ...
        'OutputFileDirectory', 'StudyFile'}, varargin{:});
    [canceled, generateWarnings, hedXML, outDir, studyFile] = ...
        pop_validatestudy_input(menuInputArgs{:});
    if canceled
        return;
    end
    inputArgs = {'GenerateWarnings', generateWarnings, 'HedXml', ...
        hedXML, 'OutputFileDirectory', outDir, 'StudyFile', studyFile};
    fPaths = validatestudy(studyFile, inputArgs{:});
    com = char(['pop_validatestudy(' logical2str(p.UseGui) ', ' ...
        keyvalue2str(varargin{:}) ');']);
else
    % Call function without menu
    if isempty(p.StudyFile)
        warning('Study file is not specified... exiting function');
        return;
    end
    if nargin > 1
        inputArgs = getkeyvalue({'GenerateWarnings', ...
            'HedXml', 'OutputFileDirectory', 'StudyFile'}, varargin{:});
        fPaths = validatestudy(p.StudyFile, inputArgs{:});
        com = char(['pop_validatestudy(' logical2str(p.UseGui) ', ' ...
            keyvalue2str(varargin{2:end}) ');']);
    end
end

    function p = parseArguments(varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addOptional('UseGui', true, @islogical);
        p.addParamValue('GenerateWarnings', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('HedXml', which('HED.xml'), ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('StudyFile', '', @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('OutputFileDirectory', pwd, ...
            @(x) ischar(x));
        p.parse(varargin{:});
        p = p.Results;
    end % parseArguments

end % pop_validatestudy