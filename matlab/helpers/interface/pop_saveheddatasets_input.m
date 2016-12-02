% GUI to create inputs for pop_saveheddatasets().
%
% Usage:
%
%   >>  [canceled, copyDatasets, copyDestination, overwriteDatasets] = ...
%       pop_saveheddatasets_input()
%
%   >>  [canceled, copyDatasets, copyDestination, overwriteDatasets] = ...
%       pop_saveheddatasets_input(varargin)
%
%   Optional (key/value):
%
%   'CopyDatasets'
%                    If true, the 'Copy original datasets to a separate
%                    directory and include the HED tags' checkbox is
%                    checked.
%
%   'CopyDestination'
%                    The 'Copy destination' edit box string.
%
%   'OverwriteDatasets'
%                    If true, the 'Overwrite the original datasets to
%                    include the HED tags' checkbox is checked. 
%
% Output:
%
%   canceled
%                    If true, the cancel button has been pushed in the
%                    menu.
%
%   copyDatasets
%                    If true, the 'Copy original datasets to a separate
%                    directory and include the HED tags' checkbox is
%                    checked.
%
%   copyDestination
%                    The 'Copy destination' edit box string.
%
%   overwriteDatasets
%                    If true, the 'Overwrite the original datasets to
%                    include the HED tags' checkbox is checked. 
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

function [canceled, copyDatasets, copyDestination, overwriteDatasets] = ...
    pop_saveheddatasets_input(varargin)
p = parseArguments(varargin{:});
checkText1 = 'Overwrite the original datasets to include the HED tags';
checkText2 = ['Copy original datasets to a separate directory and' ...
    ' include the HED tags'];
enableCopyDestination = 'off';
if p.CopyDatasets
    enableCopyDestination = 'on';
end
canceled = true;
overwriteDatasets = false;
copyDatasets = '';
copyDestination = false;
geometry = {1 1 1 [1 4 .75]};
uilist = { ...
    { 'Style' 'checkbox' 'string' checkText1 'value' ...
    p.OverwriteDatasets} ...
    { 'Style' 'checkbox' 'string' checkText2 'value' ...
    p.CopyDatasets 'callback' @copyDatasetsCallback} ...
    { } ...
    { 'Style' 'text' 'string' 'Copy destination:'} ...
    { 'Style' 'edit' 'string' p.CopyDestination 'tag' 'copyDestination' ...
    'enable' enableCopyDestination} ...
    { 'Style' 'pushbutton' 'string' 'Browse' 'callback' ...
    @browseCopyDestinationCallback 'tag'  'copyDestinationBrowseButton' ...
    'enable' enableCopyDestination}};

results = inputgui( geometry, uilist, 'pophelp(''pop_savetags'')', ...
    'Save datasets - pop_saveheddatasets()');
if ~isempty(results)
    canceled = false;
    overwriteDatasets = logical(results{1});
    copyDatasets = logical(results{2});
    copyDestination = results{3};
end

    function copyDatasetsCallback(src, ~)
        % Callback for copying datasets
        value = get(src, 'Max') == get(src, 'Value');
        status = getOnOff(value);
        set(findobj('Tag', 'copyDestination'), 'enable', status);
        set(findobj('Tag', 'copyDestinationBrowseButton'), 'enable', ...
            status);
    end % copyDatasetsCallback

    function status = getOnOff(logValue)
        % Returns 'on' if the logValue is true, 'off' if otherwise
        status = 'off';
        if logValue
            status = 'on';
        end
    end % getOnOff

    function browseCopyDestinationCallback(~, ~)
        % Callback for copy destination 'Browse' button
        directory = uigetdir(pwd, 'Browse for copy directory');
        if directory ~= 0
            set(findobj('Tag', 'copyDestination'), 'String', directory);
        end
    end % browseCopyDestinationCallback

    function p = parseArguments(varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addParamValue('CopyDatasets', false, @islogical);
        parser.addParamValue('CopyDestination', '', @(x) ...
            (isempty(x) || (ischar(x))));
        parser.addParamValue('OverwriteDatasets', false, @islogical);
        parser.parse(varargin{:});
        p = parser.Results;
    end % parseArguments

end % pop_savehed_input