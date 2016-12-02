% Creates a fieldMap object for the existing tags in a data structure.
%
% Usage:
%
%   >>  fMap = findtags(edata)
%
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
%   'HedXml'
%                    Full path to a HED XML file. The default is the
%                    HED.xml file in the hed directory.
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

function fMap = findtags(edata, varargin)
p = parseArguments(edata, varargin{:});
if  hasSummaryTags(p)
    fMap = etc2fMap(p);
else
    fMap = events2fMap(p);
end

    function summaryFound = hasSummaryTags(p)
        % Returns true if there are summary tags found in the .etc field
        summaryFound = isfield(p.edata, 'etc') && ...
            isstruct(p.edata.etc) && ...
            isfield(p.edata.etc, 'tags') && ...
            isstruct(p.edata.etc.tags) && ...
            isfield(p.edata.etc.tags, 'map') && ...
            isstruct(p.edata.etc.tags.map) && ...
            isfield(p.edata.etc.tags.map, 'field');
    end % hasSummaryTags

    function xmlFound = hasXML(p)
        % Returns true if there is a HED XML string found in the .etc field
        xmlFound = isfield(p.edata, 'etc') && ...
            isstruct(p.edata.etc) && ...
            isfield(p.edata.etc, 'tags') && ...
            isstruct(p.edata.etc.tags) && ...
            isfield(p.edata.etc.tags, 'xml') && ...
            ischar(p.edata.etc.tags.xml);
    end % hasXML

    function fMap = etc2fMap(p)
        % Adds field values to the field maps from the .event and .etc
        % field
        fMap = intializefMap(p);
        etcFields = getEtcFields(p);
        eventFields = setdiff(getEventFields(p), etcFields);
        for k = 1:length(etcFields)
            fMap = addEtcValues(p, fMap, etcFields{k});
        end
        for k = 1:length(eventFields)
            fMap = addEventValues(p, fMap, eventFields{k});
        end
    end % etc2fMap

    function fMap = intializefMap(p)
        % Initialized the field maps
        if hasXML(p)
            xml = p.edata.etc.tags.xml;
        else
            xml = fileread(p.HedXml);
        end
        fMap = fieldMap('Xml', xml, 'PreserveTagPrefixes', ...
            p.PreserveTagPrefixes);
    end % intializefMap

    function fMap = events2fMap(p)
        % Creates and populates the field maps from the .event and
        % .urevent fields
        fMap = intializefMap(p);
        eventFields = getEventFields(p);
        for k = 1:length(eventFields)
            fMap = addEventValues(p, fMap, eventFields{k});
        end
    end % events2fMap

    function fMap = addEtcValues(p, fMap, eventField)
        % Adds the field values to the field maps from the .etc field
        index = strcmpi({p.edata.etc.tags.map.field}, eventField);
        if isempty(p.edata.etc.tags.map(index).values)
            addEventValues(p, fMap, eventField);
        else
            fMap.addValues(eventField, p.edata.etc.tags.map(index).values);
        end
    end % addEtcValues

    function fMap = addEventValues(p, fMap, eventField)
        % Adds the field values to the field maps from the .event field
        tValues = getutypes(p.edata.event, eventField);
        if isempty(tValues)
            return;
        end
        valueForm = tagList.empty(0,length(tValues));
        for j = 1:length(tValues)
            valueForm(j) = tagList(num2str(tValues{j}));
        end
        fMap.addValues(eventField, valueForm);
        if isfield(p.edata.event, 'usertags')
            tMap = extracttags(p.edata.event, eventField);
            tMapValues = getValues(tMap);
            for j = 1:length(tMapValues)
                fMap.addValues(eventField, tMapValues{j});
            end
        end
    end % addEventValues

    function eventFields  = getEventFields(p)
        % Gets all of the event fields from the .event and .urevent fields
        eventFields = {};
        if isfield(p.edata, 'event') && isstruct(p.edata.event)
            eventFields = fieldnames(p.edata.event);
        end
        if isfield(p.edata, 'urevent') && isstruct(p.edata.urevent)
            eventFields = union(eventFields, ...
                fieldnames(p.edata.urevent));
        end
        eventFields = setdiff(eventFields, p.EventFieldsToIgnore);
    end % getEventFields

    function etcFields = getEtcFields(p)
        % Gets all of the event fields from the .etc field
        etcFields = {p.edata.etc.tags.map.field};
        etcFields = setdiff(etcFields, p.EventFieldsToIgnore);
    end % getEtcFields

    function p = parseArguments(edata, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('edata', @(x) (isempty(x) || isstruct(x)));
        parser.addParamValue('EventFieldsToIgnore', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
            @(x) (iscellstr(x)));
        parser.addParamValue('HedXml', which('HED.xml'), @ischar);
        parser.addParamValue('PreserveTagPrefixes', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        parser.parse(edata, varargin{:});
        p = parser.Results;
    end % parseArguments

end % findtags