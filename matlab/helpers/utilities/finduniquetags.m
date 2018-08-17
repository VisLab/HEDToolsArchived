% Finds the unique HED tags in a cell array of tags.  
%
% Usage:
%
%   >>  uniquetags = finduniquetags(tags)
%
% Input:
%
%   Required:
%
%   tags
%                    A cell array containing HED tags. 
%
% Output:
%
%   uniquetags
%                    A cell string containing the unique HED tags in the 
%                    tags input argument. 
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

function uniquetags = finduniquetags(tags)
% Gets the unique tags
uniquetags = {};
numEvents = length(tags);
for a = 1:numEvents
    uniquetags = union(uniquetags, formatTags(tags{a}));
end

    function tags = formatTags(tags)
        % Format the tags and puts them in a cellstr if they are in a
        % string
        tags = tagList.deStringify(tags);
        if ~iscellstr(tags)
            tags = [tags{:}];
        end
        tags =  tagList.getUnsortedCanonical(tags);
    end % formatTags

end % finduniquetags