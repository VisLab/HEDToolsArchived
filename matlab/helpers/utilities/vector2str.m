% Converts a vector to string with colon operators used for consecutive
% elements.
%
%   >> str = vector2str(num)
%
% Input:
%
%   num          A vector.
%
% Output:
%
%   str          A string representing a vector.
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

function str = vector2str(num)
str = '';
if numel(num) == 1
    str = num2str(num);
elseif numel(num) > 1
    str = num2str(num(1));
    incrementStart = true;
    for a = 2:length(num)
        if num(a) - num(a-1) == 1
            [str, incrementStart] = handleConsecutive(str, incrementStart);
        else
            [str, incrementStart] = handleNonConsecutive(str, ...
                incrementStart, num(a-1), num(a));
        end
    end
    str = ['[' handleLastIndex(str, incrementStart, num(length(num))) ']'];
end

    function [str, incrementStart] = handleNonConsecutive(str, ...
            incrementStart, previous, current)
        % Handles a number that is not a consecutive number
        if ~incrementStart
            str = [str num2str(previous)];
        end
        str = [str ' ' num2str(current)];
        incrementStart = true;
    end % handleNonConsecutive

    function str = handleLastIndex(str, incrementStart, last)
        % Handles the last number in the vecor
        if ~incrementStart
            str = [str num2str(last)];
        end
    end % handleLastIndex

    function [str, incrementStart] = handleConsecutive(str, incrementStart)
        % Handles a number that is a consecutive number
        if incrementStart
            str = [str ':'];
            incrementStart = false;
        end
    end % handleConsecutive

end % vector2str