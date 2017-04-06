% Allows the user to save the HED from a fieldMap object to a file with or
% without a menu.
%
% Usage:
%
%   >>  [fMap, com] = pop_savehed(fMap)
%
%   >>  [fMap, com] = pop_savehed(fMap, UseGui)
%
%   >>  [fMap, com] = pop_savehed(fMap, UseGui, 'key1', value1 ...)
%
%   >>  [fMap, com] = pop_savehed(fMap, 'key1', value1 ...)
%
% Graphic interface:
%
%   "Create/overwrite the HEDTools HED_USER.xml with the current HED"
%
%                    If true, overwrite/create the 'HED_USER.xml' file with
%                    the HED from the fieldMap object. The
%                    'HED_USER.xml' file is made specifically for modifying
%                    the original 'HED.xml' file. This file will be written
%                    under the 'hed' directory.
%
%   "Save the current HED as a separate XML file (outside of HEDTools)"
%
%                    If checked, write the the fieldMap object to a
%                    separate file outside of HEDTools.
%
%   "HED file name
%
%                    The full path and file name to write the HED from the
%                    fieldMap object to. This file is meant to be
%                    stored outside of the HEDTools.
%
% Input:
%
%   Required:
%
%   fMap
%                    A fieldMap object that stores the HED.
%
%   Optional:
%
%   UseGui
%                    If true (default), use a menu for specifying the
%                    function arguments. If false, call the function
%                    directly without a menu.
%
%   Optional (key/value):
%
%   'OverwriteUserHed'
%                    If true, overwrite/create the 'HED_USER.xml' file with
%                    the HED from the 'fMap' fieldMap object. The
%                    'HED_USER.xml' file is made specifically for modifying
%                    the original 'HED.xml' file. This file will be written
%                    under the 'hed' directory.
%
%   'SeparateUserHedFile'
%                    The full path and file name to write the HED from the
%                    'fmap' fieldMap object to. This file is meant to be
%                    stored outside of the HEDTools.
%
%   'WriteSeparateUserHedFile'
%                    If true, write the fieldMap object to the file
%                    specified by the 'SeparateUserHedFile' argument.
%
% Output:
%
%   fMap
%                    A fieldMap object that stores the HED.
%
%   com
%                    String containing call to pop_savehed() with all
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [fMap, overwriteUserHed, separateUserHedFile, ...
    writeSeparateUserHedFile, com] = pop_savehed(fMap, varargin)
com = '';
overwriteUserHed = false;
separateUserHedFile = '';
writeSeparateUserHedFile = false;

% Display help if inappropriate number of arguments
if nargin < 1
    fMap = '';
    help pop_savehed;
    return;
end;

% Parse arguments
p = parseArguments(fMap, varargin{:});

% Load field map if it is a string
firstArg = inputname(1);
if ischar(p.FMap)
    firstArg = ['''' p.FMap ''''];
    p.FMap = fieldMap.loadFieldMap(p.FMap);
end

% Call function with menu
inputArgs = getkeyvalue({'OverwriteUserHed', 'SeparateUserHedFile', ...
    'WriteSeparateUserHedFile'}, varargin{:});

if p.UseGui
    [canceled, overwriteUserHed, separateUserHedFile, ...
        writeSeparateUserHedFile] = pop_savehed_input(inputArgs{:});
    if ~canceled
        inputArgs = {'OverwriteUserHed', overwriteUserHed, ...
            'SeparateUserHedFile', separateUserHedFile, ...
            'WriteSeparateUserHedFile', writeSeparateUserHedFile};
        processHED(p.FMap, overwriteUserHed, separateUserHedFile, ...
            writeSeparateUserHedFile);
    end
end

% Call function without menu
if nargin > 1 && ~p.UseGui
    processHED(p.FMap, p.OverwriteUserHed, p.SeparateUserHedFile, ...
        p.WriteSeparateUserHedFile);
end

% Create command string
com = char(['pop_savehed('  firstArg ', ' logical2str(p.UseGui) ...
    ', ' keyvalue2str(inputArgs{:}) ');']);

    function processHED(fMap, overwriteUserHed, separateUserHedFile, ...
            writeSeparateUserHedFile)
        % Save user HED to file(s)
        if overwriteUserHed
            dir = fileparts(which('HED.xml'));
            str2file(fMap.getXml(), fullfile(dir, 'HED_USER.xml'));
        end
        if writeSeparateUserHedFile && ~isempty(separateUserHedFile)
            str2file(fMap.getXml(), separateUserHedFile);
        end
    end % processHED

    function p = parseArguments(fMap, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('FMap', @(x) isa(x, 'fieldMap') || ischar(x));
        parser.addOptional('UseGui', true, @islogical);
        parser.addParamValue('OverwriteUserHed', false, @islogical);
        parser.addParamValue('SeparateUserHedFile', '', @(x) ...
            (isempty(x) || (ischar(x))));
        parser.addParamValue('WriteSeparateUserHedFile', false, ...
            @islogical);
        parser.parse(fMap, varargin{:});
        p = parser.Results;
    end % parseArguments

end % pop_savehed