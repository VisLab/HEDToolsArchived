% 
%
% Usage:
%
%   >>  answer = heditemquerymatch(hedItem, queryItem)
%
% Input:
%
%   hedItem
%   
%
%   queryItem
%         
%
% Output:
%
%   answer
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

function answer = heditemquerymatch(hedItem, queryItem)
% hedItem can be a cell, struct or string
answer = false;
if ischar(hedItem)
    hedItem = standardizedhedtag(hedItem);
    if ischar(queryItem)
        queryItem = standardizedhedtag(queryItem);
        answer = length(hedItem) >= length(queryItem) && strcmp(hedItem(1:length(queryItem)), queryItem);
    end;
elseif isstruct(hedItem)
elseif iscell(hedItem)
    for i=1:length(hedItem)
        answer = answer || heditemquerymatch(hedItem{i}, queryItem);
    end;
end; % heditemquerymatch