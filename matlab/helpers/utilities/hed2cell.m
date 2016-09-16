% Converts a HED string into a cell array and puts them in canonical format
% if specified. Cells that are strings represent individual tags while
% cells that are cellstrs represent tag groups. Canonical tags have forward
% slashes and double quotes removed from the beginning and end of the tags.
% Canonical tags are used for validation. 
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
%   canonicalFormat
%                    True if the tags are to be converted into canonical
%                    format. False if otherwise.   
%
% Output:
%
%   fTags
%                    The formatted tags 
%                    dataset will need to have a .event field.
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

function fTags = hed2cell(tags, canonicalFormat)
fTags = vTagList.deStringify(tags);
if canonicalFormat
    numTags = length(fTags);
    for c = 1:numTags
        fTags{c} = vTagList.getUnsortedCanonical(fTags{c});
    end
end
end % hed2cell