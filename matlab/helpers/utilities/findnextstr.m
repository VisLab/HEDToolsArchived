% This function finds the next string based on the cursor position in the
% tag search bar.
%
% Usage:
%
%   >> [str, first, last] = findnextstr(text, pos)
%
% Input:
%
%   text          The search bar text.
%
%   pos           The position of the cursor in the search bar.
%
% Output:
%
%   str           The next string if found.
%
%   first         The first position of the next string found.
%
%   last          The last position of the next string found.
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [str, first, last] = findnextstr(text, pos)
str = '';
first = length(text);
last = length(text);
inString = false;
pos = findLastPos(text, pos);
if pos < length(text)
    for pos = pos+1:length(text)
        if ~inString && isDelimitingChar(text(pos))
            str(end+1) = text(pos); %#ok<AGROW>
            first = pos;
            last = pos;
            break;
        elseif inString && isspace(text(pos)) || ...
                isDelimitingChar(text(pos))
            last = pos - 1;
            break;
        elseif ~inString && ~isspace(text(pos)) && ...
                ~isDelimitingChar(text(pos))
            str(end+1) = text(pos); %#ok<AGROW>
            first = pos;
            inString = true;
        elseif ~isspace(text(pos)) && ~isDelimitingChar(text(pos))
            str(end+1) = text(pos); %#ok<AGROW>
        end
    end
end

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

    function isDelimiting = isDelimitingChar(character)
        % Returns true if the character is a delimiting character
        delimitingChars = {'(',')',','};
        isDelimiting = any(strcmp(delimitingChars, character));
    end % isDelimitingChar

end % findnextstr