% This function takes in a wiki text file containing all of the HED tags,
% their attributes, and unit classes and creates a HED XML file. Each tag
% will be converted into an XML node contained in the HED XML file.
%
% Usage:
%
%   >>  xmlDoc = wiki2xml(wikiFile)
%
%   >>  xmlDoc = wiki2xml(wikiFile, varargin)
%
% Input:
%
%   wikiFile        The name or the path of the wiki text file containing
%                   all of the HED tags. Each tag and unit class in this
%                   file will be converted into an XML node in the
%                   HED XML file that is generated from this function.
%
%   Optional (key/value):
%
%   'outputFile'
%                   The name or the path to the HED XML output file
%                   that the HED tags in the 'wiki' text file are written
%                   to. If not specified then the output file path will be
%                   the same as the 'wiki' file path with .xml as its file
%                   extension.
%
% Output:
%
%   xmlDoc
%                   Returns a handle to the newly created XML document
%                   object. This XML document object can be converted to
%                   a string, saved to another file, and traversed through
%                   to access each element (tags in this case).
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

function xmlDoc = wiki2xml(wikiFile, varargin)
p = parseArguments();
attributeUnits = '';
hedLines = false;
nodeStruct = struct;
tLine = '';
unitClassElement = [];
unitClassesElement = [];
unitClassUnits = '';
xmlDoc = com.mathworks.xml.XMLUtils.createDocument('HED');
hedElement = xmlDoc.getDocumentElement;
try
    readLines();
    writeDocumentObjectModel();
    fclose(fid);
catch me
    if fid > -1
        fclose(fid);
    end
    rethrow(me);
