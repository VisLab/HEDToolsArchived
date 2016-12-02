% Allows a user to selectively edit the tags using the CTagger GUI.
%
% Usage:
%
%   >>  fMap = editmaps(fMap)
%
%   >>  fMap = editmaps(fMap, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   fMap
%                    A fieldMap object that stores all of the tags.
%
%   Optional (key/value):
%
%   'EventFieldsToIgnore'
%                    A cell array of field names in the .event substructure
%                    to ignore during the tagging process.
%
%   'HedExtensionsAllowed'
%                    If true (default), the HED can be extended. If
%                    false, the HED can not be extended. The 
%                    'ExtensionAnywhere argument determines where the HED
%                    can be extended if extension are allowed.
%                  
%   'HedExtensionsAnywhere'
%                    If true, the HED can be extended underneath all tags.
%                    If false (default), the HED can only be extended where
%                    allowed. These are tags with the 'extensionAllowed'
%                    attribute or leaf tags (tags that do not have
%                    children).
%
%   'PreserveTagPrefixes'
%                    If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
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

function [fMap, canceled] = editmaps(fMap, varargin)
% Check the input arguments for validity and initialize
p = parseArguments(fMap, varargin{:});
p = setDefaultParameters(p);
while (~p.canceled && p.k <= length(p.fieldsToTag))
    fprintf('Tagging %s\n', p.fieldsToTag{p.k});
    p.field = p.fieldsToTag{p.k};
    p = editFieldTags(p);
end
canceled = p.canceled;

    function p = setDefaultParameters(p)
        % Set the default parameters for this function
        p.initialDepth = 3;
        p.hedExtended = false;
        p.standAlone = false;
        p.useJSON = true;
        p.fieldsToTag = sort(setdiff(p.fMap.getFields(), ...
            p.EventFieldsToIgnore));
        p.canceled = false;
        p.k = 1;
        p.firstField = true;
    end % setDefaultParameters

    function p = editFieldTags(p)
        % Edit the tags in the current field using CTagger
        p.tMap = p.fMap.getMap(p.field);
        if isempty(p.tMap)
            p.k = p.k + 1;
            return;
        end
        p = executeCTagger(p);
        if p.loaded
            baseTags = fieldMap.loadFieldMap(char(p.loader.getFMapPath));
            p.fMap.merge(baseTags, 'Update', {}, p.fieldsToTag);
            if p.loader.isStartOver()
                p.k = 1;
                p.firstField = true;
            end
        elseif p.loader.isSubmitted()
            p = updatefMap(p);
            if p.loader.isBack()
                p.k = p.k - 1;
            else
                p.k = p.k + 1;
            end
            p.firstField = p.k == 1;
        else
            p.canceled = true;
        end
    end % editFieldTags

    function p = executeCTagger(p)
        % Executes the CTagger GUI for the current field
        p = getCTaggerParameters(p);
        p.loader = javaObject('edu.utsa.tagger.TaggerLoader', ...
            p.xml, p.tValues, p.flags, p.eTitle, p.initialDepth);
        p = checkCTaggerStatus(p);
        while (~p.notified)
            pause(0.5);
            p = checkfMapSave(p);
            p = checkCTaggerStatus(p);
        end
        p.taggedList = p.loader.getXMLAndEvents();
    end % executeCTagger

    function p = checkCTaggerStatus(p)
        % Checks the status of the CTagger
        p.loaded = p.loader.fMapLoaded();
        p.saved = p.loader.fMapSaved();
        p.notified = p.loader.isNotified();
    end % checkCTaggerStatus

    function p = checkfMapSave(p)
        % Checks if an fieldMap has been saved
        if p.saved
            p.taggedList = p.loader.getXMLAndEvents();
            p = updatefMap(p);
            p.fMap.saveFieldMap(char(p.loader.getFMapPath), p.fMap);
            p.loader.setFMapSaved(false);
        end
    end % checkFMapSave

    function p = getCTaggerParameters(p)
        % Gets the parameters that are passed into the CTagger
        p.primaryField = p.tMap.getPrimary();
        p.tValues = strtrim(char(p.tMap.getJsonValues()));
        p.xml = p.fMap.getXml();
        p.flags = setCTaggerFlags(p);
        p.eTitle = ['Tagging ' p.field ' values'];
    end % getCTaggerParameters

    function flags = setCTaggerFlags(p)
        % Sets the flags parameter in CTagger
        flags = 1;
        if p.PreserveTagPrefixes
            flags = bitor(flags,2);
        end
        if p.HedExtensionsAllowed
            flags = bitor(flags,4);
        end
        if p.HedExtensionsAnywhere
            flags = bitor(flags,8);
        end
        if p.standAlone
            flags = bitor(flags,16);
        end
        if p.primaryField
            flags = bitor(flags,32);
        end
        if p.firstField
            flags = bitor(flags,64);
        end
        if p.hedExtended
            flags = bitor(flags,128);
        end
    end % setCTaggerFlags

    function p = updatefMap(p)
        % Updates the fMap tags if the current field is submitted in the
        % CTagger or a new fMap is loaded
        p.xml = strtrim(char(p.taggedList(1, :)));
        tValues = strtrim(char(p.taggedList(2, :)));
        tValues = tagMap.json2Values(tValues);
        p.fMap.removeMap(p.field);
        p.fMap.addValues(p.field, tValues, 'Primary', p.tMap.getPrimary());
        if p.HedExtensionsAllowed && p.loader.getHEDExtended()
            p.hedExtended = true;
            p.fMap.setXmlEdited(true);
            p.fMap.setXml(p.xml);
        end
    end % updatefMap

    function p = parseArguments(fMap, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, ...
            'fieldMap')));
        parser.addParamValue('EventFieldsToIgnore', {}, @iscellstr);
        parser.addParamValue('HedExtensionsAllowed', true, @islogical);
        parser.addParamValue('HedExtensionsAnywhere', false, @islogical);
        parser.addParamValue('PreserveTagPrefixes', false, @islogical);
        parser.parse(fMap, varargin{:});
        p = parser.Results;
    end % parseArguments

end % editmaps