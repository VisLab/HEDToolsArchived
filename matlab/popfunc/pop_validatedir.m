% Allows a user to validate a directory of EEG .set datasets using a GUI.
%
% Usage:
%
%   >>  [fPaths, com] = pop_validatedir()
%
%   >>  [fPaths, com] = pop_validatedir(inDir)
%
%   >>  [fPaths, com] = pop_validatedir(inDir, 'key1', value1 ...)
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
%   'DoSubDirs'
%                   If true (default), the entire inDir directory tree is
%                   searched. If false, only the inDir top-level directory
%                   is searched.
%
%   'GenerateWarnings'
%                   If true, include warnings in the log file in addition
%                   to errors. If false (default), only errors are included
%                   in the log file.
%
%   'HedXml'
%                   The full path to a HED XML file containing all of the
%                   tags. This by default will be the HED.xml file
%                   found in the hed directory.
%
%   'InDir'
%                   A directory containing tagged EEG datasets that will be
%                   validated.
%
%   'OutputFileDirectory'
%                   The directory where the log files are written to.
%                   There will be a log file generated for each directory
%                   dataset validated. The default directory will be the
%                   current directory.
%
% Output:
%
%   fPaths           A list of full file names of the datasets to be
%                    validated.
%
%   com              String containing call to tagdir with all
%                    parameters.
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA


function [fPaths, com] = pop_validatedir(varargin)
fPaths = '';
com = '';

p = parseArguments(varargin{:});

% Call function with menu
if p.UseGui
    menuInputArgs = getkeyvalue({'DoSubDirs', 'GenerateWarnings', ...
        'HedXml', 'InDir', 'OutputFileDirectory'}, varargin{:});
    [canceled, doSubDirs, generateWarnings, hedXML, inDir, outDir] = ...
        pop_validatedir_input(menuInputArgs{:});
    if canceled
        return;
    end
    inputArgs = {'DoSubDirs', doSubDirs, 'GenerateWarnings', ...
        generateWarnings, 'HedXml', hedXML, 'InDir', inDir, ...
        'OutputFileDirectory', outDir};
    fPaths = validatedir(inDir, inputArgs{:});
    com = char(['pop_validatedir(' logical2str(p.UseGui) ', ' ...
        keyvalue2str(varargin{:}) ');']);
    
else
    inputArgs = getkeyvalue({'DoSubDirs', 'GenerateWarnings', ...
        'HedXml', 'InDir', 'OutputFileDirectory'}, varargin{:});
    fPaths = validatedir(p.InDir, inputArgs{:});
    if nargin == 1
        com = char(['pop_validatedir(' logical2str(p.UseGui) ');']);        
    end
    if nargin > 1    
        com = char(['pop_validatedir(' logical2str(p.UseGui) ', ' ...
            keyvalue2str(varargin{2:end}) ');']);
    end
end

    function p = parseArguments(varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addOptional('UseGui', true, @islogical);
        p.addParamValue('DoSubDirs', true, @islogical);
        p.addParamValue('GenerateWarnings', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('HedXml', which('HED.xml'), ...
            @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('InDir', pwd, @(x) (~isempty(x) && ischar(x)));
        p.addParamValue('OutputFileDirectory', pwd, ...
            @(x) ischar(x));
        p.parse(varargin{:});
        p = p.Results;
    end % parseArguments

end % pop_validatedir