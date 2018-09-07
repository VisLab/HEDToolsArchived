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
        commaValidError = 'commaValid';
        duplicateError = 'duplicate';
        groupBracketError = 'bracket';
        numericalExpression = '<>=.0123456789';
        numericError = 'isNumeric';
        requireChildError = 'requireChild';
        requiredError = 'required';
        unitClassWarning = 'unitClass';
        unitClassError = 'unitClass';
        tilde = '~';
        tildeError = 'tilde';
        timeExpression = '^([0-1]?[0-9]|2[0-3])(:[0-5][0-9])?$';
        uniqueError = 'unique';
        validError = 'valid';
    end % Instance properties
    
    methods
        
        function obj = TagValidator(hedMaps)
            % Constructor
            obj.hedMaps = hedMaps;
        end % TagValidator
        
        function hedMaps = getHedMaps(obj)
            hedMaps = obj.hedMaps;
        end % getHedMaps
        
        function issues = checkPathNameCaps(obj, originalTag)
            % Returns true if the tag path isn't correctly capitalized
            issues = '';
            if checkIfParentTagTakesValue(obj, originalTag)
                return;
            elseif invalidCapsFoundInTag(obj, originalTag)
                issues = warningReporter(obj.capWarnings, 'tag', ...
                    originalTag);
            end
        end % checkPathNameCaps
        
        function issues = checkForMissingCommas(obj, hedString)
            % Checks for missing commas in a HED string.
            issues = '';
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
                        issues = errorReporter(obj.commaError, 'tag', ...
                            currentTag);
                        break;
                    elseif obj.commaIsMissingAfterClosingBracket(...
                            lastNonEmptyCharacter, character)
                        currentTag = strtrim(currentTag(1:end-1));
                        issues = errorReporter(obj.commaError, 'tag', ...
                            currentTag);
                        break;
                    end
                    lastNonEmptyCharacter = character;
                end
                characterIndex = characterIndex + 1;
            end
        end % checkForMissingCommas
        
        function issues = checkNumberOfGroupBrackets(obj, hedString)
            % Checks the number of group brackets in a HED string are
            % equal.
            issues = '';
            numberOfOpeningBrackets = length(strfind(hedString, '('));
            numberOfClosingBrackets = length(strfind(hedString, ')'));
            if numberOfOpeningBrackets ~= numberOfClosingBrackets
                issues = errorReporter(obj.groupBracketError, ...
                    'openingBracketCount', numberOfOpeningBrackets, ...
                    'closingBracketCount', numberOfClosingBrackets);
            end
        end % checkNumberOfGroupBrackets
        
        function issues = checkIfTagRequiresAChild(obj, originalTag, ...
                formattedTag)
            % Checks if the tag requires a child
            issues = '';
            if obj.hedMaps.requireChild.isKey(lower(formattedTag))
                issues = errorReporter(obj.requireChildError, 'tag', ...
                    originalTag);
            end
        end % checkIfTagRequiresAChild
        
        function issues = checkIfRequiredTagsPresent(obj, ...
                formattedTopLevelTags, missingRequiredTagsAreErrors)
            % Checks to see if the required tags are present at the
            % top-level.
            issues = '';
            requiredTags = obj.hedMaps.required.values();
            numRequiredTags = length(requiredTags);
            for requiredTagIndex = 1:numRequiredTags
                indicesFoundInTopLevel = ...
                    TagValidator.findIndicesThatBeginWithPrefix(...
                    formattedTopLevelTags, requiredTags{requiredTagIndex});
                if sum(indicesFoundInTopLevel) == 0
                    if missingRequiredTagsAreErrors
                        issues = [issues ...
                            errorReporter(obj.requiredError, ...
                            'tagPrefix', requiredTags{requiredTagIndex})];
                    else
                        issues = [issues ...
                            warningReporter(obj.requiredError, ...
                            'tagPrefix', requiredTags{requiredTagIndex})];
                    end
                end
            end
        end % checkIfRequiredTagsPresent
        
        function issues = checkNumberOfGroupTildes(obj, originalGroupTags)
            % Checks the number of tildes in a group are less than or equal
            % to 2.
            issues = '';
            if sum(strncmp('~', originalGroupTags, 1)) > 2
                groupTagString = vTagList.stringify(originalGroupTags);
                issues = errorReporter(obj.tildeError, 'tag', ...
                    groupTagString);
            end
        end % checkNumberOfGroupTildes
        
        function issues = checkForDuplicateTags(obj, originalTags, ...
                formattedTags)
            % Check for duplicate tags on the same level or group.
            issues = '';
            formattedTags = ...
                HedStringDelimiter.removedTildesFromGroup(formattedTags);
            numOfTags = length(formattedTags);
            for tagIndex = 1:numOfTags
                if sum(ismember(formattedTags, ...
                        formattedTags{tagIndex})) > 1
                    issues = errorReporter(obj.duplicateError, 'tag', ...
                        originalTags{tagIndex});
                    return;
                end
            end
        end % checkForDuplicateTags
        
        function issues = checkForMultipleUniquePrefixes(obj, ...
                formattedTags)
            % Looks for two or more tags that are descendants of a unique
            % tag
            issues = '';
            uniqueTags = obj.hedMaps.unique.values();
            numUniqueTags = length(uniqueTags);
            for uniqueTagsIndex = 1:numUniqueTags
                foundIndexes = strncmpi(formattedTags, ...
                    uniqueTags{uniqueTagsIndex}, ...
                    length(uniqueTags{uniqueTagsIndex}));
                if sum(foundIndexes) > 1
                    issues = errorReporter(obj.uniqueError, ...
                        'tagPrefix', uniqueTags{uniqueTagsIndex});
                end
            end
        end % checkForMultipleUniquePrefixes
        
        function issues = checkUnitClassTagHasUnits(obj, ...
                originalTag, formattedTag)
            % Checks to see if the unit class tags has units.
            issues = '';
            [isUnitClass, unitClassFormatTag] = obj.isUnitClassTag(...
                formattedTag);
            if isUnitClass
                unitClasses = strsplit(obj.hedMaps.unitClass(lower(...
                    unitClassFormatTag)), ',');
                unitClassDefault = ...
                    obj.hedMaps.default(lower(unitClasses{1}));
                numericalTagValue = TagValidator.getTagName(formattedTag);
                if TagValidator.isValidNumericalString(numericalTagValue)
                    issues = warningReporter(obj.unitClassWarning, ...
                        'defaultUnit', unitClassDefault, 'tag', ...
                        originalTag);
                end
            end
        end % checkUnitClassTagHasUnits
        
        function issues = checkUnitClassTagHasValidUnits(obj, ...
                originalTag, formattedTag)
            % Checks for errors in a unit class tag.
            issues = '';
            [isUnitClass, unitClassFormatTag] = obj.isUnitClassTag(...
                formattedTag);
            if isUnitClass
                unitClassTagValue = TagValidator.getTagName(formattedTag);
                units = obj.getTagUnitClassUnits(unitClassFormatTag);
                unitsRegexp = TagValidator.buildUnitsRegexp(units);
                if isempty(regexpi(unitClassTagValue, unitsRegexp)) && ...
                        ~TagValidator.isValidTimeString(unitClassTagValue)
                    issues = errorReporter(obj.unitClassError, 'tag', ...
                        originalTag,  'unitClassUnits', units);
                end
            end
        end % checkUnitClassTagForErrors
        
        function issues = checkIfValidNumericalTag(obj, originalTag, ...
                formattedTag)
            % Checks if the tag is valid if it has the isNumeric attribute.
            issues = '';
            isNumeric = obj.isNumericTag(formattedTag);
            isUnitClass = obj.isUnitClassTag(formattedTag);
            if isNumeric && ~isUnitClass
                numericalTagValue = TagValidator.getTagName(formattedTag);
                if ~TagValidator.isValidNumericalString(numericalTagValue)
                    issues = errorReporter(obj.numericError, 'tag', ...
                        originalTag);
                end
            end
        end % checkIfValidNumericalTag
        
        function issues = checkIfTagIsValid(obj, originalTag, ...
                formattedTag, previousOriginalTag, previousFormattedTag)
            % Checks if the tag is valid.
            issues = '';
            tagInSchema = obj.tagInSchema(formattedTag);
            if  ~tagInSchema
                if obj.previousTagParentTakesValue(previousFormattedTag)
                    issues = errorReporter(obj.commaValidError, ...
                        'previousTag', previousOriginalTag, 'tag', ...
                        originalTag);
                else
                    issues = errorReporter(obj.validError, 'tag', ...
                        originalTag);
                end
            end
        end % checkIfTagIsValid
        
        function units = getTagUnitClassUnits(obj, unitClassTag)
            % Gets the units associated with a unit class tag.
            unitClasses = strsplit(obj.hedMaps.unitClass(lower(...
                unitClassTag)), ',');
            numUnitClasses = size(unitClasses{1});
            units = obj.hedMaps.unitClasses(lower(unitClasses{1}));
            for a = 2:numUnitClasses
                units = [units, ',', ...
                    obj.hedMaps.unitClasses(lower(unitClasses{a}))]; %#ok<AGROW>
            end
        end % getTagUnitClassUnits
        
    end % Public methods
    
    methods(Access=private)
        
        function inSchema = tagInSchema(obj, tag)
            % Returns true if the tag is in the schema.
            inSchema = obj.isAValidTag(tag) || obj.isTilde(tag) || ...
                obj.checkIfParentTagTakesValue(tag) || ...
                obj.isExtensionTag(tag);
        end % tagInSchema
        
        function takesValue = previousTagParentTakesValue(obj, previousTag)
            % Returns true if the previous tag parent takes a value.
            takesValue = ~isempty(previousTag) && ...
                obj.checkIfParentTagTakesValue(previousTag);
        end % previousTagParentTakesValue
        
        function isValid = isAValidTag(obj, tag)
            % Returns true if the tag is valid.
            isValid = obj.hedMaps.tags.isKey(lower(tag));
        end % isAValidTag
        
        function [isExtensionTag, extensionParentTag] = ...
                isExtensionTag(obj, tag)
            % Checks if the tag or its descendants has the extensionAllowed
            % attribute
            isExtensionTag = false;
            extensionParentTag = '';
            slashIndexes = strfind(tag, '/');
            while size(slashIndexes, 2) > 1
                parent = tag(1:slashIndexes(end)-1);
                if obj.hedMaps.extensionAllowed.isKey(lower(parent))
                    extensionParentTag = parent;
                    isExtensionTag = true;
                    break;
                end
                slashIndexes = strfind(parent, '/');
            end
        end % isExtensionTag
        
        function tilde = isTilde(obj, tag)
            % Returns true if the tag cell array is a tilde
            tilde = strcmp(obj.tilde, tag);
        end % isTilde
        
        
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
        
        function isNumeric = isNumericTag(obj, tag)
            % Returns true if the tag is a numeric tag
            isNumeric = false;
            tag = lower(tag);
            if ~obj.hedMaps.tags.isKey(tag)
                numericTag = TagValidator.convertToTakesValueTag(tag);
                isNumeric = obj.hedMaps.isNumeric.isKey(numericTag);
            end
        end % isNumericTag
        
        function [isUnitClass, unitClassFormatTag] = isUnitClassTag(...
                obj, tag)
            % Returns true if the tag requires a unit class
            tag = lower(tag);
            isUnitClass = false;
            unitClassFormatTag = '';
            if ~obj.hedMaps.tags.isKey(tag)
                unitClassFormatTag = ...
                    TagValidator.convertToTakesValueTag(tag);
                isUnitClass = ...
                    obj.hedMaps.unitClass.isKey(unitClassFormatTag);
            end
        end % isUnitClassTag
        
        
        
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
        
        function indicesFound = findIndicesThatBeginWithPrefix(tags, ...
                prefix)
            % Finds the indices in a cell array of tags that begin with a
            % prefix.
            if prefix(end) ~= '/'
                prefix = [prefix '/'];
            end
            prefixLength = length(prefix);
            indicesFound = strncmpi(tags, prefix, prefixLength);
        end % findIndicesThatBeginWithPrefix
        
        function valueTag = convertToTakesValueTag(tag)
            % Strips the tag name and replaces it with #
            valueTag = tag;
            slashPositions = strfind(tag, '/');
            if ~isempty(slashPositions)
                valueTag = [tag(1:slashPositions(end)) '#'];
            end
        end % convertToTakesValueTag
        
        function tagName = getTagName(tag)
            % Get the tag name from the full tag path
            splitTagPath = strsplit(tag, '/');
            tagName = splitTagPath{end};
        end % getTagName
        
        function validTimeString = isValidTimeString(timeString)
            % Returns true if the string is a valid time string. False, if
            % otherwise.
            validTimeString = ~isempty(regexp(timeString, ...
                TagValidator.timeExpression, 'once'));
        end % isValidTimeString
        
        function validNumericalValue = isValidNumericalString(...
                numericalString)
            % Returns true if a valid numerical value. False, if otherwise.
            validNumericalValue = all(ismember(numericalString, ...
                TagValidator.numericalExpression));
        end
        
        function unitsRegexp = buildUnitsRegexp(units)
            % Builds a regexp for unit class units
            characterEscapes = {'.','\','+','*','?','[','^',']','$','(', ...
                ')','{','}','=','!','<','>','|',':','-'};
            splitUnits = strsplit(units, ',');
            operators = '^(>|>=|<|<=)?\s*';
            digits = '\d*\.?\d+\s*';
            unitsGroup = '(';
            for a = 1:length(splitUnits)
                if any(strcmpi(characterEscapes, strtrim(splitUnits{a})))
                    unitsGroup = [unitsGroup, ['\', ...
                        strtrim(splitUnits{a})], '|']; %#ok<AGROW>
                else
                    unitsGroup = [unitsGroup, strtrim(splitUnits{a}), ...
                        '|'];  %#ok<AGROW>
                end
            end
            unitsGroup = regexprep(unitsGroup, '\|$', '');
            unitsGroup = [unitsGroup,')?\s*'];
            unitsRegexp = [operators,unitsGroup,digits, unitsGroup, '$'];
        end % buildUnitsRegexp
        
    end % Static methods
    
end % TagValidator