end

    function addLastElements()
        % Appends the last node element, unitClass element, and unitClasses
        % element to the HED root node
        hedElement.appendChild(nodeStruct.level_0);
        createUnitClassUnitsElement();
        hedElement.appendChild(unitClassesElement);
    end % addLastElements

    function buildUnitClassUnits()
        % Builds a comma separated list of units associated with a
        % unitClass element
        unitsExpression = '[^*]+(\S+(\s*,?)+)+';
        units = strtrim(regexpi(tLine, unitsExpression, 'match'));
        unitClassUnits = [unitClassUnits, ',' units{1}];
    end % buildUnitClassUnits

    function checkHEDVersion()
        % Checks the line for HED version attribute
        versionexpression = '(?<=HED version:\s*)\d+(.\d+)*';
        version = strtrim(regexpi(tLine, versionexpression, 'match'));
        if ~isempty(version)
            hedElement.setAttribute('version',version{1});
        end
    end % checkHEDVersion

    function isFirstLastLine = checkLineType()
        % Checks if the line contains the HED version, is the start or end
        % of the HED document
        checkHEDVersion();
        isFirstLastLine = false;
        if isFirstLine()
            isFirstLastLine = true;
            hedLines = true;
        elseif isLastLine()
            isFirstLastLine = true;
            hedLines = false;
        end
    end % checkLineType

    function createChildNodeElement(nodeElement)
        % Creates a new child node element in the XML document
        deepestLevel = length(fieldnames(nodeStruct));
        numAsterisks = length(find(tLine=='*'));
        if ~isfield(nodeStruct, ['level_',numAsterisks]) || ...
                (numAsterisks == deepestLevel)
            nodeStruct.(['level_', num2str(numAsterisks)]) = nodeElement;
        end
        nodeStruct.(['level_', ...
            num2str(numAsterisks-1)]).appendChild(nodeElement);
    end % createChildNode

    function nodeElement = createDescriptionElement(nodeElement)
        % Creates a description element if the description exists for the
        % node element
        description = getDescription();
        if ~isempty(description)
            descriptionElement = xmlDoc.createElement('description');
            descriptionElement.appendChild(...
                xmlDoc.createTextNode(description));
            nodeElement.appendChild(descriptionElement);
        end
    end % createDescriptionElement

    function createNodeElement()
        % Creates a new node element in the XML document
        nameElement = createNodeNameElement();
        nodeElement = xmlDoc.createElement('node');
        nodeElement.appendChild(nameElement);
        nodeElement = createElementAttributes(nodeElement);
        nodeElement = createDescriptionElement(nodeElement);
        childExpresson = '^\*+';
        if isempty(regexpi(tLine, childExpresson, 'once'))
            createRootNodeElement(nodeElement);
        else
            createChildNodeElement(nodeElement)
        end
    end % createNodeElement

    function nameElement = createNodeNameElement()
        % Creates a new node name element in the XML document
        nameExpression = '([<>=#\-a-zA-Z0-9$:]+\s*)+';
        name = strtrim(regexpi(tLine, nameExpression, 'match'));
        nameElement = xmlDoc.createElement('name');
        nameElement.appendChild(xmlDoc.createTextNode(name{1}));
    end % createNodeNameElement

    function createRootNodeElement(nodeElement)
        % Creates a new root node element and appends the previous one to
        % the HED element if it exist
        if ~isempty(fieldnames(nodeStruct))
            hedElement.appendChild(nodeStruct.level_0);
        end
        nodeStruct = struct;
        nodeStruct.level_0 = nodeElement;
    end % createRootNodeElement

    function createUnitClassElement()
        % Creates a unitClass element in the XML document
        numAsterisks = length(find(tLine=='*'));
        if numAsterisks == 1
            if ~isempty(unitClassElement)
                createUnitClassUnitsElement();
            end
            nameElement = createUnitClassNameElement();
            unitClassElement = xmlDoc.createElement('unitClass');
            unitClassElement.appendChild(nameElement);
            unitClassElement = createElementAttributes(unitClassElement);
        else
            buildUnitClassUnits();
        end
    end % createUnitClassElement

    function createUnitClassesElement()
        % Creates a unitClasses element in the XML document
        unitClassesElement = xmlDoc.createElement('unitClasses');
    end % createUnitClassesElement

    function nameElement = createUnitClassNameElement()
        % Creates a unitClass name element in the XML document
        nameExpression = '(\w+\s*-?\s*)*(\s*\((\w+\s*-?\s*)*\))?(\#)?';
        name = strtrim(regexpi(tLine, nameExpression, 'match'));
        nameElement = xmlDoc.createElement('name');
        nameElement.appendChild(xmlDoc.createTextNode(name{1}));
    end % createUnitClassNameElement

    function createUnitClassUnitsElement()
        % Creates a units element, appends it to the unitClass element, and
        % appends the unitClass element to the unitClasses element in
        % the XML document
        unitClassUnits = regexprep(unitClassUnits, '^,', '');
        unitsElement = xmlDoc.createElement('units');
        unitsElement.appendChild(xmlDoc.createTextNode(unitClassUnits));
        unitClassElement.appendChild(unitsElement);
        unitClassesElement.appendChild(unitClassElement);
        unitClassUnits = '';
        unitClassElement = [];
    end % createUnitClassUnitsElement

    function formatLine()
        % Formats the current line by removing white space and wiki
        % portions of the line
        tLine = strtrim(tLine);
        tLine = regexprep(tLine,'</?nowiki>','');
    end % formatLine

    function attributes = getAttributes()
        % Gets the attributes from the line if they exists which are
        % enclosed in {} braces
        attributesExpression = '\{.*\}';
        individualAttributeExpression = '\w+(=?\$?\w*-?\w*-?)*';
        attributes = [];
        attributesMatch = regexpi(tLine, attributesExpression, 'match');
        if ~isempty(attributesMatch)
            attributesMatch{1} = ...
                strtrim(regexprep(attributesMatch{1},'[{}]',''));
            attributes = strtrim(regexpi(attributesMatch{1}, ...
                individualAttributeExpression, 'match'));
            tLine = regexprep(tLine, attributesExpression, '');
        end
    end % getAttributes

    function description = getDescription()
        % Gets the description from the line if it exists which is eclosed
        % in [] braces
        descriptionExpression = '\[.*\]';
        description = [];
        descriptionMatch = regexpi(tLine, descriptionExpression, 'match');
        if ~isempty(descriptionMatch)
            description = ...
                strtrim(regexprep(descriptionMatch{1},'[\[\]]',''));
            tLine = regexprep(tLine, descriptionExpression, '');
        end
    end % getDescription

    function firstLine = isFirstLine()
        % Checks if the line is the first line the HED document which
        % contains !# start hed
        startExpression = '^(!# start hed|<!-- start hed -->)$';
        firstLine = ~isempty(regexpi(tLine,startExpression, 'once'));
    end % isFirstLine

    function lastLine = isLastLine()
        % Checks if the line is the last line the HED document which
        % contains !# end hed
        endExpression = '^(!# end hed|<!-- end hed -->)$';
        lastLine = ~isempty(regexpi(tLine,endExpression, 'once'));
    end % isLastLine

    function hedTagLine = isHedTagLine()
        % Checks if the line contains a HED tag and isn't a comment or
        % extend here line
        commentExpression = '\[\w+\d+\]';
        extendExpression = '.*\[Extend here\]';
        isCommentLine = ~isempty(regexpi(tLine,commentExpression, 'once'));
        isExtendLine = ~isempty(regexpi(tLine,extendExpression, 'once'));
        hedTagLine = ~isempty(tLine) && ~isCommentLine && ~isExtendLine ...
            && hedLines;
    end % isHedTagLine

    function unitClassLine = isUnitClassLine()
        % Checks if the line is a unitClass element
        unitClassLine = ~isempty(tLine) && ~isempty(unitClassesElement) ...
            && hedLines;
    end % isUnitClassLine

    function unitClassesLine = isUnitClassesLine()
        % Checks if the line is the start of the unitClasses elements
        unitClassExpression = 'Unit Classes';
        unitClassesLine = ...
            ~isempty(regexpi(tLine,unitClassExpression, 'once'));
    end % isUnitClassesLine

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('wikiFile', @(x) ~isempty(x) && ischar(x));
        [path, file] = fileparts(wikiFile);
        p.addOptional('outputFile', fullfile(path, [file '.xml']), ...
            @(x) ~isempty(x) && ischar(x));
        p.parse(wikiFile, varargin{:});
        p = p.Results;
    end % parseArguments

    function parseLine()
        % Parses the current line in the wiki text file
        formatLine();
        isFirstLastLine = checkLineType();
        if ~isFirstLastLine
            if isUnitClassesLine()
                createUnitClassesElement();
            elseif isUnitClassLine()
                createUnitClassElement();
            elseif isHedTagLine()
                createNodeElement();
            end
        end
    end % parseLine

    function readLines()
        % Read each line and parse it to be added to a document object
        % model
        fid = fopen(wikiFile, 'r', 'n', 'UTF-8');
        tLine = fgetl(fid);
        while ischar(tLine)
            parseLine();
            tLine = fgetl(fid);
        end
        addLastElements();
    end % readLines

    function element = createElementAttributes(element)
        % Creates the attributes for an element if they exists
        attributes = getAttributes();
        if ~isempty(attributes)
            nameValueExpression = '(?<=\w+=)(\$?\w*-?\w*-?)*';
            for a = 1:length(attributes)
                if isempty(regexpi(attributes{a}, nameValueExpression, ...
                        'match'));
                    setBooleanAttribute(element, attributes, a);
                else
                    setNonBooleanAttribute(element, attributes, a);
                end
            end
            if ~isempty(attributeUnits)
                setUnitClassAttribute(element);
            end
        end
    end % createElementAttributes

    function setBooleanAttribute(nodeElement, attributes, index)
        % Sets the boolean attribute of an element to true
        nodeElement.setAttribute(attributes{index}, 'true');
    end % setBooleanAttribute

    function setNonBooleanAttribute(nodeElement, attributes, index)
        % Sets the non-boolean attribute of an element
        nameValueattribute = strsplit(attributes{index}, '=');
        attributeName = strtrim(nameValueattribute{1});
        attributeValue = strtrim(nameValueattribute{2});
        if strcmpi(attributeName, 'unitClass')
            attributeUnits = [attributeUnits, ',', attributeValue];
        else
            nodeElement.setAttribute(attributeName, attributeValue);
        end
    end % setNonBooleanAttribute

    function setUnitClassAttribute(nodeElement)
        % Sets the unitClass attribute for the node element
        attributeUnits = regexprep(attributeUnits, '^,', '');
        nodeElement.setAttribute('unitClass', attributeUnits);
        attributeUnits = '';
    end % setUnitClassAttribute

    function writeDocumentObjectModel()
        % Writes the document object model to a XML file
        xmlwrite(p.outputFile, xmlDoc);
    end % writeDocumentObjectModel

end % wiki2xml