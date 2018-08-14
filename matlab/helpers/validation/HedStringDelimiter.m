% Splits up the tags in a HED string and returns diffferent types of tags.
%
% Usage:
%
%   >>  [tags, topLevelTags, groupTags, uniqueTags] = ...
%       hedStringDelimiter(hedString)
%
% Input:
%
%   Required:
%
%   hedString
%                    A HED string.
%
%   (Optional):
%
%   hedString
%                    A HED string.
%
%
% Output:
%
%   tags
%                    A cell array containing all the tags in the HED
%                    string.
%
%   topLevelTags
%                    A cell array containing all the top-level tags in the
%                    HED string.
%
%   groupTags
%                    A cell array containing all the group tags in the
%                    HED string.
%
%   uniqueTags
%                    A cell array containing all the unique tags in the
%                    HED string.
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

classdef HedStringDelimiter
    
    properties(Access=private)
        tags;
        topLevelTags;
        groupTags;
        uniqueTags;
        formattedTags;
        formattedTopLevelTags;
        formattedGroupTags;
        formattedUniqueTags;
    end % Private properties
    
    properties(Constant)
        openingBracket = '(';
        closingBracket = ')';
        comma = ',';
        tilde = '~';
        delimiters = {'(', ','};
    end % Constant properties
    
    methods
        
        function obj = HedStringDelimiter(hedString)
            % HedStringDelimiter constructor
            %             obj.tags = hed2cell(hedString, true);
            obj.tags = HedStringDelimiter.hedString2Cell(hedString);
            obj.topLevelTags = obj.tags(cellfun(@ischar, obj.tags));
            obj.groupTags = obj.findGroupTags({}, obj.tags);
            obj.uniqueTags = obj.findUniqueTags(obj.tags);
            obj.formattedTags = ...
                HedStringDelimiter.putInCanonicalForm(obj.tags);
            obj.formattedTopLevelTags = ...
                HedStringDelimiter.putInCanonicalForm(obj.topLevelTags);
            obj.formattedGroupTags = ...
                HedStringDelimiter.putInCanonicalForm(obj.groupTags);
            obj.formattedUniqueTags = ...
                HedStringDelimiter.putInCanonicalForm(obj.uniqueTags);
        end % HedStringDelimiter
        
        function tags = getTags(obj)
            % Gets the tags
            tags = obj.tags;
        end % getTags
        
        function topLevelTags = getTopLevelTags(obj)
            % Gets the top-level tags
            topLevelTags = obj.topLevelTags;
        end % getTopLevelTags
        
        function groupTags = getGroupTags(obj)
            % Gets the group tags
            groupTags = obj.groupTags;
        end % groupTags
        
        function uniqueTags = getUniqueTags(obj)
            % Gets the unique tags
            uniqueTags = obj.uniqueTags;
        end % getUniqueTags
        
        
        function formattedTags = getFormattedTags(obj)
            % Gets the formatted tags
            formattedTags = obj.formattedTags;
        end % getFormattedTags
        
        function formattedTopLevelTags = getFormattedTopLevelTags(obj)
            % Gets the formatted top-level tags
            formattedTopLevelTags = obj.formattedTopLevelTags;
        end % getFormattedTopLevelTags
        
        function formattedGroupTags = getFormattedGroupTags(obj)
            % Gets the formatted group tags
            formattedGroupTags = obj.formattedGroupTags;
        end % getFormattedGroupTags
        
        function formattedUniqueTags = getFormattedUniqueTags(obj)
            % Gets the formattted unique tags
            formattedUniqueTags = obj.formattedUniqueTags;
        end % getFormattedUniqueTags
        
    end % Public methods
    
    methods(Access=private)
        
        
        function uniqueTags = findUniqueTags(obj, tags)
            % Finds all unique tags in a cell array
            [uniqueTags, nestedCellsPresent] = obj.unnestGroupTags(tags);
            while nestedCellsPresent
                [uniqueTags, nestedCellsPresent] = ...
                    unNestGroupTags(uniqueTags);
            end
            uniqueTags = unique(uniqueTags);
            uniqueTags = ...
                HedStringDelimiter.removedTildesFromGroup(uniqueTags);
        end % findUniqueTags
        
        function groups = findGroupTags(obj, groups, tags)
            % Finds all tag groups in cell array
            numTags = length(tags);
            for tagIndex = 1:numTags
                if iscellstr(tags{tagIndex})
                    groups{end+1} = tags{tagIndex}; %#ok<AGROW>
                elseif iscell(tags{tagIndex})
                    groups{end+1} = tags{tagIndex}; %#ok<AGROW>
                    groups = getGroupTags(groups, tags{tagIndex});
                end
            end
        end % getAllGroups
        
        function [tags, nestedCellsPresent] = unnestGroupTags(obj, tags)
            % Unest group tags in cell array
            if ~iscellstr(tags)
                tags = [tags{:}];
            end
            nestedCellsPresent = ~iscellstr(tags);
        end % unNestGroupTags
        
    end % Private methods
    
    methods(Static)
        
        function group = removedTildesFromGroup(group)
            % Removes tildes from a group.
            group = group(~cellfun(@(x) strcmp(x, '~'), group));
        end % removedTildesFromGroup
        
        function cellArray = hedString2Cell(hedString)
            % Converts a HED string into a cell array. Groups will be
            % nested cells.
            cellArray = {};
            isValid = HedStringDelimiter.hedStringIsValid(hedString);
            if isValid
                iterableAttributes = ...
                    HedStringDelimiter.createHedStringIterableAttributes(...
                    hedString);
                [cellArray, iterableAttributes] = ...
                    HedStringDelimiter.parseHedStringCharByChar(...
                    hedString, cellArray, iterableAttributes);
                cellArray = HedStringDelimiter.addLastHedStringTag(...
                    cellArray, iterableAttributes);
                groupIndices = find(cellfun(@(x) ...
                    HedStringDelimiter.hedStringIsGroup(x), cellArray));
                numGroupIndices = length(groupIndices);
                for a = 1:numGroupIndices
                    cellArray{groupIndices(a)} = ...
                        HedStringDelimiter.removeOuterGroupBrackets(...
                        cellArray{groupIndices(a)});
                    cellArray{groupIndices(a)} = ...
                        HedStringDelimiter.hedString2Cell(...
                        cellArray{groupIndices(a)});
                end
            else
                warning(['HED string is invalid. Check the number' ...
                    ' of parentheses.']); 
            end
        end % hedString2Cell
        
        function cellArray = hedString2FormattedCell(hedString)
            % Converts a HED string into a formatted cell array. Groups
            % will be nested cells.
            cellArray = HedStringDelimiter.hedString2Cell(hedString);
            cellArray = HedStringDelimiter.putInCanonicalForm(cellArray);
        end % hedString2Cell
        
    end % Static public methods
    
    
    methods(Static, Access=private)
        
        
        function tags = putInCanonicalForm(tags)
            % Removes slashes and double quotes
            numTags = length(tags);
            for a = 1:numTags
                if iscell(tags{a})
                    tags{a} = ...
                        HedStringDelimiter.putInCanonicalForm(tags{a});
                else
                    tags{a} = HedStringDelimiter.formatTag(tags{a});
                end
            end
        end % putInCanonicalForm
        
        function tag = formatTag(tag)
            % Formats the tag by converting it to lower case, removing
            % slashes in the beginning and end, and trimming space.
            tag = strtrim(tag);
            tag = lower(tag);
            if strcmp(tag(1), '/')
                tag = tag(2:end);
            end
            if strcmp(tag(end), '/')
                tag = tag(1:end-1);
            end
        end % formatTag
        
        function removeEmptyTags(tags)
            % Removes the empty tags in a HED string
            tags = tags(~cellfun(@isempty, tags));
            groupIndicies = find(~cellfun(@ischar, tags));
            numGroupIndices = length(groupIndicies);
            for a = 1:numGroupIndices
                tags{a} = removeEmptyTags(tags{a});
            end
        end % removeEmptyTags
        
        function isValid = hedStringIsValid(hedString)
            % Checks if HED string is valid by looking at the number of
            % opening and closing brackets
            numOpeningBrackets = length(strfind(hedString, '('));
            numClosingBrackets = length(strfind(hedString, ')'));
            isValid = numOpeningBrackets == numClosingBrackets;
        end % hedStringIsValid
        function hedString = removeOuterGroupBrackets(hedString)
            % Removes the outer group brackets in a HED string.
            hedString = hedString(2:end-1);
        end % removeOuterGroupBrackets
        
        function isGroup = hedStringIsGroup(hedString)
            % Returns true if the HED string is a group. False, if
            % otherwise.
            isGroup = hedString(1) == ...
                HedStringDelimiter.openingBracket && ...
                hedString(end) ==  HedStringDelimiter.closingBracket;
        end % hedStringIsGroup
        
        function cellArray = addLastHedStringTag(cellArray, ...
                iterableAttributes)
            % Add the last HED string tag to a cell array.
            if ~isempty(strtrim(iterableAttributes.charSequence)) && ...
                    ~all(ismember(HedStringDelimiter.delimiters, ...
                    iterableAttributes.charSequence))
                cellArray{iterableAttributes.cellIndex} = ...
                    strtrim(iterableAttributes.charSequence);
            end
        end % addLastHedStringTag
        
        function [cellArray, iterableAttributes] = ...
                parseHedStringCharByChar(hedString, cellArray, ...
                iterableAttributes)
            % Parses a HED string character by character.
            while(HedStringDelimiter.hedStringIndexLessThanEqualLength(...
                    iterableAttributes))
                currentChar = hedString(iterableAttributes.sequenceIndex);
                iterableAttributes.charSequence = ...
                    [iterableAttributes.charSequence currentChar];
                if HedStringDelimiter.charIsOpeningBracket(currentChar)
                    [cellArray, iterableAttributes] = ...
                        HedStringDelimiter.addHedStringGroup(hedString, ...
                        cellArray, iterableAttributes);
                elseif HedStringDelimiter.charIsTilde(currentChar)
                    [cellArray, iterableAttributes] = ...
                        HedStringDelimiter.addHedStringTag(cellArray, ...
                        iterableAttributes);
                    [cellArray, iterableAttributes] = ...
                        HedStringDelimiter.addHedStringTilde(cellArray, ...
                        iterableAttributes);
                elseif HedStringDelimiter.charIsComma(currentChar) || ...
                        HedStringDelimiter.charIsClosingBracket(currentChar)
                    [cellArray, iterableAttributes] = ...
                        HedStringDelimiter.addHedStringTag(cellArray, ...
                        iterableAttributes);
                else
                    iterableAttributes.sequenceIndex = ...
                        iterableAttributes.sequenceIndex +1;
                end
            end
        end % iterateThroughHedString
        
        function lessThanEqual = hedStringIndexLessThanEqualLength(...
                iterableAttributes)
            % Checks to see if the index is less than or equal to the
            % length of the HED string.
            lessThanEqual = iterableAttributes.sequenceIndex <= ...
                iterableAttributes.numChars;
        end % hedStringIndexLessThanEqualLength
        
        function iterableAttributes = ...
                createHedStringIterableAttributes(hedString)
            % Creates HED string iterable attributes. Attributes keep track
            % of the current sequence, sequence index, cell array index,
            % and the number of characters in the HED string.
            iterableAttributes = struct();
            iterableAttributes.sequenceIndex = 1;
            iterableAttributes.numChars = length(hedString);
            iterableAttributes.cellIndex = 1;
            iterableAttributes.charSequence = '';
        end % createHedStringIterableAttributes
        
        function [cellArray, iterableAttributes] = ...
                addHedStringTilde(cellArray, iterableAttributes)
            % Adds a HED string tilde to a cell array.
            cellArray{iterableAttributes.cellIndex} = ...
                HedStringDelimiter.tilde;
            iterableAttributes.cellIndex = iterableAttributes.cellIndex + 1;
        end % addHedStringTilde
        
        function [cellArray, iterableAttributes] = ...
                addHedStringTag(cellArray, iterableAttributes)
            % Adds a HED string tilde to a cell array.
            charSequence = strtrim(strrep(...
                iterableAttributes.charSequence, ...
                HedStringDelimiter.comma, ''));
            charSequence = strtrim(strrep(...
                charSequence, ...
                HedStringDelimiter.tilde, ''));
            charSequence = strtrim(strrep(...
                charSequence, ...
                HedStringDelimiter.closingBracket, ''));
            if ~isempty(charSequence)
                cellArray{iterableAttributes.cellIndex} = charSequence;
                iterableAttributes.cellIndex = ...
                    iterableAttributes.cellIndex + 1;
            end
            iterableAttributes.charSequence = '';
            iterableAttributes.sequenceIndex = ...
                iterableAttributes.sequenceIndex +1;
        end % addHedStringTag
        
        function [cellArray, iterableAttributes] = ...
                addHedStringGroup(hedString, cellArray, iterableAttributes)
            % Adds a HED string group to a cell array.
            charSequence = strtrim(strrep(...
                iterableAttributes.charSequence, ...
                HedStringDelimiter.openingBracket, ''));
            if ~isempty(charSequence)
                cellArray{iterableAttributes.cellIndex} = ...
                    strtrim(charSequence);
                iterableAttributes.cellIndex = ...
                    iterableAttributes.cellIndex + 1;
            end
            groupString = hedString(iterableAttributes.sequenceIndex:end);
            [cellArray{iterableAttributes.cellIndex}, offset] = ...
                HedStringDelimiter.getNextTagGroup(groupString);
            iterableAttributes.sequenceIndex = ...
                iterableAttributes.sequenceIndex + offset-1;
            iterableAttributes.charSequence = '';
            iterableAttributes.cellIndex = iterableAttributes.cellIndex ...
                + 1;
        end % addHedStringGroup
        
        function isOpening = charIsOpeningBracket(character)
            % Checks to see if the character is an opening bracket.
            isOpening = character == HedStringDelimiter.openingBracket;
        end % charIsOpeningBracket
        
        function isClosing = charIsClosingBracket(character)
            % Checks to see if the character is an closing bracket.
            isClosing = character == HedStringDelimiter.closingBracket;
        end % charIsClosingBracket
        
        function isOpening = charIsTilde(character)
            % Checks to see if the character is a tilde
            isOpening = character == HedStringDelimiter.tilde;
        end % charIsTilde
        
        
        function isOpening = charIsComma(character)
            % Checks to see if the character is a comma
            isOpening = character == HedStringDelimiter.comma;
        end % charIsComma
        
        function [group, index] = getNextTagGroup(hedString)
            % Gets the next group in the HED string. Also returns the index
            % after the group.
            group = '';
            numChars = length(hedString);
            numOpeningBrackets = 0;
            numClosingBrackets = 0;
            for index = 1:numChars
                if numOpeningBrackets > 0 && numClosingBrackets > 0 ...
                        && numOpeningBrackets == numClosingBrackets
                    return;
                end
                if hedString(index) == HedStringDelimiter.openingBracket
                    numOpeningBrackets =  numOpeningBrackets + 1;
                end
                if hedString(index) == HedStringDelimiter.closingBracket
                    numClosingBrackets =  numClosingBrackets + 1;
                end
                group = [group hedString(index)]; %#ok<AGROW>
            end
        end % getNextTagGroup
        
    end % Static private methods
    
end % HedStringDelimiter