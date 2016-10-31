% Allows a user to tag a EEGLAB study using a GUI.
%
% Usage:
%
%   >>  [fMap, com] = pop_tagstudy()
%
%   >>  [fMap, fPaths, com] = pop_tagstudy(studyFile)
% 
%   >>  [fMap, fPaths, com] = pop_tagstudy(studyFile, 'key1', value1 ...)
%
% Input:
%
%   Required:
%
%   studyFile
%                    The path to an EEG study.
%
%   Optional (key/value):
%
%   'BaseMap'
%                    A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used for initial tag
%                    information.
%
%   'ExcludeFields'
%                    A one-dimensional cell array of field names in the
%                    .event substructure to ignore during the tagging
%                    process. By default the following subfields of the
%                    .event structure are ignored: .latency, .epoch,
%                    .urevent, .hedtags, and .usertags. The user can
%                    over-ride these tags using this name-value parameter.
%
%   'Fields'
%                    A one-dimensional cell array of fields to tag. If this
%                    parameter is non-empty, only these fields are tagged.
%
%   'HedXML'         
%                    Full path to a HED XML file. The default is the 
%                    HED.xml file in the hed directory. 
%
%   'PreservePrefix'
%                    If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
%   'PrimaryField'
%                    The name of the primary field. Only one field can be
%                    the primary field. A primary field requires a label,
%                    category, and a description. The default is the type
%                    field.
%
%   'SaveDatasets'
%                    If true, save the tags to the underlying study and
%                    dataset files in the study. If false (default), do not
%                    save the tags to the underlying study and dataset
%                    files in the study.
%
%   'SaveMapFile'
%                    The full path name of the file for saving the final,
%                    consolidated fieldMap object that results from the
%                    tagging process.
%
%   'SelectFields'
%                    If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%
%   'UseGui'
%                    If true (default), the CTAGGER GUI is displayed after
%                    initialization.
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

function [fMap, fPaths, com] = pop_tagstudy(studyFile, varargin)
fMap = '';
fPaths = '';
com = '';

% Get the input parameters
[canceled, baseMap, extensionsAllowed, extensionsAnywhere, hedXML, ...
    preservePrefix, selectFields, studyFile, useGUI] = tagstudy_input();
if canceled
    return;
end

% Tag the EEG study and return the command string
[fMap, fPaths, canceled] = tagstudy(studyFile,'BaseMap', baseMap, ...
    'ExtensionsAllowed', extensionsAllowed, 'ExtensionsAnywhere', ...
    extensionsAnywhere, 'HedXML', hedXML,'PreservePrefix', ...
    preservePrefix, 'SelectFields', selectFields, 'UseGUI', useGUI);
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