% pop_tageeg
% Allows a user to tag a EEG structure using a GUI
%
% Usage:
%   >>  [EEG, com] = pop_tageeg(EEG)
%
% [EEG, com] = pop_tageeg(EEG) takes an input EEGLAB EEG structure,
% brings up a GUI to enter parameters for tageeg, and calls
% tageeg to extracts the EEG structure's tags, if any.
%
% The tageeg function may optionally connect to a community tag database.
%
% Note: The primary purpose of pop_tageeg is to package up parameter input
% and calling of tageeg for use as a plugin for EEGLAB (Edit menu).
%
%
% See also:
%   eeglab, tageeg, tagdir, tagstudy, and eegplugin_ctagger
%

%
% Copyright (C) 2012-2013 Thomas Rognon tcrognon@gmail.com and
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: pop_tageeg.m,v $
% Revision 1.0 21-Apr-2013 09:25:25  kay
% Initial version
%


function [EEG, com] = pop_tageeg(EEG)
% Create the tagger for a single EEG file
com = '';

% Display help if inappropriate number of arguments
if nargin < 1
    help pop_tageeg;
    return;
end;

% Get the tagger input parameters
[baseMap, cancelled, editXml, preservePrefix, saveMapFile, ...
    selectFields, useGUI] = tageeg_input();
if cancelled
    return;
end

% Tag the EEG structure and return the command string
EEG = tageeg(EEG, 'BaseMap', baseMap, ...
    'EditXml', editXml, ...
    'PreservePrefix', preservePrefix, ...
    'SaveMapFile', saveMapFile, ...
    'SelectFields', selectFields, ...
    'UseGUI', useGUI);
com = char(['tageeg(''BaseMap'', ''' baseMap ''', ' ...
    '''EditXml'', ' logical2str(editXml) ', ' ...
    '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
    '''SaveMapFile'', ''' saveMapFile ''', ' ...
    '''SelectFields'', ' logical2str(selectFields) ', ' ...
    '''UseGui'', ' logical2str(useGUI) ')']);
end % pop_tageeg

function s = logical2str(b)
if b
    s = 'true';
else
    s = 'false';
end
end % logical2str

