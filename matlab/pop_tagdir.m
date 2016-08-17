% Allows a user to tag a directory of datasets using a GUI. pop_tagdir
% first brings up a GUI to allow the user to set parameters for the tagdir
% function, and then calls tagdir to consolidate the tags from all of the
% data files in the specified directories. Depending on the arguments,
% tagdir may bring up a menu to allow the user to choose which fields
% should be tagged. The tagdir function may also bring up the CTAGGER GUI
% to allow users to edit the tags.
%
% Usage:
%   >>  [fMap, fPaths, com] = pop_tagdir()
%
% Output:
%    fMap   - a fieldMap object that contains the tag map information
%    fPaths - a list of full file names of the datasets to be tagged
%    com    - string containing call to tagstudy with all parameters
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function [fMap, fPaths, com] = pop_tagdir()
% Create the tagger for this EEG set
fMap = '';
fPaths = '';
com = '';
[cancelled, inDir, baseMap, doSubDirs, editXml, preservePrefix, ...
    saveDatasets, saveMapFile, selectFields, useGUI] = tagdir_input();
if cancelled
    return;
end
[fMap, fPaths] = tagdir(inDir, 'BaseMap', baseMap, ...
    'DoSubDirs', doSubDirs,  ...
    'EditXml', editXml, ...
    'PreservePrefix', preservePrefix, ...
    'SaveDatasets', saveDatasets, ...
    'SaveMapFile', saveMapFile, ...
    'SelectFields', selectFields, ...
    'UseGUI', useGUI);

com = char(['tagdir(''' inDir ''', ' ...
    '''BaseMap'', ''' baseMap ''', ' ...
    '''DoSubDirs'', ' logical2str(doSubDirs) ', ' ...
    '''EditXml'', ' logical2str(editXml) ', ' ...
    '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
    '''SaveDatasets'', ' logical2str(saveDatasets) ', ' ...
    '''SaveMapFile'', ''' saveMapFile ''', ' ...
    '''SelectFields'', ' logical2str(selectFields) ', ' ...
    '''UseGui'', ' logical2str(useGUI) ')']);

    function s = logical2str(b)
        if b
            s = 'true';
        else
            s = 'false';
        end
    end

end % pop_tagdir