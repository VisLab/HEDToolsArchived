% tagstudy_input
% GUI for input needed to create inputs for validatestudy
%
% Usage:
%   >>  validatestudy_input()
%
% Description:
% validatestudy_input() brings up a GUI for input needed to create inputs
% for validatestudy
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for tagstudy_input:
%
%    doc tagstudy_input
% See also: valideatestudy, pop_validatestudy
%
% Copyright (C) Kay Robbins and Jeremy Cockfield, UTSA, 2011-2013,
% krobbins@cs.utsa.edu
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

function [cancelled, errorLogOnly, extensionsAllowed, hedXML, ...
    outputDir] = validateeeg_input()
% Setup the variables used by the GUI
cancelled = true;
errorLogOnly = true;
extensionsAllowed = true;
hedXML = which('HED.xml');
outputDir = pwd;
title = 'Inputs for validating EEG dataset HED tags';
fig = createFigure(title);
addFigureComponents(fig);
movegui(fig);
uiwait(fig);

    function addBrowserComponents(browserPanel)
        % Adds components to the browser panel
        addBrowserLabels(browserPanel);
        addBrowserEditBoxes(browserPanel);
        addBrowserButtons(browserPanel);
    end % addBrowserComponents

    function addBrowserButtons(browserPanel)
        % Adds button components to the browser panel
        uicontrol('Parent', browserPanel, ...
            'string', 'Browse', ...
            'style', 'pushbutton', ...
            'TooltipString', 'Press to bring up file chooser', ...
            'Units', 'normalized',...
            'Callback', {@browseHedXMLCallback, ...
            'Browse for HED XML file'}, ...
            'Position', [0.775 .8 0.21 0.2]);
        uicontrol('Parent', browserPanel, ...
            'string', 'Browse', ...
            'style', 'pushbutton', ...
            'TooltipString', 'Press to bring up file chooser', ...
            'Units', 'normalized',...
            'Callback', {@browseOutputDirectoryCallback, ...
            'Browse for ouput directory'}, ...
            'Position', [0.775 .5 0.21 0.2]);
    end % addBrowserButtons

    function addBrowserEditBoxes(browserPanel)
        % Adds edit box components to the browser panel
        uicontrol('Parent', browserPanel, ...
            'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'Left', ...
            'Tag', 'HEDXMLEB', ...
            'String', hedXML, ...
            'TooltipString', 'The HED XML file.', ...
            'Units','normalized',...
            'Callback', {@hedEditBoxCallback}, ...
            'Position', [0.15 0.8 0.6 0.2]);
        uicontrol('Parent', browserPanel, ...
            'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'Left', ...
            'Tag', 'OutputDirEB', ...
            'String', outputDir, ...
            'TooltipString', ['A directory where the validation output' ...
            ' is written to.'], ...
            'Units','normalized',...
            'Callback', {@outputDirEditBoxCallback}, ...
            'Position', [0.15 0.5 0.6 0.2]);
    end % addBrowserEditBoxes

    function addBrowserLabels(browserPanel)
        % Adds label components to the browser panel
        uicontrol('Parent', browserPanel, ...
            'Style','text', ...
            'String', 'HED file', ...
            'Units','normalized',...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.015 0.75 0.1 0.2]);
        uicontrol('parent', browserPanel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', 'Output directory', ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.015 0.4 0.12 0.3]);
    end % addBrowserLabels

    function addFigureComponents(fig)
        % Adds components to the figure
        [browserPanel, optionPanel, sumissionPanel] = ...
            createPanels(fig);
        addBrowserComponents(browserPanel);
        addOptionComponents(optionPanel);
        addSubmissionComponents(fig, sumissionPanel);
    end % addFigureComponents

    function addOptionComponents(optionPanel)
        % Adds components to the option panel
        uicontrol('Parent', optionPanel, ...
            'Style', 'CheckBox', ...
            'String', 'Extensions allowed', ...
            'Enable', 'on', ...
            'Tooltip', ['If checked, tags not in the HED are accepted' ...
            ' that start with the prefix of a tag that has the' ...
            ' extension allowed attribute or is a leaf tag.'], ...
            'Value', extensionsAllowed, ...
            'Units','normalized', ...
            'Callback', @extensionsAllowedCallback, ...
            'Position', [0.1 0.6 0.8 0.3]);
        uicontrol('Parent', optionPanel, ...
            'Style', 'CheckBox', ...
            'String', 'Generate additional log files', ...
            'Enable', 'on', ...
            'Tooltip', ['If checked, warning and extension log files' ...
            ' will be generated in addition to a error log file.'], ...
            'Value', ~errorLogOnly, ...
            'Units','normalized', ...
            'Callback', @errorLogCallback, ...
            'Position', [0.1 0.2 0.8 0.3]);
    end % addOptionComponents

    function addSubmissionComponents(fig, submissionPanel)
        % Adds components to the submission panel
        uicontrol('Parent', submissionPanel, ...
            'Style', 'pushbutton', ...
            'String', 'Okay', ...
            'Enable', 'on', ...
            'Tooltip', 'Save the current configuration in a file', ...
            'Units','normalized', ...
            'Callback', {@okayButtonCallback, fig}, ...
            'Position',[0.16 0.1 0.3 .5]);
        uicontrol('Parent', submissionPanel, ...
            'Style', 'pushbutton', ...
            'Tag', 'CancelButton', ...
            'String', 'Cancel', ...
            'Enable', 'on', ...
            'Tooltip', 'Cancel the directory tagging', ...
            'Units','normalized', ...
            'Callback', {@cancelButtonCallback, fig}, ...
            'Position',[0.48 0.1 0.3 .5]);
        uicontrol('Parent', submissionPanel, ...
            'Style', 'pushbutton', ...
            'Tag', 'CancelButton', ...
            'String', 'Help', ...
            'Enable', 'on', ...
            'Tooltip', 'Cancel the directory tagging', ...
            'Units', 'normalized', ...
            'Callback', @helpButtonCallback, ...
            'Position',[0.8 0.1 0.3 .5]);
    end % addSubmissionComponents

    function [browserPanel, optionPanel, ...
            sumissionPanel] = createPanels(fig)
        % Creates the panels in the figure
        browserPanel = uipanel(fig, ...
            'BorderType','none', ...
            'BackgroundColor',[.94 .94 .94],...
            'FontSize', 12,...
            'Position',[0 .5 1 .4]);
        optionPanel = uipanel(fig, ...
            'BackgroundColor',[.94,.94,.94],...
            'FontSize', 12,...
            'Title','Additional options', ...
            'Position',[0.15 0.2 0.6 0.3]);
        sumissionPanel = uipanel(fig, ...
            'BorderType','none', ...
            'BackgroundColor',[.94 .94 .94],...
            'FontSize', 12,...
            'Position', [0.21 .025 .7 .15]);
    end % createPanels

    function browseHedXMLCallback(src, eventdata, myTitle) %#ok<INUSL>
        % Callback for 'Browse' button that sets the 'HED' editbox
        [tFile, tPath] = uigetfile({'*.xml', 'XML files (*.xml)'}, ...
            myTitle);
        if tFile ~= 0
            hedXML = fullfile(tPath, tFile);
            set(findobj('Tag', 'HEDXMLEB'), 'String', hedXML);
        end
    end % browseHedXMLCallback

    function browseOutputDirectoryCallback(~, ~, myTitle) 
        % Callback for browse button to set the output directory editbox
        startPath = get(findobj('Tag', 'OutputDirEB'), 'String');
        if isempty(startPath) || ~ischar(startPath) || ~isdir(startPath)
            startPath = pwd;
        end
        dName = uigetdir(startPath, myTitle);
        if dName ~=0
            set(findobj('Tag', 'OutputDirEB'), 'String', dName);
            outputDir = dName;
        end
    end % browseOutputDirectoryCallback

    function cancelButtonCallback(~, ~, fig)  
        % Callback for the cancel button
        cancelled = true;
        close(fig);
    end % cancelButtonCallback

    function fig = createFigure(title)
        % Creates the figure with the given title
        fig = figure( ...
            'Color', [.94 .94 .94], ...
            'MenuBar', 'none', ...
            'Name', title, ...
            'NextPlot', 'add', ...
            'NumberTitle','off', ...
            'Resize', 'on', ...
            'Tag', title, ...
            'Toolbar', 'none', ...
            'Visible', 'off', ...
            'WindowStyle', 'modal');
    end % createFigure

    function errorLogCallback(src, ~) 
        % Callback for only generate error log checkbox
        errorLogOnly = ~get(src, 'Max') == get(src, 'Value');
    end % errorLogCallback

    function extensionsAllowedCallback(src, ~) 
        % Callback for extensions allowed checkbox
        extensionsAllowed = get(src, 'Max') == get(src, 'Value');
    end % extensionAllowedCallback

    function hedEditBoxCallback(src, ~) 
        % Callback for user directly editing the HED XML editbox
        xml = get(src, 'String');
        if exist(xml, 'file')
            hedXML = xml;
        else 
            errordlg(['XML file is invalid. Setting the XML' ...
                ' file back to the previous file.'], ...
                'Invalid XML file');
            set(src, 'String', hedXML);
        end
    end % hedEditBoxCallback

    function helpButtonCallback(~, ~)
        % Callback for the okay button
        helpdlg(sprintf(['HED file - The latest HED' ...
            ' schema. This will be the HED.xml file found in the hed' ...
            ' directory by default.\n\nOutput directory - The output' ...
            ' directory will mirror the directory structure containing' ...
            ' the study data files with the log files in place of the' ...
            ' data files. The default output directory will be the' ...
            ' current directory.\n\n ***Additional Options***\n\n' ...
            ' Extensions allowed - By default tags not in the HED are' ...
            ' accepted that start with the prefix of a tag that has' ...
            ' the extension allowed attribute or is a leaf tag. If you' ...
            ' don''t want this behavior uncheck ''Extensions' ...
            ' allowed.''\n\nGenerate additional log files - ' ...
            ' There will be a error log file generated for each study' ...
            ' dataset that is validated. To generate warning and' ...
            ' extension log files in addition check ''Generate additional' ...
            ' log files''.']),'Input Description')
    end % okayButtonCallback

    function okayButtonCallback(~, ~, fig)
        % Callback for the okay button
        cancelled = false;
        close(fig);
    end % okayButtonCallback

    function outputDirEditBoxCallback(src, ~)
        % Callback for user directly editing the output directory edit box
        directory = get(src, 'String');
        if exist(directory, 'dir')
            outputDir = directory;
        else 
            errordlg(['Output directory is invalid. Setting the output' ...
                ' directory back to the previous directory.'], ...
                'Invalid output directory');
            set(src, 'String', outputDir);
        end
    end % outputDirEditBoxCallback

end % tagstudy_input