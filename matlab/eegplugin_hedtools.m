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
% Place the HEDTools folder in the |plugins| subdirectory of EEGLAB.
% EEGLAB should detect the plugin on start up.
%
%
% See also: eeglab
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

function vers = eegplugin_hedtools(fig, trystrs, catchstrs)
vers = 'hedtools1.0.0';
% Check the number of input arguments
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
evalin('base', 'save([tempdir ''tmp.mat''], ''-mat'');');
try
    javaaddpath([jarPath 'ctagger.jar']);
    javaaddpath([jarPath 'jackson.jar']);
    javaaddpath([jarPath 'hedconversion.jar']);
catch mex  %#ok<NASGU>
end
evalin('base', 'load([tempdir ''tmp.mat''], ''-mat'');');
delete([tempdir 'tmp.mat']);
warning on all;

% Find 'Edit' in the figure 
parentMenu = findobj(fig, 'Label', 'Edit');

% Processing for 'Tag current EEG'
finalcmd = '[EEG LASTCOM] = pop_tageeg(EEG);';
ifeegcmd = 'if ~isempty(LASTCOM) && ~isempty(EEG)';
savecmd = '[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);';
redrawcmd = 'eeglab redraw;';
finalcmd =  [trystrs.no_check finalcmd ifeegcmd savecmd ...
    redrawcmd 'end;' catchstrs.add_to_hist];

% Add 'Tag current EEG' to 'Edit'
uimenu(parentMenu, 'Label', 'Tag current dataset', 'Callback', ...
    finalcmd, ...
    'Separator', 'on');

% Processing for 'Validate current EEG'
finalcmd = '[~, LASTCOM] = pop_validateeeg(EEG);';

% Add 'Validate current EEG' to 'Edit'
uimenu(parentMenu, 'Label', 'Validate current dataset', 'Callback', ...
    finalcmd);

% Find 'Memory and other options' in the figure 
parentMenu = findobj(fig, 'Label', 'File', 'Type', 'uimenu');
positionMenu = findobj(fig, 'Label', 'Memory and other options', ...
    'Type', 'uimenu');
position = get(positionMenu, 'Position');

% Add 'Validate files' to 'File'
dirMenu = uimenu(parentMenu, 'Label', 'Validate files', ...
    'Position', position, 'userdata', 'startup:on;study:on');

% Processing for 'Tag directory'
finalcmd = '[~, LASTCOM] = pop_validatedir();';
finalcmd =  [trystrs.no_check finalcmd catchstrs.add_to_hist];

% Add 'Validate directory' to 'Tag files' 
uimenu(dirMenu, 'Label', 'Validate directory', 'Callback', finalcmd, ...
    'Separator', 'on', 'userdata', 'startup:on;study:on');

% Processing for 'Tag EEG study'
finalcmd = 'LASTCOM = pop_validatestudy();';
finalcmd =  [trystrs.no_check finalcmd catchstrs.add_to_hist];

% Add 'Validate EEG study' to 'Tag files'  
uimenu(dirMenu, 'Label', 'Validate study', 'Callback', finalcmd, ...
    'Separator', 'on', 'userdata', 'startup:on;study:on');

% Add 'Tag files' to 'File'
dirMenu = uimenu(parentMenu, 'Label', 'Tag files', ...
    'Separator', 'on', 'Position', position, 'userdata', 'startup:on;study:on');

% Processing for 'Tag directory'
finalcmd = '[~, ~, LASTCOM] = pop_tagdir();';
finalcmd =  [trystrs.no_check finalcmd catchstrs.add_to_hist];

% Add 'Tag directory' to 'Tag files' 
uimenu(dirMenu, 'Label', 'Tag directory', 'Callback', finalcmd, ...
    'Separator', 'on', 'userdata', 'startup:on;study:on');

% Processing for 'Tag EEG study'
finalcmd = '[~, ~, LASTCOM] = pop_tagstudy();';
finalcmd =  [trystrs.no_check finalcmd catchstrs.add_to_hist];

% Add 'Tag EEG study' to 'Tag files'  
uimenu(dirMenu, 'Label', 'Tag study', 'Callback', finalcmd, ...
    'Separator', 'on', 'userdata', 'startup:on;study:on');


% Find 'Remove baseline' in the figure 
parentMenu = findobj(fig, 'Label', 'Tools');
positionMenu = findobj(fig, 'Label', 'Remove baseline', ...
    'Type', 'uimenu');
position = get(positionMenu, 'Position');

% Processing for 'Extract epochs by tags'
finalcmd = '[EEG LASTCOM] = pop_hedepoch(EEG);';
ifeegcmd = 'if ~isempty(LASTCOM) && ~isempty(EEG)';
savecmd = '[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);';
redrawcmd = 'eeglab redraw;';
rmbasecmd = '[EEG, LASTCOM] = pop_rmbase(EEG);';
finalcmd =  [trystrs.no_check finalcmd ifeegcmd savecmd ...
    redrawcmd 'end;' rmbasecmd ifeegcmd savecmd redrawcmd ...
    'end;' catchstrs.add_to_hist];

% Add 'Extract epochs by tags' to 'Tools'
uimenu(parentMenu, 'Label', 'Extract epochs by tags', ...
    'Position', position, 'Callback', finalcmd);
end