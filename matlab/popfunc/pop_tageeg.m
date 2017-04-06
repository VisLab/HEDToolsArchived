% Allows a user to tag a EEG structure. First all of the tag information
% and potential fields are extracted from EEG.event and EEG.etc.tags
% structures. After existing event tags are extracted and merged with an
% optional input fieldMap, the user is presented with a GUI to accept or
% exclude potential fields from tagging. Then the user is presented with
% the CTagger GUI to edit and tag. Finally, the tags are rewritten to the
% EEG structure.
%
% Usage:
%
%   >>  [EEG, com] = pop_tageeg(EEG)
%
%   >>  [EEG, com] = pop_tageeg(EEG, UseGui, 'key1', value1 ...)
%
%   >>  [EEG, com] = pop_tageeg(EEG, 'key1', value1 ...)
%
% Input:
%
%   Required:
%
%   EEG
%                    The EEG dataset structure that will be tagged. The
%                    dataset will need to have an .event field.
%
%   Optional:
%
%   UseGui
%                    If true (default), use a series of menus to set
%                    function arguments.
%
%   Optional (key/value):
%
%   'BaseMap'
%                    A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
%                    information.
%
%   'EventFieldsToIgnore'
%                    A one-dimensional cell array of field names in the
%                    .event substructure to ignore during the tagging
%                    process. By default the following subfields of the
%                    .event structure are ignored: .latency, .epoch,
%                    .urevent, .hedtags, and .usertags. The user can
%                    over-ride these tags using this name-value parameter.
%
%   'FMapDescription'
%                    The description of the fieldMap object. The
%                    description will show up in the .etc.tags.description
%                    field of any datasets tagged by this fieldMap.
%
%   'FMapSaveFile'
%                    A string representing the file name for saving the
%                    final, consolidated fieldMap object that results from
%                    the tagging process.
%
%   'HEDExtensionsAllowed'
%                    If true (default), the HED can be extended. If
%                    false, the HED cannot be extended. The
%                    'ExtensionAnywhere argument determines where the HED
%                    can be extended if extension are allowed.
%
%   'HEDExtensionsAnywhere'
%                    If true, the HED can be extended underneath all tags.
%                    If false (default), the HED can only be extended where
%                    allowed. These are tags with the 'ExtensionAllowed'
%                    attribute or leaf tags (tags that do not have
%                    children).
%
%   'HedXML'
%                    Full path to a HED XML file. The default is the
%                    HED.xml file in the hed directory.
%
%   'OverwriteUserHed'
%                    If true, overwrite/create the 'HED_USER.xml' file with
%                    the HED from the fieldMap object. The
%                    'HED_USER.xml' file is made specifically for modifying
%                    the original 'HED.xml' file. This file will be written
%                    under the 'hed' directory.
%
%   'PreserveTagPrefixes'
%                    If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
%   'PrimaryEventField'
%                    The name of the primary field. Only one field can be
%                    the primary field. A primary field requires a label,
%                    category, and a description tag. The default is the
%                    .type field.
%
%   'SelectEventFields'
%                    If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%
%   'SeparateUserHedFile'
%                    The full path and file name to write the HED from the
%                    fieldMap object to. This file is meant to be
%                    stored outside of the HEDTools.
%
%   'UseCTagger'
%                    If true (default), the CTAGGER GUI is used to edit
%                    field tags.
%
%   'WriteFMapToFile'
%                    If true, write the fieldMap object to the
%                    specified 'FMapSaveFile' file.
%
%   'WriteSeparateUserHedFile'
%                    If true, write the fieldMap object to the file
%                    specified by the 'SeparateUserHedFile' argument.
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

function [EEG, fMap, com] = pop_tageeg(EEG, varargin)
fMap = '';
com = '';

% Display help if inappropriate number of arguments
if nargin < 1
    EEG = '';
    help pop_tageeg;
    return;
end;

p = parseArguments(EEG, varargin{:});

