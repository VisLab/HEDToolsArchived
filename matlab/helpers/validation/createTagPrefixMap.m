% Creates a dictionary containing a mapping of specific tag column indices
% to tag prefixes. 
%
% Usage:
%
%   >>  tagPrefixMap = createTagPrefixMap(specificColumns)

% Input:
%
%   Required:
%
%   specificColumns
%                   A scalar structure used to specify the specific tag
%                   columns. The fieldnames need to be category
%                   corresponding to Event/Category, description 
%                   corresponding to Event/Description, label corresponding
%                   to Event/Label, long corresponding to Event/ Long name.
%                   The field values are the column indices that contain
%                   the specific tags. 
%
%                   Example:
%                   specificColumns.long = 2;
%                   specificColumns.description = 3;
%                   specificColumns.label = 4;
%
% Output:
%
%   tagPrefixMap
%                   A dictionary containing a mapping of specific tag
%                   column indices to tag prefixes. 
%
% Copyright (C) 2017
% Jeremy Cockfield jeremy.cockfield@gmail.com
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

function tagPrefixMap = createTagPrefixMap(specificColumns)
SPECIFIC_COLUMN_NAMES = {'long','description','label','category'};
SPECIFIC_COLUMN_PREFIXES = {'Event/Long name/','Event/Description/', ...
    'Event/Label/','Event/Category/'};
tagPrefixMap = containers.Map('KeyType', 'double', 'ValueType', ...
    'char');
parseInputArguments(specificColumns);
specificColumnNames = fieldnames(specificColumns);
numberOfSepecificColumns = length(specificColumnNames);
for a = 1:numberOfSepecificColumns
    specificColumnIndex = find(strcmp(SPECIFIC_COLUMN_NAMES, ...
        specificColumnNames{a}), 1);
    if ~isempty(specificColumnIndex)
        tagPrefixMap(specificColumns.(specificColumnNames{a})) = ...
            SPECIFIC_COLUMN_PREFIXES{specificColumnIndex};
    end
end

    function inputArguments = parseInputArguments(specificColumns)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('specificColumns', @isstruct);
        parser.parse(specificColumns);
        inputArguments = parser.Results;
    end % parseInputArguments

end % getSpecificColumnsFromInputArguments