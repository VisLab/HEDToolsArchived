% findtags
% Creates a fieldMap object for the existing tags in a data structure
%
% Usage:
%   >>  fMap = findtags(edata)
%   >>  fMap = findtags(edata, 'key1', 'value1', ...)
%
% Description:
% fMap = findtags(edata) extracts a fieldMap object representing the
% events and their tags for the structure.
%
% tMap = findtags(edata, 'key1', 'value1', ...) specifies optional
% name/value parameter pairs:
%
%   'ExcludeFields'  A cell array containing the field names to exclude
%   'Fields'         A cell array containing the field names to extract
%                    tags for.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
% Notes:
%   The edata structure should have its events encoded as a structure
%   array edata.events. The findtags will also examinate a edata.urevents
%   structure array if it exists.
%
%   Tags are assumed to be stored in the edata.etc structure as follows:
%
%    edata.etc.tags.xml
%    edata.etc.tags.map
%       ...
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for findtags:
%
%    doc findtags
%
% See also: fMap
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
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
% $Log: findtags.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function [fMapAll, fMapTagged] = findtags(edata, varargin)
p = parseArguments();

if isfield(p.edata, 'etc') && isstruct(p.edata.etc) && ...
        isfield(p.edata.etc, 'tags') && isstruct(p.edata.etc.tags)
    [fMapAll, fMapTagged] = createFMapsFromEtc(p);
else
    [fMapAll, fMapTagged] = createFMapsFromEvents(p);
end

    function [fMapAll, fMapTagged] = createFMapsFromEtc(p)
        % Creates and populates the field maps from the .etc field
        xml = '';
        if isfield(p.edata.etc.tags, 'xml')
            xml = p.edata.etc.tags.xml;
        end
        fMapAll = fieldMap('XML', xml, 'PreservePrefix', ...
            p.PreservePrefix);
        fMapTagged = fieldMap('XML', xml, 'PreservePrefix', ...
            p.PreservePrefix);
        if isfield(p.edata.etc.tags, 'map') && ...
                isstruct(p.edata.etc.tags.map) ...
                && isfield(p.edata.etc.tags.map, 'field')
            [allFields, taggedFields] = getFieldsFromEtc(p);
            for k = 1:length(allFields)
                addFieldValuesFromEtc(p, fMapAll, fMapTagged, ...
                    allFields, taggedFields, k);
            end
        end
    end % createFMapsFromEtc

    function [fMapAll, fMapTagged] = createFMapsFromEvents(p)
        % Creates and populates the field maps from the .event and
        % .urevent fields
        [allFields, taggedFields] = getFieldsFromEvents(p);
        fMapAll = fieldMap('PreservePrefix', p.PreservePrefix);
        fMapTagged = fieldMap('PreservePrefix', p.PreservePrefix);
        for k = 1:length(allFields)
            [fMapAll, fMapTagged] = addFieldValuesFromEvents(p, ...
                fMapAll, fMapTagged, allFields, taggedFields, k);
        end
    end % createFMapsFromEvents

    function [fMapAll, fMapTagged] = addFieldValuesFromEtc(p, fMapAll, ...
            fMapTagged, allFields, taggedFields, index)
        % Adds the field values to the field maps from the .etc field
        if isempty(p.edata.etc.tags.map(index).values)
            addFieldValuesFromEvents(p, fMapAll, fMapTagged, ...
                allFields, taggedFields, index);
        else
            thisField = p.edata.etc.tags.map(index).field;
            if sum(strcmpi(thisField, taggedFields) == 1)
                fMapTagged.addValues(thisField, ...
                    p.edata.etc.tags.map(index).values);
            end
            fMapAll.addValues(thisField, ...
                p.edata.etc.tags.map(index).values);
        end
    end % addFieldValuesFromEtc

    function [fMapAll, fMapTagged] = addFieldValuesFromEvents(p, ...
            fMapAll, fMapTagged, allFields, taggedFields, index)
        % Adds the field values to the field maps from the .event and
        % .urevent fields
        tValues = getutypes(p.edata.event, allFields{index});
        if isfield(p.edata, 'urevent')
            tValues = union(tValues, getutypes(p.edata.urevent, ...
                allFields{index}));
        end
        if isempty(tValues)
            return;
        end
        valueForm = tagList.empty(0,length(tValues));
        for j = 1:length(tValues)
            valueForm(j) = tagList(num2str(tValues{j}));
        end
        if sum(strcmpi(allFields{index}, taggedFields) == 1)
            fMapTagged.addValues(allFields{index}, valueForm);
        end
        fMapAll.addValues(allFields{index}, valueForm);
    end % addFieldValuesFromEvents

    function [allFields, taggedFields] = getFieldsFromEvents(p)
        % Gets all of the event fields from the .event and .urevent fields
        allFields = {};
        taggedFields = {};
        if isfield(p.edata, 'event') && isstruct(p.edata.event)
            allFields = fieldnames(p.edata.event);
            taggedFields = fieldnames(p.edata.event);
        end
        if isfield(p.edata, 'urevent') && isstruct(p.edata.urevent)
            allFields = union(allFields, fieldnames(p.edata.urevent));
            taggedFields = union(allFields, fieldnames(p.edata.urevent));
        end
        allFields = setdiff(allFields, p.ExcludeFields);
        taggedFields = setdiff(taggedFields, p.ExcludeFields);
        if ~isempty(p.Fields)
            taggedFields = intersect(p.Fields, allFields);
        end
    end % getFieldsFromEvents

    function [allFields, taggedFields] = getFieldsFromEtc(p)
        % Gets all of the event fields from the .etc field
        taggedFields = {p.edata.etc.tags.map.field};
        allFields = {p.edata.etc.tags.map.field};
        if ~isempty(p.Fields)
            taggedFields = intersect(p.Fields, taggedFields);
        end
    end % getFieldsFromEtc

    function p = parseArguments()
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('edata', @(x) (isempty(x) || isstruct(x)));
        parser.addParamValue('ExcludeFields', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
            @(x) (iscellstr(x)));
        parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
        parser.addParamValue('PreservePrefix', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        parser.parse(edata, varargin{:});
        p = parser.Results;
    end % parseArguments

% for k = 1:length(efields)
%     if isfield(edata.event, 'usertags')
%         tMap = extractTags(edata, efields{k});
%         tMapValues = getValues(tMap);
%         for j = 1:length(tMapValues)
%             fMap.addValues(efields{k}, tMapValues{j});
%         end
%     end
%     tValues = getutypes(edata.event, efields{k});
%     if isfield(edata, 'urevent')
%         tValues = union(tValues, getutypes(edata.urevent, efields{k}));
%     end
%     if isempty(tValues)
%         continue
%     end
%     valueForm = tagList.empty(0,length(tValues));
%     for j = 1:length(tValues)
%         valueForm(j) = tagList(num2str(tValues{j}));
%     end
%     fMap.addValues(efields{k}, valueForm);
% end
end %findtags