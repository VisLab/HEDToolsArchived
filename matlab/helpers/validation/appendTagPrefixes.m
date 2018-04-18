% Appends tag prefixes to HED tags in a spreadsheet row. 
%
% Usage:
%
%   >>  tagPrefixMap = appendTagPrefixes(specificColumns)

% Input:
%
%   Required:
%
%   spreadsheetRow
%                   A cell array containing the HED tags in a given row.
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
%   spreadsheetRow
%                   The spreadsheet row with the append tag prefixes.
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

function spreadsheetRow = appendTagPrefixes(spreadsheetRow, ...
    specificColumns)
tagPrefixMap = createTagPrefixMap(specificColumns);
numberOfColumns = length(spreadsheetRow);
for a = 1:numberOfColumns
    if isKey(tagPrefixMap, a)
        columnTags = spreadsheetRow{a};
        if ~isempty(columnTags)
            splitColumnTags = strsplit(columnTags, ',');
            numberOfColumnTags = length(splitColumnTags);
            for b = 1:numberOfColumnTags
                columnTag = splitColumnTags{b};
                prefix = tagPrefixMap(a);
                if ~strncmpi(columnTag, prefix, length(columnTag))
                    splitColumnTags{b} = [prefix, columnTag]; 
                end
            end
            spreadsheetRow{a} = strjoin(splitColumnTags, ',');
        end
    end
end
end % appendTagPrefixes

