% Allows a user to tag a EEGLAB study using a GUI.
%
% Usage:
%
%   >>  [fMap, com] = pop_tagstudy()
%
% Output:
%
%   fMap
%                    A fieldMap object that contains the tag map
%                    information
%
%   fPaths
%                    A fieldMap object that contains the tag map
%                    information
%   com
%                    String containing call to tagstudy with all
%                    parameters.
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

function [fMap, fPaths, com] = pop_tagstudy()
fMap = '';
fPaths = '';
com = '';

% Get the input parameters
[canceled, baseMap, extensionsAllowed, extensionsAnywhere, ...
    preservePrefix, selectFields, studyFile, useGUI] = tagstudy_input();
if canceled
    return;
end

% Tag the EEG study and return the command string
[fMap, fPaths, canceled] = tagstudy(studyFile,'BaseMap', baseMap, ...
    'ExtensionsAllowed', extensionsAllowed, 'ExtensionsAnywhere', ...
    extensionsAnywhere, 'PreservePrefix', preservePrefix, ...
    'SelectFields', selectFields, ...
    'UseGUI', useGUI);
if canceled
    return;
end

if fMap.getXmlEdited()
[overwriteHED, saveHED, hedPath] = savehed_input();

if overwriteHED
   str2file(fMap.getXml(), which('HED.xml')); 
end

if saveHED && ~isempty(hedPath)
    str2file(fMap.getXml(), hedPath);
end
end

[overwriteDatasets, savefMap, fMapPath, fMapDescription] = ...
    savetags_input();

if fMapDescription
    fMap.setDescription(fMapDescription);
end

if savefMap && ~isempty(fMapPath)
    savefmap(fMap, fMapPath);
end

if overwriteDatasets
    overwritedataset(fMap, studyFile, 'PreservePrefix', preservePrefix);
end

% Create command string
com = char(['tagstudy(''' studyFile ''', ' ...
    '''BaseMap'', ''' baseMap ''', '...
    '''ExtensionsAllowed'', ' logical2str(extensionsAllowed) ', ' ...
    '''ExtensionsAnywhere'', ' logical2str(extensionsAnywhere) ', ' ...
    '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
    '''SaveDatasets'', ' logical2str(overwriteDatasets) ', ' ...
    '''SaveMapFile'', ''' fMapPath ''', ' ...
    '''SelectFields'', ' logical2str(selectFields) ', ' ...
    '''UseGui'', ' logical2str(useGUI) ')']);

    function s = logical2str(b)
        % Converts a logical to a string
        if b
            s = 'true';
        else
            s = 'false';
        end
    end % logical2str

end % pop_tagstudy