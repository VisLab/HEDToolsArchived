% editmaps
% Allows a user to selectively edit the tags using the ctagger GUI
%
% Usage:
%   >>  fMap = editmaps(fMap)
%   >>  fMap = editmaps(fMap, 'key1', 'value1', ...)
%
% Description:
% fMap = editmaps(fMap) presents a CTAGGER tagging GUI for each of the
% fields in fMap and allows users to tag, add items to the tag
% hierarchy or add/edit events.
%
% fMap = editmaps(fMap, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%
%   'EditXml'        If false (default), the HED XML cannot be modified
%                    using the tagger GUI. If true, then the HED XML can
%                    be modified using the tagger GUI.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'Synchronize'    If false (default), the ctagger GUI is run with
%                    synchronization done using the MATLAB pause. If
%                    true, synchronization is done within Java. This
%                    latter option is usually reserved when not calling
%                    the GUI from MATLAB.
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for editmaps:
%
%    doc editmaps
%
% See also:
%
% Copyright (C) Kay Robbins, Jeremy Cockfield, and Thomas Rognon, UTSA,
% 2011-2015, kay.robbins.utsa.edu jeremy.cockfield.utsa.edu
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
%
% $Log: editmaps.m,v $
% $Revision: 2.0 10-Jul-2015 14:07:15 $
% $Initial version $
%

function [fMap, canceled] = editmaps(fMap, varargin)
% Check the input arguments for validity and initialize
parser = inputParser;
parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
parser.addParamValue('EditXml', false, @islogical);
parser.addParamValue('PreservePrefix', false, @islogical);
parser.addParamValue('Synchronize', false, @islogical);
parser.parse(fMap, varargin{:});
excluded = {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'};
EditXml = parser.Results.EditXml;
preservePrefix = parser.Results.PreservePrefix;
% syncThis = parser.Results.Synchronize;
permissions = 0;
initialDepth = 3;
isStandAloneVersion = false;
fields = fMap.getFields();
canceled = false;
k = 1;
while (~canceled && k <= length(fields))
    fprintf('Tagging %s\n', fields{k});
    editmap(fields{k});
end

    function editmap(field)
        % Proceed with tagging for field values and adjust fMap accordingly
        tMap = fMap.getMap(field);
        if isempty(tMap)
            return;
        end
        [loader, xml, taggedList, loaded] = executeTagger(tMap, field);
        if loaded
            baseTags = fieldMap.loadFieldMap(char(loader.getFMapPath));
            fMap.merge(baseTags, 'Merge', excluded, fields);
            if loader.isStartOver()
                k = 1;
            end
        elseif loader.isSubmitted()
            updateFieldMap(field, xml, taggedList);
            k = k + 1;
        else
            canceled = true;
        end
    end % editmap

    function [loader, xml, taggedList, loaded] = ...
            executeTagger(tMap, field)
        % Executes the CTagger gui
        [primary, tValues, xml, flags, eTitle] = ...
            getTaggerParameters(tMap, field);
        loader = javaObjectEDT('edu.utsa.tagger.TaggerLoader', ...
            xml, tValues, flags, permissions, eTitle, initialDepth, ...
            primary, isStandAloneVersion);
        [loaded, saved, notified] = checkStatus(loader);
        while (~notified)
            pause(0.5);
            checkFMapSave(field, loader, xml, saved);
            [loaded, saved, notified] = checkStatus(loader);
        end
        taggedList = loader.getXMLAndEvents();
    end % executeTagger

    function [loaded, saved, notified] = checkStatus(loader)
        % Checks the status of the CTagger
        loaded = loader.fMapLoaded();
        saved = loader.fMapSaved();
        notified = loader.isNotified();
    end % checkStatus

    function checkFMapSave(field, loader, xml, saved)
        % Checks if an fieldMap has been saved
        if saved
            taggedList = loader.getXMLAndEvents();
            updateFieldMap(field, xml, taggedList);
            fMap.saveFieldMap(char(loader.getFMapPath), fMap);
            loader.setFMapSaved(false);
        end
    end % checkFMapSave

    function [primary, tValues, xml, flags, eTitle] = ...
            getTaggerParameters(tMap, field)
        % Gets the parameters that are passed into the CTagger
        primary = tMap.getPrimary();
        tValues = strtrim(char(tMap.getJsonValues()));
        xml = fMap.getXml();
        flags = setFlags();
        eTitle = ['Tagging ' field ' values'];
    end % getTaggerParameters

    function flags = setFlags()
        % Sets the flags parameter based on the input arguments
        flags = 1;
        if EditXml
            flags = bitor(flags,8);
        end
        if preservePrefix
            flags = bitor(flags,2);
        end
    end % setFlags

    function updateFieldMap(field, xml, taggedList)
        % Updates fMap if CTagger is submitted
        if ~isempty(taggedList)
            tValues = strtrim(char(taggedList(2, :)));
        end
        tValues = tagMap.json2Values(tValues);
        fMap.mergeXml(strtrim(xml));
        fMap.removeMap(field);
        fMap.addValues(field, tValues);
        fMap.updateXml();
    end % updateFieldMap

end % editmaps