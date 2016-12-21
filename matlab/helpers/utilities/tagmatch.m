% This function looks for a exact tag match in a list of tags.
%
% Usage:
%
%   >>  found = tagmatch(tags, search)
%
% Input:
%
%   tags         A cell array containing the event tags.
%
%   search       A search tag that is looked for amongst the event tags.
%
% Output:
%
%   found        True if a match was found.
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

function found = tagmatch(tags, search)
parseArguments(tags, search);
if search(1) == '/'
   search = search(2:end); 
end
offsetTag = 'Attribute/Offset';
if any(strncmpi(tags, offsetTag, length(offsetTag)))
    onsetTag = 'Attribute/Onset';
    tags{end+1} = onsetTag;
end
prefixSearch = [search '/'];
found = any(strcmpi(tags, search)) || ...
    any(strncmpi(tags, prefixSearch, length(prefixSearch)));

    function p = parseArguments(tags, search)
        % Parses the input arguments and returns the results
        p = inputParser();
        p.addRequired('Tags', @(x) iscell(x));
        p.addRequired('Search', @(x) ischar(x));
        p.parse(tags, search);
        p  = p.Results;
    end % parseArguments

end % tagmatch