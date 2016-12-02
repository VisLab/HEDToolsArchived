% GUI to create inputs for pop_savefmap().
%
% Usage:
%
%   >>  [canceled, fMapDescription, fMapSaveFile, writeFMapToFile] = ...
%       pop_savefmap_input()
%
%   >>  [canceled, fMapDescription, fMapSaveFile, writeFMapToFile] = ...
%       pop_savefmap_input(varargin)
%
%   Optional (key/value):
%
%   'FMapDescription'
%                    If specified, set the 'Field map description' edit box
%                    to this when pressing the 'Edit description' 
%                    button.
%
%   'FMapSaveFile'
%                    If specified, set 'field map file name' edit box to 
%                    this.
%
%   'WriteFMapToFile'
%                    If true, check the 'Save the tags as a field map'
%                    checkbox.  
%
% Output:
%
%   canceled
%                    If true, the cancel button has been pushed in the
%                    menu.
%
%   fMapDescription
%                    If true, the 'Create/overwrite the HEDTools
%                    HED_USER.xml with the current' checkbox is checked.
%
%   fMapSaveFile
%                    The 'field map file name' edit box string. 
%
%   writeFMapToFile
%                    If true, enable the 'field map file name' edit box.
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

function [canceled, fMapDescription, fMapSaveFile, writeFMapToFile] = ...
    pop_savefmap_input(varargin)
p = parseArguments(varargin{:});
enablefMapFile = 'off';
if p.WriteFMapToFile
    enablefMapFile = 'on';
end
canceled = true;
checkText1 = 'Save the tags as a field map';
fMapSaveFile = '';
fMapDescription = '';
writeFMapToFile = false;
geometry = {1 1 [1 4 0 .75 1]};
uilist = { ...
    { 'Style' 'checkbox' 'string' checkText1 'value' p.WriteFMapToFile ...
    'callback' @savefMapCallback} ...
    { } ...
    { 'Style' 'text' 'string' 'field map file name:'} ...
    { 'Style' 'edit' 'string' p.FMapSaveFile 'tag' 'fMapPath' 'enable' ...
    enablefMapFile} ...
    { 'Style' 'edit' 'string' p.FMapDescription 'Max' 2 'tag' ...
    'fMapDescription' 'enable' 'off'} ...
    { 'Style' 'pushbutton' 'string' 'Browse' 'callback' ...
    @browsefMapCallback 'tag'  'fMapBrowseButton' 'enable' ...
    enablefMapFile} ...
    { 'Style' 'pushbutton' 'string' 'Edit description' 'callback' ...
    @fMapdescriptionCallback 'tag'  'fMapDescriptionButton'}};

results = inputgui( geometry, uilist, 'pophelp(''pop_savefmap'')', ...
    'Save field map - pop_savefmap()');
if ~isempty(results)
    canceled = false;
    writeFMapToFile = logical(results{1});
    fMapSaveFile = results{2};
    fMapDescription = results{3};
end

    function fMapdescriptionCallback(~, ~)
        % Callback for field map 'Edit description' button
        description = get(findobj('Tag', 'fMapDescription'), 'String');
        description = pop_comments(description, 'Field map description');
        set(findobj('Tag', 'fMapDescription'), 'String', description);
    end % fMapdescriptionCallback

    function savefMapCallback(src, ~)
        % Callback for save field map checkbox
        value = get(src, 'Max') == get(src, 'Value');
        status = getOnOff(value);
        set(findobj('Tag', 'fMapPath'), 'enable', status);
        set(findobj('Tag', 'fMapBrowseButton'), 'enable', status);
    end % savefMapCallback

    function status = getOnOff(logValue)
        % Returns 'on' if the logValue is true, 'off' if otherwise
        status = 'off';
        if logValue
            status = 'on';
        end
    end % getOnOff

    function browsefMapCallback(~, ~)
        % Callback for field map 'Browse' button
        [file,path] = uiputfile({'*.mat', 'MATLAB Files (*.mat)'}, ...
            'Save event tags', 'fMap.mat');
        if ischar(file) && ~isempty(file)
            saveMapFile = fullfile(path, file);
            set(findobj('Tag', 'fMapPath'), 'String', saveMapFile);
        end
    end % browseSaveTagsCallback

    function p = parseArguments(varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addParamValue('FMapDescription', '', @ischar);
        parser.addParamValue('FMapSaveFile', '', @(x)(isempty(x) || ...
            (ischar(x))));
        parser.addParamValue('WriteFMapToFile', false, @islogical);
        parser.parse(varargin{:});
        p = parser.Results;
    end % parseArguments

end % pop_savefmap_input