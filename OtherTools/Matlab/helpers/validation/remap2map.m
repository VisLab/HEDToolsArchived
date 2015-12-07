% This function takes in a HED remap file and stores the old HED to new HED
% tag mappings in a Map object.
%
% Usage:
%   >>  remapMap = remap2map(remapFile);
%
% Input:
%       'remap'     The name or the path of the HED remap file containing
%                   the mappings of old HED tags to new HED tags. This
%                   file is a two column tab-delimited file with the old
%                   HED tags in one column and the new HED tags in another
%                   column.
% Output:
%       'remapMap'  A Map object the contains the old HED to new HED tag
%                   mappings from the HED remap file. The old HED tags will
%                   be the keys and the new HED tags will be the values.
%
% Examples:
%                   To create a remap Map object 'remapMap' from the HED
%                   remap file 'HEDRemap.txt'.
%
%                  remapMap = remap2map('HEDRemap.txt')
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

function remapMap = remap2map(remap)
p = parseArguments();
tagColumns = [1,2];
remapMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
readRemapLines();

    function p = parseArguments()
        % Parses the input arguments and returns the results
        p = inputParser();
        p.addRequired('Remap', @(x) ~isempty(x) && ischar(x));
        p.parse(remap);
        p = p.Results;
    end % parseArguments

    function readRemapLines()
        % Read each line in the tab-delimited Remap file
        try
            fileId = fopen(p.Remap);
            tLine = fgetl(fileId);
            while ischar(tLine)
                if ~isempty(tLine)
                    tags = parseRemapTags(tLine, tagColumns);
                    remapMap(lower(tags{1})) = tags(2:end);
                end
                tLine = fgetl(fileId);
            end
            fclose(fileId);
        catch me
            fclose(fileId);
            rethrow(me);
        end
    end % readRemapLines

    function tags = parseRemapTags(tLine, columns)
        % Reads the remap tags from a give row in a tab-delimited file
        splitLine = strsplit(tLine, '\t');
        numCols = length(columns);
        splitTags = splitLine{columns(1)};
        for a = 2:numCols
            if length(splitLine) >= 2
                splitTags  = [splitTags, ',', ...
                    splitLine{columns(a)}]; %#ok<AGROW>
            end
        end
        tags = str2cell(splitTags);
    end % parseRemapTags

    function tagCell = str2cell(tagStr)
        % Converts the tags from a str to a cellstr and formats them
        tagCell = formatTags(tagStr, true);
    end % str2cell

end % remap2map