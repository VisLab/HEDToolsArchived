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
parser.addParamValue('Fields', {}, @iscellstr);
parser.addParamValue('EditXml', false, @islogical);
parser.addParamValue('ExcludedFields', {}, @iscellstr);
parser.addParamValue('PreservePrefix', false, @islogical);
parser.parse(fMap, varargin{:});
p = parser.Results;
p.excluded = p.ExcludedFields;
p.EditXml = p.EditXml;
p.preservePrefix = p.PreservePrefix;
p.permissions = 0;
p.initialDepth = 3;
p.isStandAloneVersion = false;
if ~isempty(p.Fields)
    p.fields = p.Fields;
else
    p.fields = p.fMap.getFields();
end
p.canceled = false;
p.k = 1;
p.firstField = true;
while (~p.canceled && p.k <= length(p.fields))
    fprintf('Tagging %s\n', p.fields{p.k});
    p.field = p.fields{p.k};
    p = editmap(p);
end
canceled = p.canceled;

    function p = editmap(p)
        % Proceed with tagging for field values and adjust fMap accordingly
        p.tMap = p.fMap.getMap(p.field);
        if isempty(p.tMap)
            p.k = p.k + 1;
            return;
        end
        p = executeTagger(p);
        if p.loaded
            baseTags = fieldMap.loadFieldMap(char(p.loader.getFMapPath));
            p.fMap.merge(baseTags, 'Merge', p.excluded, p.fields);
            if p.loader.isStartOver()
                p.k = 1;
                p.firstField = true;
            end
        elseif p.loader.isSubmitted()
            updateFieldMap(p);
            if p.loader.isBack()
                p.k = p.k - 1;
            else
                p.k = p.k + 1;
            end
            p.firstField = p.k == 1;
        else
            p.canceled = true;
        end
    end % editmap

    function p = executeTagger(p)
        % Executes the CTagger gui
        p = getTaggerParameters(p);
        p.loader = javaObject('edu.utsa.tagger.TaggerLoader', ...
            p.xml, p.tValues, p.flags, p.permissions, p.eTitle, ...
            p.initialDepth,  p.primary, p.isStandAloneVersion, ...
            p.firstField);
        p = checkStatus(p);
        while (~p.notified)
            pause(0.5);
            checkFMapSave(p);
            p = checkStatus(p);
        end
        p.taggedList = p.loader.getXMLAndEvents();
    end % executeTagger

    function p = checkStatus(p)
        % Checks the status of the CTagger
        p.loaded = p.loader.fMapLoaded();
        p.saved = p.loader.fMapSaved();
        p.notified = p.loader.isNotified();
    end % checkStatus

    function checkFMapSave(p)
        % Checks if an fieldMap has been saved
        if p.saved
            p.taggedList = p.loader.getXMLAndEvents();
            updateFieldMap(p);
            p.fMap.saveFieldMap(char(p.loader.getFMapPath), p.fMap);
            p.loader.setFMapSaved(false);
        end
    end % checkFMapSave

    function p = getTaggerParameters(p)
        % Gets the parameters that are passed into the CTagger
        p.primary = p.tMap.getPrimary();
        p.tValues = strtrim(char(p.tMap.getJsonValues()));
        p.xml = p.fMap.getXml();
        p.flags = setFlags(p);
        p.eTitle = ['Tagging ' p.field ' values'];
    end % getTaggerParameters

    function flags = setFlags(p)
        % Sets the flags parameter based on the input arguments
        flags = 1;
        if p.EditXml
            flags = bitor(flags,8);
        end
        if p.preservePrefix
            flags = bitor(flags,2);
        end
    end % setFlags

    function updateFieldMap(p)
        % Updates fMap if CTagger is submitted
        if ~isempty(p.taggedList)
            tValues = strtrim(char(p.taggedList(2, :)));
        end
        tValues = tagMap.json2Values(tValues);
        p.fMap.mergeXml(strtrim(p.xml));
        p.fMap.removeMap(p.field);
        p.fMap.addValues(p.field, tValues, 'Primary', p.tMap.getPrimary());
        p.fMap.updateXml();
    end % updateFieldMap

end % editmaps