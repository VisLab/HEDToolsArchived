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
OPENING_GROUP_BRACKET = '(';
CLOSING_GROUP_BRACKET = ')';
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
        if ~isempty(lastNonEmptyCharacter) && ...
                ~characterIsDelimiter(lastNonEmptyCharacter) && ...
                character == OPENING_GROUP_BRACKET
            currentTag = strtrim(currentTag(1:end-1));
            errors = generateerror(ERRORTYPE, [], currentTag);
            break;
        end
        if ~isempty(lastNonEmptyCharacter) && ...
                lastNonEmptyCharacter == CLOSING_GROUP_BRACKET && ...
                ~characterIsDelimiter(character)
            currentTag = strtrim(currentTag(1:end-1));
            errors = generateerror(ERRORTYPE, [], currentTag);
            break;
        end
        lastNonEmptyCharacter = character;
    end
end

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

end % checkcommas