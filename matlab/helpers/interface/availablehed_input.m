% Shows a dialog that allows the user to choose rather or not they want to
% download the latest version of the HED.
%
% Usage:
%
%   >>  [okay, success] = availablehed_input(version)
%
% Input:
%
%   Required:
%
%   version
%                    The latest the version of the HED that is available.
%
% Output:
%
%   okay
%                    True if the user decided to download the latest HED. 
%                    False if otherwise.
%
%   success
%                    True if the user decided to download the latest HED
%                    and it was successfully downloaded. False if
%                    otherwise.  
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

function [okay, success] = availablehed_input(version)
title = 'Update Available';
okay = false;
success = false;
fig = createFigure(title);
createTopPanel();
createBottomPanel();
movegui(fig);
uiwait(fig);

    function createBottomPanelButtons(panel)
        % Creates the bottom panel buttons
        uicontrol('Parent', panel, ...
            'String', 'OK', ...
            'Style', 'pushbutton', ...
            'TooltipString', ...
            'Press to proceed with update', ...
            'Units','normalized',...
            'Callback', {@okCallback}, ...
            'Position', [0.575 0.1 0.2 0.35]);
        uicontrol('Parent', panel, ...
            'String', 'Skip', ...
            'Style', 'pushbutton', ...
            'TooltipString', ...
            'Press to skip update', ...
            'Units','normalized',...
            'Callback', {@skipCallback}, ...
            'Position', [0.79 0.1 0.2 0.35]);
    end % createBottomPanelButtons

    function fig = createFigure(title)
        % Creates a figure and sets the properties
        fig = figure( ...
            'Color', [.94 .94 .94], ...
            'MenuBar', 'none', ...
            'Name', title, ...
            'NextPlot', 'add', ...
            'NumberTitle','off', ...
            'Position', [750, 750, 500, 200], ...
            'Resize', 'on', ...
            'Tag', title, ...
            'Toolbar', 'none', ...
            'Visible', 'on');
    end % createFigure

    function createTopPanel()
        % Creates the top panel
        panel = uipanel('Parent', fig, ...
            'BackgroundColor', [.94 .94 .94], ...
            'FontSize', 12, ...
            'Position', [0 .5 1 .5]);
        createTopPanelLabels(panel);
    end % createTopPanel

    function createBottomPanel()
        % Creates the bottom panel
        panel = uipanel('Parent', fig, ...
            'BackgroundColor', [.94 .94 .94], ...
            'FontSize', 12, ...
            'Position', [0 0 1 .5]);
        createBottomPanelLabels(panel);
        createBottomPanelButtons(panel);
    end % createBottomPanel

    function createTopPanelLabels(panel)
        % Creates the labels in the top panel
        uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', ['A new version of the HED XML schema is' ...
            ' available. Do you want to download it now?'], ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.1 0.55 0.8 0.4]);
    end % createTopPanelLabels

    function createBottomPanelLabels(panel)
        % Creates the labels in the bottom panel
        uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', ['Version: ' version], ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.1 0.75 0.8 0.2]);
        url = 'https://github.com/BigEEGConsortium/HED/wiki/HED-Schema';
        labelStr = ['<html>From: <a href="">' url ...
            '</a></html>'];
        jLabel = javaObjectEDT('javax.swing.JLabel', labelStr);
        [hjLabel,hContainer] = javacomponent(jLabel, [10,10,250,20], ...
            panel);
        set(hContainer, 'Units','norm');
        set(hContainer, 'Position', [0.1 .45 1 0.35]);
        % Modify the mouse cursor when hovering on the label
        hjLabel.setCursor(java.awt.Cursor.getPredefinedCursor(...
            java.awt.Cursor.HAND_CURSOR));
        % Set the label's tooltip
        hjLabel.setToolTipText(['Visit the ' url ' website']);
        % Set the mouse-click callback
        set(hjLabel, 'MouseClickedCallback', @(h,e)web(url, '-browser'));
    end % createBottomPanelLabels

    function okCallback(src, evnt) %#ok<INUSD>
        % Callback for the okay button
        wb = waitbar(.5,'Updating...');
        try         
            replacehed();
            close(wb);
            success = true;
            msgbox('Update complete', 'Success','modal');
        catch
            close(wb);
            success = false;
            msgbox('Update failed', 'Failure','modal');
        end
        okay = true;
        close(fig);
    end % okCallback

    function skipCallback(src, evnt) %#ok<INUSD>
        % Callback for the skip button
        close(fig);
    end % skipCallback

end % availablehed_input