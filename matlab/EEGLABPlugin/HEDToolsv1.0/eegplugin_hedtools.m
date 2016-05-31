% eegplugin_hedtools makes a HEDTools plugin for EEGLAB 
%     
% Usage:
%   >> eegplugin_hedtools(fig, trystrs, catchstrs)
%
%% Description
% eegplugin_hedtools(fig, trystrs, catchstrs) makes a HEDTools 
%    plugin for EEGLAB. The plugin automatically
%    extracts the items and the current tagging structure from the
%    current EEG structure in EEGLAB.
% 
%    The fig, trystrs, and catchstrs arguments follow the
%    convention for plugins to EEGLAB. The fig argument holds the figure
%    number of the main EEGLAB GUI. The trystrs and catchstrs arguments
%    hold the try and catch strings for EEGLAB menu callbacks.
%
% Place the ctagger folder in the |plugins| subdirectory of EEGLAB.
% EEGLAB should detect the plugin on start up.  
%
% Notes:
%   See Contents.m for the contents of this plugin.
%
% See also: eeglab and pop_ctagger
%

%
% Copyright (C) 2012-2013 Thomas Rognon tcrognon@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1.07  USA

% $Log: eegplugin_ctagger.m,v $
% Revision 1.0 21-Apr-2013 09:25:25 10:22:05  kay
% Initial revision
%

function vers = eegplugin_hedtools(fig, trystrs, catchstrs)
% 
    vers = 'hedtools1.0';
    if nargin < 3
        error('eegplugin_hedtools requires 3 arguments');
    end;

    % Find the path of the current directory
    tPath = which('eegplugin_hedtools.m');
    tPath = strrep(tPath, [filesep 'eegplugin_hedtools.m'], '');

    % Add hedtools folders to path if they aren't already there
    if ~exist('eegplugin_hedtools-subfoldertest.m', 'file')  % Dummy file to make sure not added
        addpath(genpath(tPath));  % Add all subfolders to path too
    end;

    % Add the jar files needed to run this
    jarPath = [tPath filesep 'jars' filesep];  % With jar
    warning off all;
    try
        javaaddpath([jarPath 'ctagger.jar']);
        javaaddpath([jarPath 'jackson.jar']);
        javaaddpath([jarPath 'hedconversion.jar']);
    catch mex  %#ok<NASGU>
    end
    warning on all;

    % Add to EEGLAB edit menu for current EEG dataset
    parentMenu = findobj(fig, 'Label', 'Edit');
    finalcmd = '[EEG LASTCOM] = pop_tageeg(EEG);';
    ifeegcmd = 'if ~isempty(LASTCOM) && ~isempty(EEG)';
    savecmd = '[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);';
    redrawcmd = 'eeglab redraw;';
    finalcmd =  [trystrs.no_check finalcmd ifeegcmd savecmd ...
                 redrawcmd 'end;' catchstrs.add_to_hist];
    uimenu(parentMenu, 'Label', 'Tag current EEG', 'Callback', finalcmd, ...
        'Separator', 'on');
    
    % Add tagging of directory of EEG
    finalcmd = '[~, ~, LASTCOM] = pop_tagdir();';
    finalcmd =  [trystrs.no_check finalcmd catchstrs.add_to_hist];
    parentMenu = findobj(fig, 'Label', 'File', 'Type', 'uimenu');
    positionMenu = findobj(fig, 'Label', 'Memory and other options', ...
        'Type', 'uimenu');
    position = get(positionMenu, 'Position');
    dirMenu = uimenu(parentMenu, 'Label', 'Tag data', ...
        'Separator', 'on', 'Position', position, 'userdata', 'startup:on;study:on');
    uimenu(dirMenu, 'Label', 'Tag directory', 'Callback', finalcmd, ...
           'Separator', 'on', 'userdata', 'startup:on;study:on');
    
    % Add tagging of current study 
    finalcmd = '[~, LASTCOM] = pop_tagstudy();';
    finalcmd =  [trystrs.no_check finalcmd catchstrs.add_to_hist];
    uimenu(dirMenu, 'Label', 'Tag EEG study', 'Callback', finalcmd, ...
        'Separator', 'on', 'userdata', 'startup:on;study:on');
    
    % Add to EEGLAB edit menu for current EEG dataset
    parentMenu = findobj(fig, 'Label', 'Tools');
    finalcmd = '[EEG LASTCOM] = pop_hedepoch(EEG);';
    positionMenu = findobj(fig, 'Label', 'Remove baseline', ...
        'Type', 'uimenu');
    position = get(positionMenu, 'Position');
    ifeegcmd = 'if ~isempty(LASTCOM) && ~isempty(EEG)';
    savecmd = '[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);';
    redrawcmd = 'eeglab redraw;';
    rmbasecmd = '[EEG, LASTCOM] = pop_rmbase(EEG);';
    finalcmd =  [trystrs.no_check finalcmd ifeegcmd savecmd ...
                 redrawcmd 'end;' rmbasecmd ifeegcmd savecmd redrawcmd ...
                 'end;' catchstrs.add_to_hist];
    uimenu(parentMenu, 'Label', 'Extract epochs by tags', ...
        'Position', position, 'Callback', finalcmd);
end