% Call function with menu
if p.UseGui
  
    % Get the menu input parameters
    menuInputArgs = getkeyvalue({'BaseMap', 'HedExtensionsAllowed', ...
        'HedExtensionsAnywhere', 'HedXml', 'PreserveTagPrefixes', ...
        'SelectEventFields', 'UseCTagger'}, varargin{:});
    [canceled, baseMap, hedExtensionsAllowed, ...
        hedExtensionsAnywhere, hedXml, preserveTagPrefixes, ...
        selectEventFields, useCTagger] = ...
        pop_tageeg_input(menuInputArgs{:});
    menuOutputArgs = {'BaseMap', baseMap, 'HedExtensionsAllowed', ...
        hedExtensionsAllowed, 'HedExtensionsAnywhere', ...
        hedExtensionsAnywhere, 'HedXml', hedXml, 'PreserveTagPrefixes', ...
        preserveTagPrefixes, 'SelectEventFields', selectEventFields, ...
        'UseCTagger', useCTagger};
    
    if canceled
        return;
    end
    
    ignoreEventFields =  getkeyvalue({'EventFieldsToIgnore'}, varargin{:});
    tageegInputArgs = [getkeyvalue({'BaseMap', 'HedXml', ...
        'PreserveTagPrefixes'}, menuOutputArgs{:}) ignoreEventFields];
    
    canceled = false;
    
    % Merge base map
    [~, fMap] = tageeg(EEG, tageegInputArgs{:});
    
    taggerMenuArgs = getkeyvalue({'SelectEventFields', 'UseCTagger'}, ...
        menuOutputArgs{:});
    selectEventFields = taggerMenuArgs{2};
    useCTagger = taggerMenuArgs{4};
    
    % Select fields to tag
    ignoredEventFields = {};
    if useCTagger && selectEventFields
        selectmapsInputArgs = getkeyvalue({'PrimaryEventField'}, ...
            varargin{:});
        [canceled, ignoredEventFields] = selectmaps(fMap, ...
            selectmapsInputArgs{:});
    else
        fMap.setPrimaryMap(p.PrimaryEventField);
    end
    selectmapsOutputArgs = {'EventFieldsToIgnore', ignoredEventFields};
    
    % Use CTagger
    if useCTagger && ~canceled
        editmapsInputArgs = [getkeyvalue({'HedExtensionsAllowed', ...
            'HedExtensionsAnywhere', 'PreserveTagPrefixes'}, ...
            menuOutputArgs{:}) selectmapsOutputArgs];
        [fMap, canceled] = editmaps(fMap, editmapsInputArgs{:});
    end
    
    if canceled
        fprintf('Tagging was canceled\n');
        return;
    end
    fprintf('Tagging complete\n');
    
    inputArgs = [menuOutputArgs ignoreEventFields];
    % Save HED if modified
    if fMap.getXmlEdited()
        savehedInputArgs = getkeyvalue({'OverwriteUserHed', ...
            'SeparateUserHedFile', 'WriteSeparateUserHedFile'}, ...
            varargin{:});
        [fMap, overwriteUserHed, separateUserHedFile, ...
            writeSeparateUserHedFile] = pop_savehed(fMap, ...
            savehedInputArgs{:});
        savehedOutputArgs = {'OverwriteUserHed', overwriteUserHed, ...
            'SeparateUserHedFile', separateUserHedFile, ...
            'WriteSeparateUserHedFile', writeSeparateUserHedFile};
        inputArgs = [inputArgs savehedOutputArgs];
    end
    
    % Save field map containing tags
    savefmapInputArgs = getkeyvalue({'FMapDescription', ...
        'FMapSaveFile', 'WriteFMapToFile'}, varargin{:});
    [fMap, fMapDescription, fMapSaveFile] = ...
        pop_savefmap(fMap, savefmapInputArgs{:});
    savefmapOutputArgs = {'FMapDescription', fMapDescription, ...
        'FMapSaveFile', fMapSaveFile};
    
    writeTagsInputArgs = getkeyvalue({'PreserveTagPrefixes'}, ...
        menuOutputArgs{:});
    EEG = writetags(EEG, fMap, writeTagsInputArgs{:});
    
    inputArgs = [inputArgs savefmapOutputArgs];
end

% Call function without menu
if nargin > 1 && ~p.UseGui
    inputArgs = getkeyvalue({'BaseMap', 'EventFieldsToIgnore' ...
        'HedXml', 'PreserveTagPrefixes'}, varargin{:});
    [EEG, fMap] = tageeg(EEG, inputArgs{:});
end

com = char(['pop_tageeg(' inputname(1) ', ' logical2str(p.UseGui) ...
    ', ' keyvalue2str(inputArgs{:}) ');']);

    function p = parseArguments(EEG, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('EEG', @(x) (isempty(x) || isstruct(EEG)));
        parser.addOptional('UseGui', true, @islogical);
        parser.addParamValue('BaseMap', '', @(x) isa(x, 'fieldMap') || ...
            ischar(x));
        parser.addParamValue('EventFieldsToIgnore', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
            @iscellstr);
        parser.addParamValue('FMapDescription', '', @ischar);
        parser.addParamValue('FMapSaveFile', '', @(x)(isempty(x) || ...
            (ischar(x))));
        parser.addParamValue('HedExtensionsAllowed', true, @islogical);
        parser.addParamValue('HedExtensionsAnywhere', false, @islogical);
        parser.addParamValue('HedXml', which('HED.xml'), @ischar);
        parser.addParamValue('OverwriteUserHed', '', @islogical);
        parser.addParamValue('PreserveTagPrefixes', false, @islogical);
        parser.addParamValue('PrimaryEventField', 'type', @(x) ...
            (isempty(x) || ischar(x)))
        parser.addParamValue('SelectEventFields', true, @islogical);
        parser.addParamValue('SeparateUserHedFile', '', @(x) ...
            (isempty(x) || (ischar(x))));
        parser.addParamValue('UseCTagger', true, @islogical);
        parser.addParamValue('WriteFMapToFile', false, @islogical);
        parser.addParamValue('WriteSeparateUserHedFile', false, ...
            @islogical);
        parser.parse(EEG, varargin{:});
        p = parser.Results;
    end % parseArguments

end % pop_tageeg