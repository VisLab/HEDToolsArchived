% GUI for input needed to update the current HED version.
%
% Usage:
%
%   >>  updatehed_input(tab)
%
% Input:
%
%   tab              A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
%                    information.
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

function updatehed_input(tab)
versionCtrl = '';
currentVersion = getXMLHEDVersion('HED.xml');
createPanel(tab);

    function createButtons(panel)
        % Creates the buttons in the tab panel
        uicontrol('Parent', panel, ...
            'String', 'Check', ...
            'Style', 'pushbutton', ...
            'TooltipString', 'Press to check for latest HED version', ...
            'Units','normalized',...
            'Callback', {@checkUpdateCallback}, ...
            'Position', [0.775 0.025 0.2 0.1]);
    end % createButtons

    function createLabels(panel)
        % Creates the labels in the tab panel
        uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', 'Check for a newer HED version', ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0 0.8 0.5 0.2]);
        versionCtrl = uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', ['Current HED version: ' currentVersion], ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0 0 0.5 0.05]); 
    end % createLabels

    function createPanel(tab)
        % Creates the tab panel 
        panel = uipanel('Parent', tab, ...
            'BorderType', 'none', ...
            'BackgroundColor', [.94 .94 .94], ...
            'FontSize', 12, ...
            'Position', [0 0 1 1]);
        createLabels(panel);
        createButtons(panel);
    end % createPanel

    function checkUpdateCallback(~, ~) 
        % Callback for 'Check' button
        latestVersion = downloadHED();
        if ~strcmp(currentVersion, latestVersion)
            [okay, success] = availablehed_input(latestVersion);
            if okay && success
                currentVersion = latestVersion;
                set(versionCtrl, 'String', ...
                    ['Current HED version: ' currentVersion]);
            end
        else
            msgbox('The current version is up to date');
        end
    end % checkUpdateCallback

end % updatehed_input