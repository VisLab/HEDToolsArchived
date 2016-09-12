% This function parses a HED XML file and stores the tags, attributes, and
% unit classes in a structure of Map objects.
%
% Usage:
%
%   >>  hedMaps = mapattributes(hedXML)
%
% Input:
%
%       hedXML
%                   The name or the path of the HED XML file containing
%                   all of the tags.
% Output:
%
%       hedMaps
%                   A structure that contains Maps associated with the HED
%                   XML tags. There is a map that contains all of the HED
%                   tags, a map that contains all of the unit class units,
%                   a map that contains the tags that take in units, a map
%                   that contains the default unit used for each unit
%                   class, a map that contains the tags that take in
%                   values, a map that contains the tags that are numeric,
%                   a map that contains the required tags, a map that
%                   contains the tags that require children, a map that
%                   contains the tags that are extension allowed, and map
%                   that contains the tags are are unique.
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

function hedMaps = mapattributes(hedXML)
try
    xDoc = xmlread(hedXML);
catch
    error('Failed to read XML file %s.',hedXML);
end
rootElement = xDoc.getDocumentElement();
hedMaps = initializeMaps();
hedMaps.version = strtrim(char(rootElement.getAttribute('version')));
processNodeElements(rootElement, '');

    function addNodeAttributeToMaps(nodePath, attributeName, ...
            attributeValue)
        % Adds the node attributes to the maps
        if strcmpi('true', attributeValue) || ...
                any(strcmpi({'default','unitClass'}, attributeName))
            switch(attributeName)
                case 'default'
                    hedMaps.default(nodePath) = attributeValue;
                case 'extensionAllowed'
                    hedMaps.extensionAllowed(nodePath) = nodePath;
                case 'isNumeric'
                    hedMaps.isNumeric(nodePath) = nodePath;
                case 'requireChild'
                    hedMaps.requireChild(nodePath) = nodePath;
                case 'required'
                    hedMaps.required(nodePath) = nodePath;
                case 'takesValue'
                    hedMaps.takesValue(nodePath) = nodePath;
                case 'unique'
                    hedMaps.unique(nodePath) = nodePath;
                case 'unitClass'
                    hedMaps.unitClass(nodePath) = attributeValue;
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
            addNodeAttributeToMaps(lower(nodePath), attributeName, ...
                attributeValue);
        end
    end % processAttributes

    function processNodeElements(parentElement, parentPath)
        % Processes the all node elements in the HED XML file
        childNodes = parentElement.getChildNodes();
        numChildNodes = childNodes.getLength();
        nodesFound = false;
        for nodecount = 1:numChildNodes
            childElement = childNodes.item(nodecount-1);
            if ~isempty(childElement) && ...
                    strcmpi('node', char(childElement.getNodeName()))
                nodesFound = true;
                nodeNameDoc = childElement.getElementsByTagName('name');
                nodeNameElement = nodeNameDoc.item(0);
                nodeName = ...
                    strtrim(char(nodeNameElement.getFirstChild.getData));
                nodePath = [parentPath,nodeName];
                hedMaps.tags(lower(nodePath)) = nodePath;
                processAttributes(childElement, nodePath);
                processNodeElements(childElement, [nodePath,'/']);
            elseif ~isempty(childElement) && strcmpi('unitClasses', ...
                    char(childElement.getNodeName()))
                processUnitClassElements(childElement);
            end
        end
        if ~nodesFound
            parentPath = parentPath(1:end-1);
            hedMaps.extensionAllowed(lower(parentPath)) = parentPath;
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
                hedMaps.unitClasses(lower(unitClassName)) = units;
            end
        end
    end % processUnitClassElements

end % mapattributes