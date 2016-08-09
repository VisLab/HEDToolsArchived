% Creates a fieldMap object for the existing tags in a data structure.
%
% Usage:
%
%   >>  fMap = findtags(edata)
%   >>  fMap = findtags(edata, 'key1', 'value1', ...)
%
% Inputs:
%
% Required:
%
%   edata
%                    The EEG dataset structure that tags will be extracted
%                    from. The dataset will need to have a .event field.
%
% Key/Value:
%
%   'ExcludeFields'
%                    A cell array containing the field names to exclude
%
%   'Fields'
%                    A cell array containing the field names to extract
%                    tags for.
%
%   'PreservePrefix'
%                    If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013,
% krobbins@cs.utsa.edu
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

function [fMap1, fMap2] = findtags(edata, varargin)
p = parseArgs(edata, varargin{:});

if isfield(p.edata, 'etc') && isstruct(p.edata.etc) && ...
        isfield(p.edata.etc, 'tags') && isstruct(p.edata.etc.tags)
    [fMap1, fMap2] = etcToFMap(p);
else
    [fMap1, fMap2] = eventsToFMap(p);
end

    function [fMap1, fMap2] = etcToFMap(p)
        % Creates and populates the field maps from the .etc field
        p = intializeFMaps(p);
        if isfield(p.edata.etc.tags, 'map') && ...
                isstruct(p.edata.etc.tags.map) ...
                && isfield(p.edata.etc.tags.map, 'field')
            p = addValues(p);
        end
        fMap1 = p.fMap1;
        fMap2 = p.fMap2;
    end % etcToFMap

    function p = intializeFMaps(p)
        % Initialized the field maps
        xml = '';
        if isfield(p.edata.etc, ...
                'tags') && isfield(p.edata.etc.tags, 'xml')
            xml = p.edata.etc.tags.xml;
        end
        p.fMap1 = fieldMap('XML', xml, 'PreservePrefix', p.PreservePrefix);
        p.fMap2 = fieldMap('XML', xml, 'PreservePrefix', p.PreservePrefix);
    end % intializeFMaps

    function [fMap1, fMap2] = eventsToFMap(p)
        % Creates and populates the field maps from the .event and
        % .urevent fields
        p = intializeFMaps(p);
        [p.allEventFields, p.taggedEventFields] = getEventFields(p);
        for k = 1:length(p.allEventFields)
            p = addEventValues(p, k);
        end
        fMap1 = p.fMap1;
        fMap2 = p.fMap2;
    end % eventsToFMap

    function p = addValues(p)
        % Adds field values to the field maps from the .event and .etc
        % field
        [p.allEtcFields, p.taggedEtcFields] = getEtcFields(p);
        [p.allEventFields, p.taggedEventFields] = getEventFields(p);
        p.allEventFields = setdiff(p.allEventFields, p.allEtcFields);
        p.taggedEventFields = setdiff(p.taggedEventFields, ...
            p.taggedEtcFields);
        for k = 1:length(p.allEtcFields)
            p = addEtcValues(p, k);
        end
        for k = 1:length(p.allEventFields)
            p = addEventValues(p, k);
        end
    end % addValues

    function p = addEtcValues(p, index)
        % Adds the field values to the field maps from the .etc field
        if isempty(p.edata.etc.tags.map(index).values)
            addEventValues(p, index);
        else
            thisField = p.edata.etc.tags.map(index).field;
            if sum(strcmpi(thisField, p.taggedEtcFields) == 1)
                p.fMap2.addValues(thisField, ...
                    p.edata.etc.tags.map(index).values);
            end
            p.fMap1.addValues(thisField, ...
                p.edata.etc.tags.map(index).values);
        end
    end % addEtcValues

    function p = addEventValues(p, index)
        % Adds the field values to the field maps from the .event and
        % .urevent fields
        tValues = getutypes(p.edata.event, p.allEventFields{index});
        if isfield(p.edata, 'urevent')
            tValues = union(tValues, getutypes(p.edata.urevent, ...
                p.allEventFields{index}));
        end
        if isempty(tValues)
            return;
        end
        valueForm = tagList.empty(0,length(tValues));
        for j = 1:length(tValues)
            valueForm(j) = tagList(num2str(tValues{j}));
        end
        if sum(strcmpi(p.allEventFields{index}, p.taggedEventFields) == 1)
            p.fMap2.addValues(p.allEventFields{index}, valueForm);
        end
        p.fMap1.addValues(p.allEventFields{index}, valueForm);
    end % addEventValues

    function [allEventFields, taggedEventFields] = getEventFields(p)
        % Gets all of the event fields from the .event and .urevent fields
        allEventFields = {};
        taggedEventFields = {};
        if isfield(p.edata, 'event') && isstruct(p.edata.event)
            allEventFields = fieldnames(p.edata.event);
            taggedEventFields = fieldnames(p.edata.event);
        end
        if isfield(p.edata, 'urevent') && isstruct(p.edata.urevent)
            allEventFields = union(allEventFields, ...
                fieldnames(p.edata.urevent));
            taggedEventFields = union(allEventFields, ...
                fieldnames(p.edata.urevent));
        end
        %         allFields = setdiff(allFields, p.ExcludeFields);
        %         taggedFields = setdiff(taggedFields, p.ExcludeFields);
        if ~isempty(p.Fields)
            taggedEventFields = intersect(p.Fields, allEventFields);
        end
    end % getEventFields

    function [allFields, taggedFields] = getEtcFields(p)
        % Gets all of the event fields from the .etc field
        allFields = {p.edata.etc.tags.map.field};
        taggedFields = {p.edata.etc.tags.map.field};
        if ~isempty(p.Fields)
            taggedFields = intersect(p.Fields, taggedFields);
        end
    end % getEtcFields

    function p = parseArgs(edata, varargin)
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
    end % parseArgs

end % findtags