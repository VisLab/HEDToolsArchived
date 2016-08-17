% pop_tagstudy
% Allows a user to tag a EEGLAB study using a GUI
%
% Usage:
%   >>  [fMap, com] = pop_tagstudy()
%
% Output:
%    fMap   - a fieldMap object that contains the tag map information
%    com    - string containing call to tagstudy with all parameters
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function [fMap, fPaths, com] = pop_tagstudy()
% Create the tagger for this EEG study
[cancelled, baseMap, editXml, preservePrefix, saveDatasets, ...
    saveMapFile, selectFields, studyFile, useGUI] = tagstudy_input();
if cancelled
    fMap = '';
    com = '';
    return;
end
[fMap, fPaths] = tagstudy(studyFile,'BaseMap', baseMap, ...
    'EditXml', editXml, ...
    'PreservePrefix', preservePrefix, ...
    'SaveDatasets', saveDatasets, ...
    'SaveMapFile', saveMapFile, ...
    'SelectFields', selectFields, ...
    'UseGUI', useGUI);

com = char(['tagstudy(''' studyFile ''', ' ...
    '''BaseMap'', ''' baseMap ''', '...
    '''EditXml'', ' logical2str(editXml) ', ' ...
    '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
    '''SaveDatasets'', ' logical2str(saveDatasets) ', ' ...
    '''SaveMapFile'', ''' saveMapFile ''', ' ...
    '''SelectFields'', ' logical2str(selectFields) ', ' ...
    '''UseGui'', ' logical2str(useGUI) ')']);
end % pop_tagstudy

function s = logical2str(b)
if b
    s = 'true';
else
    s = 'false';
end
end