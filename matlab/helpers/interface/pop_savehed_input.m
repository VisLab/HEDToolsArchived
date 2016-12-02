% GUI to create inputs for pop_savehed().
%
% Usage:
%
%   >>  [canceled, overwriteUserHed, separateUserHedFile, ...
%       writeSeparateUserHedFile] = pop_savehed_input()
%
%   >>  [canceled, overwriteUserHed, separateUserHedFile, ...
%       writeSeparateUserHedFile] = pop_savehed_input(varargin)
%
%   Optional (key/value):
%
%   'OverwriteUserHed'
%                    If true, check the 'Create/overwrite the HEDTools
%                    HED_USER.xml with the current' checkbox.  
%
%   'SeparateUserHedFile'
%                    If specified, set 'HED file name' edit box to this.
%
%   'WriteSeparateUserHedFile'
%                    If true, check the 'Save the current HED as a separate
%                    XML file (outside of HEDTools)' checkbox.  
%
% Output:
%
%   canceled
%                    If true, the cancel button has been pushed in the
%                    menu.
%
%   overwriteUserHed
%                    If true, the 'Create/overwrite the HEDTools
%                    HED_USER.xml with the current' checkbox is checked.
%
%   separateUserHedFile
%                    The 'HED file name' edit box string. 
%
%   writeSeparateUserHedFile
%                    If true, write the the fieldMap object to the file
%                    specified by the 'SeparateUserHedFile' argument.
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

function [canceled, overwriteUserHed, separateUserHedFile, ...
    writeSeparateUserHedFile] = pop_savehed_input(varargin)
p = parseArguments(varargin{:});
checkText1 = ['Create/overwrite the HEDTools HED_USER.xml with the' ...
    ' current HED'];
checkText2 = ['Save the current HED as a separate XML file' ...
    ' (outside of HEDTools)'];
enableSeparateUserHedFile = 'off';
if p.WriteSeparateUserHedFile
    enableSeparateUserHedFile = 'on';
end
% if ~isempty(p.SeparateUserHedFile)
%     p.WriteSeparateUserHedFile = true;
%     enableSeparateUserHedFile = 'on';
% end
canceled = true;
overwriteUserHed = false;
separateUserHedFile = '';
writeSeparateUserHedFile = false;
geometry = {1 1 1 [1 4 .75]};
uilist = { ...
    { 'Style' 'checkbox' 'string' checkText1 'value' ...
    p.OverwriteUserHed} ...
    { 'Style' 'checkbox' 'string' checkText2 'value' ...
    p.WriteSeparateUserHedFile 'callback' @saveHEDCallback} ...
    { } ...
    { 'Style' 'text' 'string' 'HED file name:'} ...
    { 'Style' 'edit' 'string' p.SeparateUserHedFile 'tag' 'fMapPath' ...
    'enable' enableSeparateUserHedFile} ...
    { 'Style' 'pushbutton' 'string' 'Browse' 'callback' ...
    @browseHEDCallback 'tag'  'fMapBrowseButton' 'enable' ...
    enableSeparateUserHedFile}};

results = inputgui( geometry, uilist, 'pophelp(''pop_savetags'')', ...
    'Save HED schema - pop_savehed()');
if ~isempty(results)
    canceled = false;
    overwriteUserHed = logical(results{1});
    writeSeparateUserHedFile = logical(results{2});
    separateUserHedFile = results{3};
end

    function saveHEDCallback(src, ~)
        % Callback for save HED checkbox
        value = get(src, 'Max') == get(src, 'Value');
        status = getOnOff(value);
        set(findobj('Tag', 'fMapPath'), 'enable', status);
        set(findobj('Tag', 'fMapBrowseButton'), 'enable', status);
    end % saveHEDCallback

    function status = getOnOff(logValue)
        % Returns 'on' if the logValue is true, 'off' if otherwise
        status = 'off';
        if logValue
            status = 'on';
        end
    end % getOnOff

    function browseHEDCallback(~, ~)
        % Callback for field map 'Browse' button
        [file,path] = uiputfile({'*.xml', 'XML Files (*.xml)'}, ...
            'Save HED schema', 'HED.xml');
        if ischar(file) && ~isempty(file)
            saveMapFile = fullfile(path, file);
            set(findobj('Tag', 'fMapPath'), 'String', saveMapFile);
        end
    end % browseHEDCallback

    function p = parseArguments(varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addParamValue('OverwriteUserHed', false, @islogical);
        parser.addParamValue('SeparateUserHedFile', '', @(x) ...
            (isempty(x) || (ischar(x))));
        parser.addParamValue('WriteSeparateUserHedFile', false, ...
            @islogical);
        parser.parse(varargin{:});
        p = parser.Results;
    end % parseArguments

end % pop_savehed_input