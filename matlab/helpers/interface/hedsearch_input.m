% GUI input for specifying the "Time-locking HED tag(s) in the pop_epochhed
% function.
%
% Usage:
%
%   >>  [canceled, tags] = hedsearch_input(uniquetags, searchtags)
%
% Graphic interface:
%
%    "Search for"
%
%                A search string consisting of tags to use for extracting
%                data epochs. The string uses commas to narrow the search.
%                Two tags separated by a comma is equivalent to the AND
%                operator in general searches and the search only returns
%                events that contain both of the tags. For example,
%                “/Attribute/Visual/Color/Green,
%                /Item/2d shape/Rectangle/Square” find epochs with green
%                squares. When using the search bar and typing in something
%                there will be a listbox below the search bar containing
%                possible matches. Pressing the "up" and "down" arrows on
%                the keyboard while the cursor is in the search bar will
%                move to the next or previous tag in the listbox. Pressing
%                "Enter" will select the current tag in the listbox and it
%                will be added to the search bar. When done click the "Ok"
%                button and it will take you back to the main epoching
%                menu.
%
% Input:
%
%   Required:
%
%   uniquetags
%                The unique HED tags in the EEG dataset loaded.
%
%   tags         
%                A search string consisting of tags to extract data epochs.
%
% Output:
%
%   canceled
%                True if the cancel button is pressed. False if otherwise.
%
%   tags
%                A search string consisting of tags to extract data epochs.
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

function [canceled, tags] = hedsearch_input(uniquetags, tags)
canceled = true;
matches = '';
title = 'Set time-locking HED tag(s)';
criteriaTitle = 'Current time-lock tag string';
listbox = [];
editbox = [];
criteriaLabel = [];
label = [];
fig = createFigure(title);
createPanel(fig);
movegui(fig);
drawnow;
uiwait(fig);
if ishandle(fig)
    close(fig);
