% Usage:
%
%   >>  [fMap, fPaths, excluded] = tagstudy(studyFile)
%
%   >>  [fMap, fPaths, excluded] = tagstudy(studyFile, 'key1', ...
%       'value1', ...)
%
% Input:
%
%   fMap
%                    A fieldMap object or a full path to a that contains the tag map
%                    information.
%
%   location
%                    The location to write the fieldMap tags to. The
%                    location can be a string which is either the full
%                    path of a directory containing datasets or the full
%                    path of a EEG study.
%
% Output:
%
%   success
%                    True, if the fieldMap was successful with the save.
%                    False, if it failed.
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

function success = savefmap(fMap, location)
p = parseArguments(fMap, location);
success = true;
if ~isempty(p.location) && ~fieldMap.saveFieldMap(p.location, p.fMap)
    success = false;
    warning(['Could not save fieldMap to ' p.location]);
end

    function p = parseArguments(fMap, location)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('fMap', @(x) isa(x, 'fieldMap') || ...
            ischar(x));
        parser.addRequired('location', @ischar);
        parser.parse(fMap, location)
        p = parser.Results;
    end % parseArguments

end % savefmap