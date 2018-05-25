% This function finds the previous string based on the cursor position in
% the HED tag search bar.
%
% Usage:
%
%   >> [sequence, start, finish] = findhedsequence(text, pos)
%
% Inputs:
%
%   text          The search bar text.
%
%   pos           The position of the cursor in the search bar.
%
% Outputs:
%
%   sequence      The current sequence.
%
%   start         The first position of the sequence.
%
%   finish        The last position of the sequence.
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

function [sequence, start, finish] = findhedsequence(text, pos)
start = findFirstPos(text, pos);
finish = findLastPos(text, pos);
% if ~isDelimitingChar(text(pos)) && ~isOperator(text(start:finish)) && ...
%         ~isHEDTag(text(start:finish));
if ~isDelimitingChar(text(pos)) && ~isHEDTag(text(start:finish))
    [~, start, ~, startMatch, startMatchFinish] = ...
        findSequenceStart(text, start);
    if startMatch
        finish = startMatchFinish;
    else
        [~, ~, finish, finishStartMatch, startMatchStart] = ...
            findSequenceFinish(text, finish);
        if finishStartMatch
            start = startMatchStart;
        end
    end
end
[start, finish] = ...
    findNonDelimitingRange(text(start:finish), start, finish);
sequence = strtrim(text(start:finish));

    function [tagFound, start, finish, startMatch, startMatchFinish] = ...
            findSequenceStart(text, pos)
        % Find the beginning of the sequence
        start = 1;
        finish = 1;
        startMatchFinish = pos;
        [hasPreviousStr, PreviousStrStart, ~, tagFound, tagStart, ...
            tagFinish] = findPreviousTag(text, pos);
        startMatch = tagFound;
        while hasPreviousStr && ~tagFound
            [hasPreviousStr, PreviousStrStart, ~, tagFound, tagStart, ...
                tagFinish] = findPreviousTag(text, PreviousStrStart);
        end
        if tagFound
            if startMatch
                start = tagStart;
                finish = tagFinish;
                startMatchFinish = tagFinish;
            else
                start = tagFinish;
                [~, start, finish] = findnextstr(text, start);
            end
        end
    end % findSequenceStart

    function [tagFound, start, finish, startMatch, startMatchStart] = ...
            findSequenceFinish(text, pos)
        % Finds the end of the sequence
        start = length(text);
        finish = length(text);
        startMatchStart = pos;
        [hasNextStr, nextStrStart, ~, tagFound, tagStart, tagFinish] = ...
            findNextTag(text, pos);
        startMatch = tagFound;
        while hasNextStr && ~tagFound
            [hasNextStr, nextStrStart, ~, tagFound, tagStart, ...
                tagFinish] = findNextTag(text, nextStrStart);
        end
        if tagFound
            if startMatch
                startMatchStart = tagStart;
                start = tagStart;
                finish = tagFinish;
            else
                finish = tagStart;
                [~,start, finish] = findpreviousstr(text, finish);
            end
        end
    end % findSequenceFinish

    function [hasPrevious, previousStart, previousFinish, found, ...
            foundStart, foundFinish] = findPreviousTag(text, pos)
        % Finds the previous tag from the current cursor position
        found = false;
        foundStart = findFirstPos(text, pos);
        foundFinish = findLastPos(text, pos);
        [hasPrevious, previousStart, previousFinish] = ...
            hasPreviousString(text, foundFinish);
        concatStr = text(foundStart:foundFinish);
        if isSpecialString(concatStr)
            found = true;
            return;
        end
        while hasPreviousString(text, foundStart)
            [currentStr, foundStart] = ...
                findpreviousstr(text, foundStart);
            concatStr = [currentStr ' ' concatStr]; %#ok<AGROW>
            if isSpecialString(concatStr)
                found = true;
                return;
            end
        end
    end % findPreviousTag

    function [hasNext, nextStart, nextFinish, found, foundStart, ...
            foundFinish] = findNextTag(text, pos)
        % Finds the next tag from the current cursor position
        found = false;
        foundStart = findFirstPos(text, pos);
        foundFinish = findLastPos(text, pos);
        [hasNext, nextStart, nextFinish] = hasNextString(text, pos);
        concatStr = text(foundStart:foundFinish);
        if isSpecialString(concatStr)
            found = true;
            return;
        end
        while hasNextString(text, foundFinish)
            [currentStr, ~, foundFinish] = ...
                findnextstr(text, foundFinish);
            concatStr = [concatStr ' ' currentStr]; %#ok<AGROW>
            if isSpecialString(concatStr)
                found = true;
                return;
            end
        end
    end % findNextTag

    function isTag = isSpecialString(str)
        % Returns true if string is a tag, delimiting character, or
        % operator
        isTag = false;
%         if isDelimitingChar(str) || isOperator(str) 
        if isDelimitingChar(str)
            isTag = true;
        end
    end % checkForTag

    function [hasNext, start, finish] = hasNextString(text, pos)
        % Returns true if there is a next string
        hasNext = false;
        [nextString, start, finish] = findnextstr(text, pos);
        if ~isempty(nextString)
            hasNext = true;
        end
    end % hasNextString

    function [hasPrevious, start, finish] = hasPreviousString(text, pos)
        % Returns true if there is a previous string
        hasPrevious = false;
        [previousString, start, finish] = findpreviousstr(text, pos);
        if ~isempty(previousString)
            hasPrevious = true;
        end
    end % hasPreviousString

    function first = findFirstPos(text, pos)
        % Finds the first position of the current string
        first = pos;
        if isspace(text(first)) || isDelimitingChar(text(first))
            return;
        end
        for first = pos:-1:1
            if isspace(text(first)) || isDelimitingChar(text(first))
                if ~(first + 1 > length(text))
                    first = first + 1; %#ok<FXSET>
                end
                break;
            end
        end
    end % findFirstPos

    function last = findLastPos(text, pos)
        % Finds the last position of the current string
        last = pos;
        if isspace(text(last)) || isDelimitingChar(text(last))
            return;
        end
        numChars = length(text);
        for last = pos:numChars
            if isspace(text(last)) || isDelimitingChar(text(last))
                if ~(last - 1 < 1)
                    last = last - 1; %#ok<FXSET>
                end
                break;
            end
        end
    end % findLastPos

    function [isDelimiting, endDelimiter] = isDelimitingChar(character)
        % Returns true if the character is a delimiting character
%         specialChars = {'(',')',','};
        specialChars = {','};
        isDelimiting =  any(strcmp(specialChars, character));
        endDelimiter = character == ')';
    end % isDelimitingChar

    function [start, finish] = findNonDelimitingRange(sequence, start, ...
            finish)
        % Finds the start and finish position of a string contained in
        % parentheses
        exp = '[^ \(\),\s]';
        nonDelimiters = regexp(sequence, exp);
        if ~isempty(nonDelimiters)
            start = max(start,min(nonDelimiters));
            finish = max(finish, max(nonDelimiters));
        end
    end % findNonDelimitingRange

    function isOp = isOperator(string)
        % Returns true if the string is a operator
        isOp = false;
        operators = {'AND', 'OR', 'NOT', '~'};
        if any(strcmp(operators, string))
            isOp = true;
        end
    end % isOperator

    function isTag = isHEDTag(string)
        % Returns true if the string is a HED tag
        isTag = false;
        try
            Maps.tagMap(lower(string));
            isTag = true;
        catch
        end
    end % isHEDTag

end % findhedsequence