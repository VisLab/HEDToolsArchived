% This function combines tags that share the same prefix and only the most
% specific is retained (e.g., /a/b/c and /a/b become just /a/b/c).
%
% Usage:
%
%   >>  nonPrefixTags = undoprefix(tags)
%
% Input:
%
%   Required:
%
%   tags
%                    A cell array of tags.
%
% Output:
%
%   tags
%                    A cell array of tags whose shared prefixes are
%                    combined.
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

function tags = undoprefix(tags)
% nonPrefixTags = sort(tags);
for k = 1:length(tags) - 1
    if ~ischar(tags{k})
        tags{k} = undoprefix(tags{k});
        continue;
    end
    if ~isempty(regexp(tags{k+1}, ['^' tags{k}], ...
            'match'))
        tags{k} = [];
    end
end
tags = tags(~cellfun('isempty',tags));
end % undoprefix