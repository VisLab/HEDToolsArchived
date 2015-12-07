% This function parses a HED XML file and stores the tags, attributes, and
% unit classes in a structure of Map objects.
%
% Usage:
%   >>  Maps = parsehed(xml)
%
% Input:
%       'hed'       The name or the path to the HED XML file containing all
%                   of the tags.
%       Optional:
%       'Maps'      A structure that contains all of the Map objects
%                   created from the HED tags, attributes, and unit
%                   classes.
%
% Examples:
%                   Parses a HED XML file 'HED2.026.xml' and returns a
%                   structure of Map objects 'Maps' that contain all of the
%                   tags,attributes and unit classes.
%
%                   Maps = parsehed('HED2.026.xml')
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
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

function Maps = parsehed(hed)
try
    xDoc = xmlread(hed);
catch
    error('Failed to read XML file %s.',hed);
end
HEDDoc = xDoc.getElementsByTagName('HED');
HEDElement = HEDDoc.item(0);
Maps = initializeMaps();
processNodeElements(HEDElement, '/');

    function addNodeAttributeToMaps(nodePath, attributeName, ...
            attributeValue)
        % Adds the node attributes to the maps
        if strcmpi('true', attributeValue) || ...
                any(strcmpi({'default','unitClass'}, attributeName))
            switch(attributeName)
                case 'default'
                    Maps.default(lower(nodePath)) = attributeValue;
                case 'extensionAllowed'
                    Maps.extensionAllowed(lower(nodePath)) = nodePath;
                case 'isNumeric'
                    Maps.isNumeric(lower(nodePath)) = nodePath;
                case 'requireChild'
                    Maps.requireChild(lower(nodePath)) = nodePath;
                case 'required'
                    Maps.required(lower(nodePath)) = nodePath;
                case 'takesValue'
                    Maps.takesValue(lower(nodePath)) = nodePath;
                case 'unique'
                    Maps.unique(lower(nodePath)) = nodePath;
                case 'unitClass'
                    Maps.unitClass(lower(nodePath)) = attributeValue;
            end
        end
    end % addNodeAttributeToMaps

    function Maps = initializeMaps()
        % Initializes all of the maps containing the tags and attributes
        Maps = struct();
        Maps.default = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        Maps.extensionAllowed = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        Maps.isNumeric = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        Maps.requireChild = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        Maps.required = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        Maps.tags = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        Maps.takesValue = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        Maps.unique = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        Maps.unitClass = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
        Maps.unitClasses = ...
            containers.Map('KeyType', 'char', 'ValueType', 'any');
    end % initializeMaps

    function processAttributes(childElement, nodePath)
        % Processes the node attributes in the HED
        theAttributes = childElement.getAttributes;
        numAttributes = theAttributes.getLength;
        for count = 1:numAttributes
            attribute = theAttributes.item(count-1);
            attributeName = strtrim(char(attribute.getName));
            attributeValue = strtrim(char(attribute.getValue));
            addNodeAttributeToMaps(nodePath, attributeName, ...
                attributeValue);
        end
    end % processAttributes

    function processNodeElements(parentElement, parentPath)
        % Processes the all node elements in the HED XML file
        childNodes = parentElement.getChildNodes;
        numChildNodes = childNodes.getLength;
        for nodecount = 1:numChildNodes
            childElement = childNodes.item(nodecount-1);
            if ~isempty(childElement) && ...
                    strcmpi('node', char(childElement.getNodeName()))
                nodeNameDoc = childElement.getElementsByTagName('name');
                nodeNameElement = nodeNameDoc.item(0);
                nodeName = strtrim(char(...
                    nodeNameElement.getFirstChild.getData));
                nodePath = [parentPath,nodeName];
                Maps.tags(lower(nodePath)) = nodePath;
                processAttributes(childElement, nodePath);
                processNodeElements(childElement, [nodePath,'/']);
            elseif ~isempty(childElement) && strcmpi('unitClasses', ...
                    char(childElement.getNodeName()))
                processUnitClassElements(childElement);
            end
        end
    end % processNodeElements

    function processUnitClassElements(childElement)
        % Processes the unit class elements in the HED XML file
        unitClassesChildNodes = childElement.getChildNodes;
        numUnitClassNodes = unitClassesChildNodes.getLength;
        for unitClassCount = 1:numUnitClassNodes
            unitClassElement = ...
                unitClassesChildNodes.item(unitClassCount-1);
            if ~isempty(unitClassElement) && strcmpi('unitClass', ...
                    char(unitClassElement.getNodeName()))
                unitClassNameDoc = ...
                    unitClassElement.getElementsByTagName('name');
                unitClassNameElement = unitClassNameDoc.item(0);
                unitClassName = strtrim(char(...
                    unitClassNameElement.getFirstChild.getData));
                unitsDoc = unitClassElement.getElementsByTagName('units');
                unitsElement = unitsDoc.item(0);
                units = strtrim(char(unitsElement.getFirstChild.getData));
                processAttributes(unitClassElement, unitClassName);
                Maps.unitClasses(lower(unitClassName)) = units;
            end
        end
    end % processUnitClassElements

end % parsehed