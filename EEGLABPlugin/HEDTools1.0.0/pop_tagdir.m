% Allows a user to tag a directory of datasets using a GUI. pop_tagdir
% first brings up a GUI to allow the user to set parameters for the tagdir
% function, and then calls tagdir to consolidate the tags from all of the
% data files in the specified directories. Depending on the arguments,
% tagdir may bring up a menu to allow the user to choose which fields
% should be tagged. The tagdir function may also bring up the CTAGGER GUI
% to allow users to edit the tags.
%
% Usage:
%
%   >>  [fMap, fPaths, com] = pop_tagdir()
%
%   >>  [fMap, fPaths, com] = pop_tagdir(inDir)
% 
%   >>  [fMap, fPaths, com] = pop_tagdir(inDir, 'key1', value1 ...)
%
% Input:
%
%   Required:
%
%   inDir
%                    A directory that contains similar EEG .set files.
%
%   Optional (key/value):
%
%   'BaseMap'
%                    A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
%                    information.
%
%   'DoSubDirs'
%                    If true (default), the entire inDir directory tree is
%                    searched. If false, only the inDir directory is
%                    searched.
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
%                    category, and a description. The default is the type
%                    field.
%
%   'SaveDatasets'
%                    If true, save the tags to the underlying
%                    dataset files in the directory. If false (default),
%                    do not save the tags to the underlying dataset files
%                    in the directory.
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
%                    If true (default), the CTAGGER GUI is displayed after
%                    initialization.
%
% Output:
%
%   fMap             A fieldMap object that contains the tag map
%                    information.
%
%   fPaths           A list of full file names of the datasets to be
%                    tagged.
%
%   com              String containing call to tagdir with all
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function [fMap, fPaths, com] = pop_tagdir(inDir, varargin)
fMap = '';
fPaths = '';
com = '';

% Get the input parameters
[baseMap, canceled, doSubDirs, extensionsAllowed, extensionsAnywhere, ...
    hedXML, inDir, preservePrefix, selectFields, useGUI] = tagdir_input();
if canceled
    return;
end

% Tag the EEG directory
[fMap, fPaths, canceled] = tagdir(inDir, 'BaseMap', baseMap, ...
    'DoSubDirs', doSubDirs, 'ExtensionsAllowed', extensionsAllowed, ...
    'ExtensionsAnywhere', extensionsAnywhere, 'HedXML', hedXML, ...
    'PreservePrefix', preservePrefix, 'SelectFields', selectFields, ...
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
    overwritedataset(fMap, inDir, 'PreservePrefix', preservePrefix);
end

% Create command string
com = char(['tagdir(''' inDir ''', ' ...
    '''BaseMap'', ''' baseMap ''', ' ...
    '''DoSubDirs'', ' logical2str(doSubDirs) ', ' ...
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

end % pop_tagdir