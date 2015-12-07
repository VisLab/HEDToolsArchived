% This function calls the HED conversion utilities pop-up gui menu. The 
% pop-up gui menu contains five tools separated through tabs. The five
% tabs are 'Wiki to HED' which calls the 'wiki2hed' function, 
% 'Validate HED' which calls the 'validatehed' function, 'Validate Tags'
% which calls the 'validatetags' function, 'HED Mapping' which calls the
% 'createhedmap' function, and 'Replace Tags' which calls the 'replacetags'
% function.
%
% Usage:
%   >>  pop_hedconversion()
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

function pop_hedconversion()
addJars();
title = 'HED Conversion Utilities';
fig = createFigure(title);
tabGroup = uitabgroup(fig);
tabs = createTabs(tabGroup);
createTabLayouts(tabs);
movegui(fig);
drawnow;
uiwait(fig);
if ishandle(fig)
    close(fig);
end

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
            'Visible', 'off');
    end % createFigure

    function createTabLayouts(tabs)
        % Creates the layouts for the figure
        createWikiConversionLayout(tabs.tab1);
        createHedValidationLayout(tabs.tab2);
        createTagValidationLayout(tabs.tab3);
        createHedMappingLayout(tabs.tab4);
        createReplaceTagsLayout(tabs.tab5);
    end % createTabLayouts

    function tabs = createTabs(tabGroup)
        % Creates the tab panels in the figure
        tabs.tab1 = uitab(tabGroup, 'title', 'Wiki to HED');
        tabs.tab2 = uitab(tabGroup, 'title', 'Validate HED');
        tabs.tab3 = uitab(tabGroup, 'title', 'Validate Tags');
        tabs.tab4 = uitab(tabGroup, 'title', 'HED Mapping');
        tabs.tab5 = uitab(tabGroup, 'title', 'Replace Tags');
    end % createTabs

end % pop_hedconversion