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

function tags = hed2cell(tags, canonicalFormat)
if ischar(tags)
    tags = strtrim(tags);
    if isempty(tags)
        tags = {};
    elseif isempty(regexp(tags, '[,~]', 'ONCE'))
        tags = {tags};
    else
        tags = hedstring2cell(tags, 'keepTildes', true);
    end
end
if canonicalFormat
    tags = putInCanonicalForm(tags);
end

    function tags = putInCanonicalForm(tags)
        % Removes slashes and double quotes
        numTags = length(tags);
        for a = 1:numTags
            if iscell(tags{a})
                tags{a} = putInCanonicalForm(tags{a});
            else
                tags{a} = vTagList.getUnsortedCanonical(tags{a});
            end
        end
    end % putInCanonicalForm

end % hed2cell