end

    function [matches, sequence] = findMatchingTags(src)
        % Looks for matching tags 
        sequence = findhedsequence(char(src.getText()), ...
            src.getCaretPosition());
        indexes = ~cellfun(@isempty, regexpi(uniquetags, sequence));
        matches = uniquetags(indexes);
    end % findMatchingTags

    function searchClbk(src, evnt)
        % The search bar callback 
        if ~isempty(char(src.getText())) && src.getCaretPosition() > 0
            [matches, sequence] = findMatchingTags(src);
            matches = vertcat({sequence}, matches);
            isListboxKey = checkForSpecialKeys(evnt, matches);
            if ~isListboxKey
                if isempty(sequence)
                    set(listbox, 'Visible', 'off');
                else
                    set(listbox, 'Visible', 'on');
                    set(listbox, 'Value', 1);
                    set(listbox, 'String', matches);
                end
                tags = editbox.getText();
                set(label, 'String', char(editbox.getText()));
            end
        else
            set(label, 'String', '');
            set(listbox, 'Visible', 'off');
        end
    end % searchClbk

    function isListboxKey = checkForSpecialKeys(evnt, matches)
        % Checks for special keys associated with the listbox 
        isListboxKey = false;
        if isequal(get(listbox, 'Visible'), 'on') && ...
                (evnt.getKeyCode() == 10 || evnt.getKeyCode() == 13)
            MatchClbk(listbox, []);
            isListboxKey = true;
        end
        if isequal(get(listbox, 'Visible'), 'on') && ...
                evnt.getKeyCode() == 40
            value = get(listbox, 'Value');
            if (value ~= length(matches))
                set(listbox, 'Value', value+1);
            end
            isListboxKey = true;
        end
        if isequal(get(listbox, 'Visible'), 'on') && ...
                evnt.getKeyCode() == 38
            value = get(listbox, 'Value');
            if (value ~= 1)
                set(listbox, 'Value', value-1);
            end
            isListboxKey = true;
        end
    end % checkForSpecialKeys

    function okayCallback(src, eventdata) %#ok<INUSD>
        % The okay button callback
        canceled = false;
        tags = char(editbox.getText());
        close(fig);
    end % okayCallback

    function cancelCallback(src, eventdata) %#ok<INUSD>
        % The cancel button callback 
        canceled = true;
        tags = char(editbox.getText());
        close(fig);
    end % cancelCallback

    function helpCallback(src, eventdata) %#ok<INUSD>
        % The help button callback 
        doc hedsearch_input
    end % helpCallback

    function MatchClbk(src, evnt) %#ok<INUSD>
        items = get(src, 'String');
        text = char(editbox.getText());
        item = items{get(src, 'Value')};
        [~, start, finish] = findhedsequence(char(editbox.getText()), ...
            editbox.getCaretPosition());
        text = [text(1:start-1) item text(finish+1:end)];
        editbox.setText(text);
        editbox.setCaretPosition(length([text(1:start-1) item]));
        set(label, 'String', char(editbox.getText()));
        editbox.requestFocusInWindow();
        set(listbox, 'visible', 'off');
    end

    function createEditBoxes()
        % Creates the edit boxes in the panel
        editbox = javax.swing.JTextField();
        editbox.setHorizontalAlignment(javax.swing.JTextField.CENTER);
        editbox.setText(tags);
        [hcomponent, hContainer] = javacomponent(editbox, [85 360 340 35]);
        set(hContainer, 'Units','norm');
        set(hContainer, 'Position', [0.12 0.85 0.85 0.1]);
        set(editbox, 'KeyReleasedCallback', @searchClbk);
        hcomponent.setFocusable(true);
        hcomponent.putClientProperty('TabCycleParticipant', true);
    end % createEditBoxes

    function fig = createFigure(title)
        % Creates a figure and sets the properties
        fig = figure( ...
            'Color', [.94 .94 .94], ...
            'MenuBar', 'none', ...
            'Name', title, ...
            'NextPlot', 'add', ...
            'NumberTitle','off', ...
            'WindowScrollWheel', @scroll, ...
            'KeyPressFcn', @downCall, ...
            'Resize', 'on', ...
            'Tag', title, ...
            'Toolbar', 'none', ...
            'Visible', 'off');
    end % createFigure

    function scroll(src, evnt) %#ok<INUSL>
        % Scroll action handler for listbox 
        numTags = length(matches);
        position = get(listbox,'Value');   
        if evnt.VerticalScrollCount == 1 && (position + 1 <= numTags)
            set(listbox,'Value', position + 1)
        elseif evnt.VerticalScrollCount == -1 && (position - 1 >= 1)
            set(listbox,'Value', position - 1)
        end
    end % scroll

    function createLabels(panel)
        % Creates the labels in the panel
        uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', 'Search for', ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.01 0.8 0.12 0.12]);
        uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'FontWeight', 'bold', ...
            'String', criteriaTitle, ...
            'HorizontalAlignment', 'Center', ...
            'Position', [0.01 0.22 0.95 0.22]);
        label = uicontrol('parent', panel, ...
            'Style', 'Text', ...
            'Units', 'normalized', ...
            'String', tags, ...
            'HorizontalAlignment', 'Center', ...
            'Position', [0.01 0.18 0.95 0.22]);
    end % createLabels

    function downCall(src, evnt) %#ok<INUSD>
    end % downCall

    function createButtons(panel)
        % Creates the buttons in the panel
        uicontrol('parent', panel, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'String', 'Help', ...
            'HorizontalAlignment', 'Left', ...
            'Callback', @helpCallback, ...
            'Position', [0.01 0.05 0.2 0.1]);
        uicontrol('parent', panel, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'String', 'Cancel', ...
            'HorizontalAlignment', 'Left', ...
            'Callback', @cancelCallback, ...
            'Position', [0.525 0.05 0.2 0.1]);
        uicontrol('parent', panel, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'String', 'Ok', ...
            'Callback', @okayCallback, ...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.75 0.05 0.2 0.1]);
    end % createButtons

    function createListBoxes(panel)
        % Creates the edit boxes in the panel
        listbox = uicontrol('Parent', panel, ...
            'Style', 'listbox', ...
            'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'Left', ...
            'String', '', ...
            'TooltipString', 'Possible matches', ...
            'Visible', 'off', ...
            'Units','normalized',...
            'Callback',@MatchClbk, ...
            'Position', [0.12 0.45 0.85 0.4]);
    end % createListBoxes

    function createPanel(fig)
        % Creates HED mapping layout
        panel = uipanel('Parent', fig, ...
            'BorderType', 'none', ...
            'BackgroundColor', [.94 .94 .94], ...
            'FontSize', 12, ...
            'Position', [0 0 1 1]);
        createLabels(panel);
        createEditBoxes();
        createListBoxes(panel);
        createButtons(panel);
    end % createPanel

end % searchmenu