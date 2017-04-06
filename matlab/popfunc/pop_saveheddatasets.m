% Allows the user to save HED tags to directory of datasets or a study
% and its associated datasets with or without a menu.
%
% Usage:
%
%   >>  [fMap, copyDatasets, copyDestination, overwriteDatasets, ...
%       com] = pop_saveheddatasets(fMap, source)
%
%   >>  [fMap, copyDatasets, copyDestination, overwriteDatasets, ...
%       com] = pop_saveheddatasets(fMap, source, UseGui)
%
%   >>  [fMap, copyDatasets, copyDestination, overwriteDatasets, ...
%       com] = pop_saveheddatasets(fMap, source, UseGui, 'key1',
%       value1 ...)
%
%   >>  [fMap, copyDatasets, copyDestination, overwriteDatasets, ...
%       com] = pop_saveheddatasets(fMap, source, 'key1', value1 ...)
%
% Graphic interface:
%
%   "Overwrite the original datasets to include the HED tags"
%
%                    If true, overwrite/create the 'HED_USER.xml' file with
%                    the HED from the fieldMap object. The
%                    'HED_USER.xml' file is made specifically for modifying
%                    the original 'HED.xml' file. This file will be written
%                    under the 'hed' directory.
%
%   "Copy original datasets to a separate directory and include the HED
%   tags"
%                    If true, copy the datasets to the 'CopyDestination'
%                    directory and write the HED tags to them.
%
%   "Copy destination"
%                    The full path of a directory to copy the original
%                    datasets to and write the HED tags to them.
%
% Input:
%
%   Required:
%
%   fMap
%                    A fieldMap object containing HED tags.
%
%   source
%                    The location of the datasets to write the HED tags to.
%                    The location can be a cell string containing paths to
%                    datasets, a string containing the full path of a
%                    directory containing datasets, the full path of a EEG
%                    study, or a EEG structure. If the location is a EEG
%                    structure then the HED tags will be written to the
%                    structure and the underlying dataset file.
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
%   'CopyDatasets'
%                    If true, copy the datasets to the 'CopyDestination'
%                    directory and write the HED tags to them.
%
%   'CopyDestination'
%                    The full path of a directory to copy the original
%                    datasets to and write the HED tags to them.
%
%   'OverwriteDatasets'
%                    If true, write the the HED tags to the original
%                    datasets.
%
% Output:
%
%   fMap
%                    A fieldMap object contains the HED tags.
%
%   com
%                    String containing call to pop_saveheddatasets() with
%                    all parameters.
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

function [fMap, copyDatasets, copyDestination, overwriteDatasets, ...
    com] = pop_saveheddatasets(fMap, source, varargin)
com = '';
copyDatasets = false;
copyDestination = '';
overwriteDatasets = false;

% Display help if inappropriate number of arguments
if nargin < 1
    fMap = '';
    help pop_saveheddatasets;
    return;
end;

% Parse arguments
p = parseArguments(fMap, source, varargin{:});

% Load field map if it is a string
firstArg = inputname(1);
if ischar(p.fMap)
    firstArg = ['''' p.fMap ''''];
    p.fMap = fieldMap.loadFieldMap(p.fMap);
end

secondArg = inputname(2);

% Call function with menu
inputArgs = getkeyvalue({'CopyDatasets', 'CopyDestination', ...
    'OverwriteDatasets'}, varargin{:});

if p.UseGui
    [canceled, copyDatasets, copyDestination, overwriteDatasets] = ...
        pop_saveheddatasets_input(inputArgs{:});
    if ~canceled
        inputArgs = {'CopyDatasets', copyDatasets, ...
            'CopyDestination', copyDestination, ...
            'OverwriteDatasets', overwriteDatasets};
        processDatasets(p.fMap, p.source, copyDatasets, ...
            copyDestination, overwriteDatasets, p.PreserveTagPrefixes);
    end
end

% Call function without menu
if nargin > 1 && ~p.UseGui
    processDatasets(p.fMap, p.source, p.CopyDatasets, ...
        p.CopyDestination, p.OverwriteDatasets, p.PreserveTagPrefixes);
end

% Create command string
com = char(['pop_saveheddatasets('  firstArg ', ' secondArg ', ' ...
    logical2str(p.UseGui) ', ' keyvalue2str(inputArgs{:}) ');']);

    function processDatasets(fMap, source, copyDatasets, ...
            copyDestination, overwriteDatasets, preserveTagPrefixes)
        % Save user HED to file(s)
        if overwriteDatasets
            savetags(fMap, source, 'PreserveTagPrefixes', ...
                preserveTagPrefixes);
        end
        if copyDatasets && ~isempty(copyDestination)
            source = copysetfiles(fMap, source, copyDestination);
            savetags(fMap, source, 'PreserveTagPrefixes', ...
                preserveTagPrefixes);
        end
    end % processHED

    function p = parseArguments(fMap, source, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('fMap', @(x) isa(x, 'fieldMap') || ischar(x));
        parser.addRequired('source', @(x) ischar(x) || isstruct(x) || ...
            iscellstr(x));
        parser.addOptional('UseGui', true, @islogical);
        parser.addParamValue('CopyDatasets', false, @islogical);
        parser.addParamValue('CopyDestination', '', @(x) ...
            (isempty(x) || (ischar(x))));
        parser.addParamValue('PreserveTagPrefixes', false, @islogical);
        parser.addParamValue('OverwriteDatasets', false, @islogical);
        parser.parse(fMap, source, varargin{:});
        p = parser.Results;
    end % parseArguments

end % pop_savehed