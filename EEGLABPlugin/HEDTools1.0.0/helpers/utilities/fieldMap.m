% Creates an object encapsulating xml tags and type-tagMap association.
% This object can produce output in either JSON or a structure array.
%
% Usage:
%
%   >>  obj = fieldMap()
%
%   >>  obj = fieldMap('key1', 'value1', ...)
%
% Input:
%
%    Optional (key/value):
%
%   'Description'      String describing the purpose of this fieldMap.
%
%   'PreservePrefix'   Logical if false (default) tags with matching
%                      prefixes are merged to be the longest.
%
%   'XML'              XML string specifying tag hierarchy to be used.
%
% Notes:
%
%   Merge options:
%
%   'Merge'           If an event with that key is not part of this
%                     object, add it as is.
%
%   'None'            Don't update anything in the structure
%
%   'Replace'         If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object then completely replace
%                     that event with the new one.
%
%   'Update'          If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object, then update the tags of
%                     the matching event with the new ones from this event,
%                     using the PreservePrefix value to determine how to
%                     combine the tags. Also update any empty code
%                     fields by using the values in the
%                     input event.
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, ...
% 2011-2013, krobbins@cs.utsa.edu
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

classdef fieldMap < hgsetget
    properties (Constant = true)
        DefaultXml = 'HED.xml';
        DefaultSchema = 'HED.xsd';
    end % constant
    
    properties (Access = private)
        Description          % String describing this field map
        GroupMap             % Map for matching event labels
        PreservePrefix       % If true, don't eliminate duplicate
        % prefixes (default false)
        PrimaryField
        Xml                  % Tag hierarchy as an XML string
        XmlEdited            % If true, the HED has been modified through
        % the CTagger (default false)
        XmlSchema            % String containing the XML schema
    end % private properties
    
    methods
        function obj = fieldMap(varargin)
            % Constructor parses parameters and sets up initial data
            p = fieldMap.parseArguments(varargin{:});
            obj.Description = p.Description;
            obj.PreservePrefix = p.PreservePrefix;
            obj.Xml = p.Xml;
            obj.XmlSchema = p.XmlSchema;
            obj.GroupMap = containers.Map('KeyType', 'char', ...
                'ValueType', 'any');
        end % fieldMap constructor
        
        function addValues(obj, type, values, varargin)
            % Add values (structure or cell format) to tagMap for type
            p = inputParser;
            p.addRequired('Type', @(x) (~isempty(x) && ischar(x)));
            p.addRequired('Values', ...
                @(x) (isempty(x) || isstruct(x) || isa(x, 'tagList')));
            p.addParamValue('Primary', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
            p.addParamValue('UpdateType', 'merge', ...
                @(x) any(validatestring(lower(x), ...
                {'Update', 'Replace', 'Merge', 'None'})));
            p.parse(type, values, varargin{:});
            primary = p.Results.Primary;
            type = p.Results.Type;
            if ~obj.GroupMap.isKey(type)
                eTag = tagMap('Field', type, 'Primary', primary);
            else
                eTag = obj.GroupMap(type);
            end
            if primary
                obj.PrimaryField = type;
            end
            if iscell(values)
                for k = 1:length(values)
                    eTag.addValue(values{k}, ...
                        'UpdateType', p.Results.UpdateType, ...
                        'PreservePrefix', obj.PreservePrefix);
                end
            else
                for k = 1:length(values)
                    eTag.addValue(values(k), ...
                        'UpdateType', p.Results.UpdateType, ...
                        'PreservePrefix', obj.PreservePrefix);
                end
            end
            obj.GroupMap(type) = eTag;
        end % addValues
        
        function newMap = clone(obj)
            % Create a copy (newMap) of the fieldMap
            newMap = fieldMap();
            newMap.Description = obj.Description;
            newMap.PreservePrefix = obj.PreservePrefix;
            newMap.Xml = obj.Xml;
            newMap.XmlSchema = obj.XmlSchema;
            values = obj.GroupMap.values;
            tMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            for k = 1:length(values)
                tMap(values{k}.getField()) = values{k};
            end
            newMap.GroupMap = tMap;
        end % clone
        
        function description = getDescription(obj)
            % Return a string describing the purpose of the fieldMap
            description = obj.Description;
        end % getDescription
        
        function fields = getFields(obj)
            % Return the field names of the fieldMap
            fields = obj.GroupMap.keys();
        end % getFields
        
        function jString = getJson(obj)
            % Return a JSON string version of the fieldMap
            jString = savejson('', obj.getStruct());
        end % getJson
        
        function jString = getJsonValues(obj)
            % Return a JSON string representation of the tag maps
            jString = tagMap.values2Json(obj.GroupMap.values);
        end % getJsonValues
        
        function tMap = getMap(obj, field)
            % Return a tagMap object associated field name
            if ~obj.GroupMap.isKey(field)
                tMap = '';
            else
                tMap = obj.GroupMap(field);
            end
        end % getMap
        
        function tMaps = getMaps(obj)
            % Return the tagMap objects as a cell array
            tMaps = obj.GroupMap.values;
        end % getMaps
        
        function pPrefix = getPreservePrefix(obj)
            % Return the logical PreservePrefix flag of the fieldMap
            pPrefix = obj.PreservePrefix;
        end % getPreservePrefix
        
        function primaryField = getPrimaryField(obj)
            % Return the field names of the fieldMap
            primaryField = obj.PrimaryField;
        end % getFields
        
        function thisStruct = getStruct(obj)
            % Return the fieldMap as a structure array
            thisStruct = struct('description', obj.Description, ...
                'xml', obj.Xml, 'map', '');
            types = obj.GroupMap.keys();
            if isempty(types)
                return;
            end
            events = struct('field', types, 'values', '');
            for k = 1:length(types)
                eTags = obj.GroupMap(types{k});
                events(k).values = eTags.getValueStruct();
            end
            thisStruct.map = events;
        end % getStruct
        
        function tags = getTags(obj, field, value)
            % Return the tag string associated with (field name, value)
            tags = '';
            try
                tMap = obj.GroupMap(field);
                eStruct = tMap.getValue(value);
                tags = eStruct.getTags();
            catch me %#ok<NASGU>
            end
        end % getTags
        
        function value = getValue(obj, type, key)
            % Return value structure for specified type and key
            value = '';
            if obj.GroupMap.isKey(type)
                value = obj.GroupMap(type).getValue(key);
            end
        end % getValue
        
        function values = getValues(obj, type)
            % Return values for type as a cell array of structures
            if obj.GroupMap.isKey(type)
                values = obj.GroupMap(type).getValues();
            else
                values = '';
            end;
        end % getValues
        
        function xml = getXml(obj)
            % Return a string containing the xml of the fieldMap
            xml = obj.Xml;
        end % getXml
        
        function xmlEdited = getXmlEdited(obj)
            % Returns true if the XML was edited through the CTagger
            xmlEdited = obj.XmlEdited;
        end % getXmlEdited
        
        function merge(obj, fMap, updateType, excludeFields, includeFields)
            % Combine this object with the fMap fieldMap
            if isempty(fMap)
                return;
            end
            fields = fMap.getFields();
            fields = setdiff(fields, excludeFields);
            if ~isempty(includeFields)
                fields = intersect(fields, includeFields);
            end
            for k = 1:length(fields)
                type = fields{k};
                tMap = fMap.getMap(type);
                if ~obj.GroupMap.isKey(type)
                    obj.GroupMap(type) = tagMap('Field', type);
                end
                myMap = obj.GroupMap(type);
                myMap.merge(tMap, updateType, obj.PreservePrefix)
                obj.GroupMap(type) = myMap;
            end
        end % merge
        
        function removeMap(obj, field)
            % Remove the tag map associated with specified field name
            if ~isempty(field) && obj.GroupMap.isKey(field)
                obj.GroupMap.remove(field);
            end
        end % removeMap
        
        function setPrimaryMap(obj, field)
            % Sets the tag map associated with specified field name as a
            % primary field
            if ~isempty(field) && obj.GroupMap.isKey(field)
                tMap = getMap(obj, field);
                setPrimary(tMap, true);
                obj.GroupMap.remove(field);
                obj.GroupMap(field) = tMap;
            end
        end % setPrimaryMap
        
        function setDescription(obj, description)
            % Set the description of the fieldMap
            obj.Description = description;
        end % setDescription
        
        function xml = setXml(obj, xml)
            % Set the XML of the fieldMap
            obj.Xml = xml;
        end % setXml
        
        function xmlEdited = setXmlEdited(obj, xmlEdited)
            % Set the XML of the fieldMap
            obj.XmlEdited = xmlEdited;
        end % setXmlEdited
        
    end % public methods
    
    methods (Static = true)
        
        function baseTags = loadFieldMap(tagsFile)
            % Load a fieldMap from a file tagsFile
            baseTags = '';
            try
                t = load(tagsFile);
                tFields = fieldnames(t);
                for k = 1:length(tFields);
                    nextField = t.(tFields{k});
                    if isa(nextField, 'fieldMap')
                        baseTags = nextField;
                        return;
                    end
                end
            catch ME         %#ok<NASGU>
            end
        end % loadFieldMap
        
        function successful = saveFieldMap(tagsFile, ...
                tagsObject) %#ok<INUSD>
            % Save the fieldMap tagsObject in a file tagsFile
            successful = true;
            try
                save(tagsFile, 'tagsObject');
            catch ME         %#ok<NASGU>
                successful = false;
            end
        end % saveFieldMap
        
        function p = parseArguments(varargin)
            % Parses the input arguments and returns the results
            parser = inputParser;
            parser.addParamValue('Description', '', @ischar);
            parser.addParamValue('PreservePrefix', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
            parser.addParamValue('Xml', fileread(fieldMap.DefaultXml), ...
                @(x) (ischar(x)));
            parser.addParamValue('XmlSchema', ...
                fileread(fieldMap.DefaultSchema), @ischar);
            parser.parse(varargin{:})
            p = parser.Results;
        end % parseArguments
        
    end % static methods
    
end % fieldMap