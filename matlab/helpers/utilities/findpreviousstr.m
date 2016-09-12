% This function finds the previous string based on the cursor position in
% the tag search bar.
%
% Usage:
%
%   >> [str, first, last] = findpreviousstr(text, pos)
%
% Inputs:
%
%   text          
%                 The search bar text.
%
%   pos           
%                 The position of the cursor in the search bar.
%
% Outputs:
%
%   str           
%                 The previous string if found.
%
%   first         
%                 The first position of the previous string found.
%
%   last          
%                 The last position of the previous string found.
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

function [str, first, last] = findpreviousstr(text, pos)
str = '';
first = 1;
last = 1;
inString = false;
pos = findFirstPos(text, pos);
if pos > 1
    for pos = pos-1:-1:1
        if ~inString && isDelimitingChar(text(pos))
            str(end+1) = text(pos); %#ok<AGROW>
            first = pos;
            last = pos;
            break;
        elseif inString && isspace(text(pos)) || ...
                isDelimitingChar(text(pos))
            first = pos + 1;
            break;
        elseif ~inString && ~isspace(text(pos)) && ...
                ~isDelimitingChar(text(pos))
            str(end+1) = text(pos); %#ok<AGROW>
            last = pos;
            inString = true;
        elseif ~isspace(text(pos)) && ~isDelimitingChar(text(pos))
            str(end+1) = text(pos); %#ok<AGROW>
        end
    end
    str = fliplr(str);
end

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

    function isDelimiting = isDelimitingChar(character)
        % Returns true if the character is a delimiting character
        delimitingChars = {'(',')',','};
        isDelimiting = any(strcmp(delimitingChars, character));
    end % isDelimitingChar

end % findpreviousstr