% Allows a user to tag a EEG structure using a GUI.
%
% Usage:
%
%   >>  [EEG, com] = pop_tageeg(EEG)
%
%   >>  [EEG, com] = pop_tageeg(EEG, 'key1', value1 ...)
%
% Input:
%
%   Required:
%
%   EEG
%                    The EEG dataset structure that will be tagged. The
%                    dataset will need to have a .event field.
%
%   Optional (key/value):
%
%   'BaseMap'
%                    A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
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
%   'ExtensionsAllowed'
%                    If true (default), the HED can be extended. If
%                    false, the HED can not be extended. The 
%                    'ExtensionAnywhere argument determines where the HED
%                    can be extended if extension are allowed.
%                  
%   'ExtensionsAnywhere'
%                    If true, the HED can be extended underneath all tags.
%                    If false (default), the HED can only be extended where
%                    allowed. These are tags with the 'extensionAllowed'
%                    attribute or leaf tags (tags that do not have
%                    children).
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
%                    If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
%   'PrimaryField'
%                    The name of the primary field. Only one field can be
%                    the primary field. A primary field requires a label,
%                    category, and a description tag. The default is the
%                    .type field.
%
%   'SaveDataset'
%                    If true, save the tags to the underlying dataset. If
%                    false (default), do not save the tags to the
%                    underlying dataset.
%
%   'SaveMapFile'
%                    A string representing the file name for saving the
%                    final, consolidated fieldMap object that results from
%                    the tagging process.
%
%   'SelectFields'
%                    If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%
%   'UseGui'
%                    If true (default), the CTAGGER GUI is used to edit
%                    field tags.
%
% Output:
%
%   EEG
%                    The EEG dataset structure that has been tagged. The
%                    tags will be written to the .usertags field under
%                    the .event field.
%
%   fMap
%                    A fieldMap object that stores all of the tags.
%
%   com
%                    String containing call to tageeg with all parameters.
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

function [EEG, com] = pop_tageeg(EEG, varargin)
% Create the tagger for a single EEG file
com = '';

% Display help if inappropriate number of arguments
if nargin < 1
    help pop_tageeg;
    return;
end;

% Get the input parameters
[baseMap, canceled, extensionsAllowed, extensionsAnywhere, ...
    hedXML, preservePrefix, selectFields, useGUI] = tageeg_input();
if canceled
    return;
end

% Tag the EEG structure
[EEG, fMap, canceled] = tageeg(EEG, 'BaseMap', baseMap, ...
    'ExtensionsAllowed', extensionsAllowed, 'ExtensionsAnywhere', ...
    extensionsAnywhere, 'HedXML', hedXML, 'PreservePrefix', ...
    preservePrefix, 'SelectFields', selectFields, 'UseGUI', useGUI);
if canceled
    return;
end

if fMap.getXmlEdited()
[overwriteHED, saveHED, hedPath] = savehed_input();

if overwriteHED
   dir = fileparts(which('HED.xml'));
   str2file(fMap.getXml(), fullfile(dir, 'HED_user.xml')); 
end

if saveHED && ~isempty(hedPath)
    str2file(fMap.getXml(), hedPath);
end
end

[overwriteDataset, savefMap, fMapPath, fMapDescription] = savetags_input();

if fMapDescription
    fMap.setDescription(fMapDescription);
    EEG.etc.tags.description = fMapDescription;
end

if savefMap && ~isempty(fMapPath)
    savefmap(fMap, fMapPath);
end

if overwriteDataset
    EEG = overwritedataset(fMap, EEG, 'PreservePrefix', preservePrefix);
end

% Create command string
com = char(['tageeg(''BaseMap'', ''' baseMap ''', ' ...
    '''ExtensionsAllowed'', ' logical2str(extensionsAllowed) ', ' ...
    '''ExtensionsAnywhere'', ' logical2str(extensionsAnywhere) ', ' ...
    '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
    '''SaveDataset'', ''' logical2str(overwriteDataset) ''', ' ...
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

end % pop_tageeg