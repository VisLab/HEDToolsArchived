% Converts a HED string, composed of any number of nested paranthesis
% and tildes, to a cell array with nested (string) tags, or
% struct('subject', 'verb', 'object') structures.
%
% Usage:
%
%   >>  paranthesisGroup,  paranthesisDepth] = ...
%       process_paranthesis(inputString)
%
% Input:
%
%   inputString
%                    A HED string composed of any number of nested
%                    paranthesis and tildes.
%
% Output:
%
% paranthesisGroup
%                   The same length as characters in inputString,
%                   with different depth =1 paranthesis groups numbered
%                   differently (increasing from start to end)
% paranthesisDepth
%                   The same length as characters in inputString, with
%                   zero for outside any paranthesis and 1, 2, etc for text
%                   inside more and more nested paranthesis.
%
% Copyright (C) 2015 Nima Bigdely-Shamlo nima.bigdely@qusp.io
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

function [paranthesisGroup,  paranthesisDepth] = ...
    processparanthesis(inputString)
paranthesisDepth = zeros(length(inputString), 1);
paranthesisGroup = paranthesisDepth;
openMask = inputString == '(';
closeMask = inputString == ')';
paranthesisGuide = paranthesisDepth;
paranthesisGuide(openMask) = 1;
paranthesisGuide(closeMask) = -1;
paranthesisDepth = cumsum(paranthesisGuide);
paranthesisDepth(find(closeMask)) = paranthesisDepth(find(closeMask)-1);
lastDephth = 0;
currentGroup = 0;
for i=1:length(inputString)
    if (i == 1 || paranthesisDepth(i-1) == 0) && paranthesisDepth(i) == 1
        currentGroup = currentGroup + 1;
    end
    paranthesisGroup(i) = currentGroup;
end;
paranthesisGroup(paranthesisDepth == 0) = 0;

body = inputString(paranthesisGroup == 0);
parathesisStrings = {};
for i=1:max(paranthesisGroup)
    parathesisStrings{i} = inputString(paranthesisGroup == i);
end; % processparanthesis