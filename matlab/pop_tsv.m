% This function calls the HED validation utilities pop-up gui menu. The
% pop-up gui menu contains three tools separated through tabs. The three
% tabs are 'Validate Tab-Delimited HED Tags' which calls the
% 'validateTSVTags' function, 'Remap Tab-Delimited HED Tags' which calls
% the 'remapTSVTags' function, and 'Check for Updates' which calls the
% 'updateHED' function.
%
% Usage:
%   >>  pop_tsv();
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function pop_tsv()
% Prevent an annoying warning msg
addJars();
title = 'HEDTools Validation';
fig = createFigure(title);
tabGroup = uitabgroup('Parent', fig);
tabs = createTabs(tabGroup);
createTabLayouts(tabs);

    function fig = createFigure(title)
        % Creates a figure and sets the properties
        fig = figure( ...
            'Color', [.94 .94 .94], ...
            'MenuBar', 'none', ...
            'Name', title, ...
            'NextPlot', 'add', ...
            'NumberTitle','off', ...
            'Resize', 'on', ...
            'Tag', title, ...
            'Toolbar', 'none', ...
            'Visible', 'on');
    end % createFigure

    function createTabLayouts(tabs)
        % Creates the layouts for the figure
        createTagValidationLayout(tabs.tab1);
        createRemapTagsLayout(tabs.tab2);
        checkForUpdatesLayout(tabs.tab3);
    end % createTabLayouts

    function tabs = createTabs(tabGroup)
        % Creates the tab panels in the figure
        warning off all;
        tabs.tab1 = uitab('Parent', tabGroup, 'title', ...
            'Validate Tab-Delimited File Tags');
        tabs.tab2 = uitab('Parent', tabGroup, 'title', ...
            'Update Tab-Delimited File Tags');
        tabs.tab3 = uitab('Parent', tabGroup, 'title', ...
            'Check for Latest HED');
        warning on all;
    end % createTabs

end % pop_hedtagvalidate