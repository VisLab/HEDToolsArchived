% This class contains the interface that does the actual validation and
% return any issues found.
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
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

classdef TagValidator
    
    properties
        hedMaps
    end
    
    properties(Constant, Access=private)
        capWarnings = 'cap';
        capExpression = '^[a-z]|/[a-z]|[^|]\s+[A-Z]';
        commaError = 'comma';
        groupBracketError = 'bracket';
        requireChildError = 'requireChild';
        requiredError = 'required';
    end % Instance properties
    
    methods
        
        function obj = TagValidator(hedMaps)
            % Constructor
            obj.hedMaps = hedMaps;
        end % TagValidator
        
        function hedMaps = getHedMaps(obj)
            hedMaps = obj.hedMaps;
        end
        
        function warnings = checkCaps(obj, originalTag)
            % Returns true if the tag isn't correctly capitalized
            warnings = '';
            if checkIfParentTagTakesValue(obj, originalTag)
                return;
            elseif invalidCapsFoundInTag(obj, originalTag)
                warnings = warningReporter(obj.capWarnings, 'tag', ...
                    originalTag);
            end
        end % runHedStringValidator
        
        function errors = checkCommas(obj, hedString)
            errors = '';
            currentTag = '';
            lastNonEmptyCharacter = '';
            hedStringLength = length(hedString);
            characterIndex = 1;
            while characterIndex < hedStringLength
                character = hedString(characterIndex);
                currentTag = [currentTag character]; %#ok<AGROW>
                if ~TagValidator.characterIsWhitespace(character)
                    if TagValidator.characterIsDelimiter(character)
                        currentTag = '';
                    end
                    if  character == '(' && ...
                            obj.isValidTagWithParentheses(...
                            hedString, currentTag, characterIndex)
                        characterIndex = ...
                            obj.getIndexAtEndOfParentheses(...
                            hedString, currentTag, characterIndex);
                        currentTag = '';
                    elseif obj.commaMissingBeforeOpeningBracket(...
                            lastNonEmptyCharacter, character)
                        currentTag = strtrim(currentTag(1:end-1));
                        errors = errorReporter(obj.commaError, 'tag', ...
                            currentTag);
                        break;
                    elseif obj.commaIsMissingAfterClosingBracket(...
                            lastNonEmptyCharacter, character)
                        currentTag = strtrim(currentTag(1:end-1));
                        errors = errorReporter(obj.commaError, 'tag', ...
                            currentTag);
                        break;
                    end
                    lastNonEmptyCharacter = character;
                end
                characterIndex = characterIndex + 1;
            end
        end % checkcommas
        
        function errors = checkGroupBrackets(obj, hedString)
            % Checks the number of group brackets in a HED string.
            errors = '';
            numberOfOpeningBrackets = length(strfind(hedString, '('));
            numberOfClosingBrackets = length(strfind(hedString, ')'));
            if numberOfOpeningBrackets ~= numberOfClosingBrackets
                errors = errorReporter(obj.groupBracketError, ...
                    'openingBracketCount', numberOfOpeningBrackets, ...
                    'closingBracketCount', numberOfClosingBrackets);
            end
        end % checkgroupbrackets
        
        function errors = checkRequiredChildTags(obj, originalTag, ...
                formattedTag)
            % Checks if the tag requires a child
            errors = '';
            if obj.hedMaps.requireChild.isKey(lower(formattedTag))
                errors = errorReporter(obj.requireChildError, 'tag', ...
                    originalTag);
            end
        end % checkRequiredChildTags
        
        function checkRequiredTags(obj, formattedTopLevelTags)
            % Checks the tags that are required
            requiredTags = obj.hedMaps.required.values();
            numTags = length(requiredTags);
            for a = requiredTagsIndex:numTags
                requiredTagWithSlash = [requiredTags{requiredTagsIndex} ...
                    '/'];
                requiredTagWithSlashLength = ...
                    length(requiredTags{requiredTagsIndex}) + 1;
                indicesFoundInTopLevel = strncmpi(...
                    formattedTopLevelTags, requiredTagWithSlash, ...
                    requiredTagWithSlashLength);
                if sum(indicesFoundInTopLevel) == 0
                    warningReporter(obj.requiredError, 'tagPrefix', ...
                        requiredTagWithSlash);
                end
            end
        end % checkRequiredTags
        
    end % Public methods
    
    methods(Access=private)
        
        function invalidCaps = invalidCapsFoundInTag(obj, tag)
            % Returns true if invalid caps were found in a tag. False, if
            % otherwise. The first letter of the tag is supposed to be
            % capitalized and all subsequent words are supposed to be
            % lowercase.
            invalidCaps = ~isempty(regexp(tag, obj.capExpression, 'once'));
        end % invalidCapsFoundInTag
        
        function takesValue = checkIfParentTagTakesValue(obj, tag)
            % Returns true if the parent tag takes a value. False, if
            % otherwise.
            takesValue = false;
            slashPositions = strfind(tag, '/');
            if ~isempty(slashPositions)
                valueTag = [tag(1:slashPositions(end)) '#'];
                if obj.hedMaps.takesValue.isKey(lower(valueTag))
                    takesValue = true;
                end
            end
        end % checkIfParentTagTakesValue
        
        
        
        
        
        
        function tagIsValid = isValidTagWithParentheses(obj, hedString, ...
                currentTag, characterIndex)
            % Checks to see if the current tag with the next set of
            % parentheses in the HED string is valid.
            currentTag = currentTag(1:end-1);
            restOfHedString = hedString(characterIndex:end);
            currentTagWithParentheses = ...
                obj.getNextSetOfParenthesesInHedString([currentTag ...
                restOfHedString]);
            currentTagWithParentheses = lower(currentTagWithParentheses);
            tagIsValid = obj.hedMaps.tags.isKey(currentTagWithParentheses);
        end % isValidTagWithParentheses
        
        
        function parenthesesLength = getIndexAtEndOfParentheses(...
                obj, hedString, currentTag, characterIndex)
            % Checks to see if the current tag with the next set of
            % parentheses in the HED string is valid. Some tags have
            % parentheses and this function is implemented to avoid
            % reporting a missing comma error.
            currentTag = currentTag(1:end-1);
            restOfHedString = hedString(characterIndex:end);
            [~, parenthesesLength] = ...
                obj.getNextSetOfParenthesesInHedString(...
                [currentTag restOfHedString]);
        end % getIndexAtEndOfParentheses
        
        function [setOfParentheses, parenthesesLength] = ...
                getNextSetOfParenthesesInHedString(obj, hedString) %#ok<INUSL>
            % Gets the next set of parentheses in the provided HED string.
            setOfParentheses = '';
            openingParenthesisFound = false;
            numberOfCharacters = length(hedString);
            parenthesesLength = 0;
            for parenthesesLength = 1:numberOfCharacters
                character = hedString(parenthesesLength);
                setOfParentheses = [setOfParentheses ...
                    hedString(parenthesesLength)]; %#ok<AGROW>
                if character == '('
                    openingParenthesisFound = true;
                elseif character == ')' && openingParenthesisFound
                    return;
                end
            end
        end % getNextSetOfParenthesesInHedString
        
        function commaMissing = commaIsMissingAfterClosingBracket(...
                obj, lastNonEmptyCharacter, currentCharacter)
            % Returns true if a comma is missing after a closing bracket.
            commaMissing = ~isempty(lastNonEmptyCharacter) && ...
                lastNonEmptyCharacter == ')' && ...
                ~obj.characterIsDelimiter(currentCharacter);
        end % commaIsMissingAfterClosingBracket
        
        function commaMissing = commaMissingBeforeOpeningBracket(...
                obj, lastNonEmptyCharacter, currentCharacter)
            % Returns true if a comma is missing before an opening bracket.
            commaMissing = ~isempty(lastNonEmptyCharacter) && ...
                ~obj.characterIsDelimiter(lastNonEmptyCharacter) && ...
                currentCharacter == '(';
        end % commaMissingBeforeOpeningBracket
        
    end % Private methods
    
    methods(Static)
        function isWhitespace = characterIsWhitespace(character)
            % Checks to see if the specified character is whitespace. Tab
            % and newline characters are considered whitespace.
            isWhitespace = ~isempty(regexp(character, '[\\n\\t ]', ...
                'once'));
        end % characterIsWhitespace
        
        function isDelimiter = characterIsDelimiter(character)
            % Checks to see if the specified character is a delimiter.
            % Comma and tildes are considered delimiters.
            isDelimiter = ~isempty(regexp(character, '[,~]', 'once'));
        end % characterIsDelimiter
        
    end % Static methods
    
    
    
    
end % TagValidator