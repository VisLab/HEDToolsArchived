% This function checks to see if commas are missing after tags and groups.
%
% Usage:
%
%   >>  errors = checkcommas(hedString)
%
% Input:
%
%   hedString
%                   A HED string.
%
% Output:
%
%   errors
%                   A string containing the validation errors.
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

function errors = checkcommas(hedString)
ERRORTYPE = 'comma';
errors = '';
currentTag = '';
lastNonEmptyCharacter = '';
hedStringLength = length(hedString);
for a = 1:hedStringLength
    character = hedString(a);
    currentTag = [currentTag character]; %#ok<AGROW>
    if ~characterIsWhitespace(character)
        if characterIsDelimiter(character)
            currentTag = '';
        end
        if commaMissingBeforeOpeningBracket(lastNonEmptyCharacter, ...
                character) && ~isValidTagWithParentheses(...
                hedString, currentTag, a);
            currentTag = strtrim(currentTag(1:end-1));
            errors = generateerror(ERRORTYPE, [], currentTag);
            break;
        end
        if commaIsMissingAfterClosingBracket(lastNonEmptyCharacter, ...
                character)
            currentTag = strtrim(currentTag(1:end-1));
            errors = generateerror(ERRORTYPE, [], currentTag);
            break;
        end
        lastNonEmptyCharacter = character;
    end
end
end % checkcommas

function commaMissing = commaIsMissingAfterClosingBracket(...
    lastNonEmptyCharacter, currentCharacter)
% Returns true if a comma is missing after a closing bracket
commaMissing = ~isempty(lastNonEmptyCharacter) && ...
    lastNonEmptyCharacter == ')' && ...
    ~characterIsDelimiter(currentCharacter);
end % commaIsMissingAfterClosingBracket

function commaMissing = commaMissingBeforeOpeningBracket(...
    lastNonEmptyCharacter, currentCharacter)
% Returns true if a comma is missing before an opening bracket
commaMissing = ~isempty(lastNonEmptyCharacter) && ...
    ~characterIsDelimiter(lastNonEmptyCharacter) && ...
    currentCharacter == '(';
end % commaMissingBeforeOpeningBracket

function isWhitespace = characterIsWhitespace(character)
% Checks to see if the specified character is whitespace. Tab and
% newline characters are considered whitespace.
isWhitespace = ~isempty(regexp(character, '[\\n\\t ]', 'once'));
end % characterIsWhitespace

function isDelimiter = characterIsDelimiter(character)
% Checks to see if the specified character is a delimiter. Comma
% and tildes are considered delimiters.
isDelimiter = ~isempty(regexp(character, '[,~]', 'once'));
end % characterIsDelimiter

function setOfParentheses = getNextSetOfParenthesesInHedString(...
    hedString)
% Gets the next set of parentheses in the provided HED string.
setOfParentheses = '';
openingParenthesisFound = false;
numberOfCharacters = length(hedString);
for a = 1:numberOfCharacters
    character = hedString(a);
    setOfParentheses = [setOfParentheses hedString(a)]; %#ok<AGROW>
    if character == '('
        openingParenthesisFound = true;
    elseif character == ')' && openingParenthesisFound
        return;
    end
end
end % getNextSetOfParenthesesInHedString

function tagIsValid = isValidTagWithParentheses(hedString, ...
    currentTag, characterIndex)
% Checks to see if the current tag with the next set of parentheses
% in the HED string is valid. Some tags have
load(which('HEDMaps.mat'));
currentTag = currentTag(1:end-1);
restOfHedString = hedString(characterIndex:end);
currentTagWithParentheses = getNextSetOfParenthesesInHedString(...
    [currentTag restOfHedString]);
currentTagWithParentheses = lower(currentTagWithParentheses);
tagIsValid = hedMaps.tags.isKey(currentTagWithParentheses);
end % isValidTagWithParentheses