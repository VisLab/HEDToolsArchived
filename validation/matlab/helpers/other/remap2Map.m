% This function takes in a remap file and stores the old HED to new HED
% tag mappings in a Map object.
%
% Usage:
%   >>  remapMap = remap2map(remapFile);
%
% Input:
%       'remap'     The name or the path of the map file containing
%                   the mappings of old tags to new tags. This
%                   file is a two column tab-delimited file with the old
%                   HED tags in one column and the new HED tags in another
%                   column.
% Output:
%       'remapMap'  A Map object the contains the old to new tag
%                   mappings from the HED remap file. The old tags will
%                   be the keys and the new tags will be the values.
%
% Examples:
%                   To create a remap Map object 'remapMap' from the HED
%                   remap file 'HEDRemap.txt'.
%
%                  remapMap = remap2map('HED1To2Remap.txt')
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

function remap = remap2Map(remapFile)
p = parseArguments();
remap = containers.Map('KeyType', 'char', 'ValueType', 'any');
putInMap();

    function p = parseArguments()
        % Parses the input arguments and returns the results
        p = inputParser();
        p.addRequired('remapFile', @(x) ~isempty(x) && ischar(x));
        p.parse(remapFile);
        p = p.Results;
    end % parseArguments

    function putInMap()
        % Put each line of a remap file in a hash map
        try
            fileId = fopen(p.remapFile);
            tLine = fgetl(fileId);
            while ischar(tLine)
                if ~isempty(tLine)
                    [originalTag, replacementTag] = parseLine(tLine);
                    if ~isempty(originalTag) && ~isempty(replacementTag)
                        remap(lower(originalTag)) = replacementTag;
                    end
                end
                tLine = fgetl(fileId);
            end
            fclose(fileId);
        catch me
            fclose(fileId);
            rethrow(me);
        end
    end % putInMap

    function [originalTag, replacementTag] = parseLine(tLine)
        % Parses the map file line
        [originalTag, replacementTag] = strtok(tLine, char(9));
        originalTag = strtrim(originalTag);
        replacementTag = strtrim(replacementTag);
    end % parseLine

end % remap2map