% Replaces the ids in a map container with parts of a HED string. 
%
% Usage:
%
%   >>  output = hedreplaceidswithpart(input, idToPartMap)
%
% Input:
%
%   input
%                    A HED string containing ids that will be replaced. 
%
%   idToPartMap
%                    A map container containing parts of the tag string. 
%
% Output:
%
%   output
%                   A HED string containing the parts that replaced the
%                   ids.
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

function output = hedreplaceidswithpart(input, idToPartMap)
output = input;
if ischar(input)
    if isKey(idToPartMap, input)
        output = idToPartMap(input);
    end;
elseif isstruct(input)
    names = fieldnames(input);
    for j=1:length(names)
        output.(names{j}) = hedreplaceidswithpart(input.(names{j}), ...
            idToPartMap);
    end;
elseif iscell(input)
    for i=1:length(input)
        output{i} = hedreplaceidswithpart(input{i}, idToPartMap);
    end;
end; % hedreplaceidswithpart