% Allows the user to save a fieldMap object to a file with or without a
% menu.
%
% Usage:
%
%   >>  [fMap, com] = pop_savefmap(fMap)
%
%   >>  [fMap, com] = pop_savefmap(fMap, UseGui)
%
%   >>  [fMap, com] = pop_savefmap(fMap, UseGui, 'key1', value1 ...)
%
%   >>  [fMap, com] = pop_savefmap(fMap, 'key1', value1 ...)
%
% Graphic interface:
%
%   "Save the tags as a field map"
%
%                    If checked, write the fieldMap object to a file.
%
%   "field map file name"
%
%                    The full path and file name to write the fieldMap
%                    object to.
%
% Input:
%
%   Required:
%
%   fMap
%                    A fieldMap object that stores the tags.
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
%   'FMapDescription'
%                    The description of the 'fMap' fieldMap object. The
%                    description will show up in the .etc.tags.description
%                    field of any datasets tagged by this fieldMap.
%
%   'FMapSaveFile'
%                    The full path and file name to write the 'fmap'
%                    fieldMap object to. This file is used to retag
%                    datasets from the same study.
%
%   'WriteFMapToFile'
%                    If true, write the 'fmap' fieldMap object to the
%                    specified 'FMapSaveFile' file.
%
% Output:
%
%   fMap
%                    A fieldMap object that stores the tags.
%
%   fMapDescription
%                    The description of the 'fMap' fieldMap object. The
%                    description will show up in the .etc.tags.description
%                    field of any datasets tagged by this fieldMap.
%
%   fMapSaveFile
%                    The full path and file name to write the 'fmap'
%                    fieldMap object to. This file is used to retag
%                    datasets from the same study.
%
%   writeFMapToFile
%                    If true, write the 'fmap' fieldMap object to the
%                    specified 'FMapSaveFile' file.
%
%   com
%                    String containing call to pop_savehed with all
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

function [fMap, fMapDescription, fMapSaveFile, writeFMapToFile, com] = ...
    pop_savefmap(fMap, varargin)
com = '';
fMapDescription = '';
fMapSaveFile = '';
writeFMapToFile = false;

% Display help if inappropriate number of arguments
if nargin < 1
    fMap = '';
    help pop_savefmap;
    return;
end;

% Parse arguments
p = parseArguments(fMap, varargin{:});

% Load field map if it is a string
firstArg = inputname(1);
if ischar(p.FMap)
    if exist(p.FMap, 'file') ~= 2
        warning('field map file does not exist');
        return;
    end
    firstArg = ['''' p.FMap ''''];
    p.FMap = fieldMap.loadFieldMap(p.FMap);
end

inputArgs = getkeyvalue({'FMapDescription', 'FMapSaveFile', ...
    'WriteFMapToFile'}, varargin{:});

% Assign field map description if it exist 
if isempty(p.FMapDescription) && ~isempty(p.FMap.getDescription())
    p.FMapDescription = p.FMap.getDescription();
    inputArgs = [getkeyvalue({'FMapSaveFile', ...
        'WriteFMapToFile'}, varargin{:}) {'FMapDescription', ...
        p.FMapDescription}];
end

% Call function with menu
if p.UseGui
    [canceled, fMapDescription, fMapSaveFile, writeFMapToFile] = ...
        pop_savefmap_input(inputArgs{:});
    if ~canceled
        inputArgs = {'FMapDescription', fMapDescription, ...
            'FMapSaveFile', fMapSaveFile, 'WriteFMapToFile', ...
            writeFMapToFile};
        processfMap(p.FMap, fMapDescription, fMapSaveFile, ...
            writeFMapToFile);
    end
end

% Call function without menu
if nargin > 1 && ~p.UseGui
    processfMap(p.FMap, p.FMapDescription, p.FMapSaveFile, ...
        p.WriteFMapToFile);
end

% Create command string
com = char(['pop_savefmap('  firstArg ', '  logical2str(p.UseGui) ...
    ', ' keyvalue2str(inputArgs{:}) ');']);

    function processfMap(fMap, fMapDescription, fMapSaveFile, ...
            writeFMapToFile)
        % Updates and saves field map
        if ~isempty(fMapDescription)
            fMap.setDescription(fMapDescription);
        end
        if writeFMapToFile && ~isempty(fMapSaveFile)
            savefmap(fMap, fMapSaveFile);
        end
    end % processfMap

    function p = parseArguments(fMap, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('FMap', @(x) isa(x, 'fieldMap') || ischar(x));
        parser.addOptional('UseGui', true, @islogical);
        parser.addParamValue('FMapDescription', '', @ischar);
        parser.addParamValue('FMapSaveFile', '', @(x)(isempty(x) || ...
            (ischar(x))));
        parser.addParamValue('WriteFMapToFile', false, @islogical);
        parser.parse(fMap, varargin{:});
        p = parser.Results;
    end % parseArguments

end % pop_savefmap