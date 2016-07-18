% This function looks for a exact tag match in a list of tags.
%
% Usage:
%   >>  found = tagmatch(tags, search)
%
% Inputs:
%   tags         A cell array containing the event tags. 
% 
%   search       A search tag that is looked for amongst the event tags.
%
% Outputs:
%   found        True if a match was found. 
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function found = tagmatch(tags, search)
parseArguments();
defaultTag = 'Attribute/Onset';
tags{end+1} = defaultTag;
found = any(strncmpi(tags, search, length(search)));

    function p = parseArguments()
        % Parses the input arguments and returns the results 
        p = inputParser();
        p.addRequired('Tags', @(x) iscell(x));
        p.addRequired('Search', @(x) ischar(x));
        p.parse(tags, search);
        p  = p.Results;
    end  % parseArguments

end % exactmatch