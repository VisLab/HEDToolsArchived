% Returns a cell array with the unique values from a specified field name
% in a structure array.
%
% Usage:
%
%   >>  tValues = getutypes(estruct, type)
%
% Inputs:
%
%   Required:
%
%   estruct
%                    A structure array.
%
%   type             A field name in the structure array that you want to
%                    extract the unique values from.
%
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

function tValues = getutypes(estruct, type)
parseArguments(estruct, type);
tValues = {};
values = {estruct.(type)};
isNum = cell2mat(cellfun(@isnumeric, values, 'UniformOutput', false));
tValues = unique(cellfun(@num2str, values, 'UniformOutput', false));
tEmpty = cellfun(@isempty, tValues);
tValues(tEmpty) = [];
tNaN = strcmpi('NaN', tValues);
tValues(tNaN) = [];

    function parseArguments(estruct, type)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('estruct', @(x) (~isempty(x) && ...
            isstruct(x)));
        parser.addRequired('type', @(x) (~isempty(x) && ...
            ischar(x)));
        parser.parse(estruct, type);
    end % parseArguments

end % getutypes