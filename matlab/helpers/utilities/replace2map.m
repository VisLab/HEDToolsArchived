% This function takes in a replace file and stores the old HED to new HED
% tag mappings in a Map object.
%
% Usage:
%
%   >>  replaceMap = replace2map(replaceFile)
%
% Input:
%
%   replaceFile
%                   The name or the path of the map file containing
%                   the mappings of old tags to new tags. This
%                   file is a two column tab-separated file with the old
%                   HED tags in one column and the new HED tags in another
%                   column.
% Output:
%
%   replaceMap
%                   A Map object the contains the old to new tag
%                   mappings from the HED replace file. The old tags will
%                   be the keys and the new tags will be the values.
%
% Examples:
%                   To create a replace Map object 'replaceMap' from the
%                   HED replace file 'HED1To2Replace.txt'.
%
%                   replaceMap = replace2map('HED1To2Replace.txt')
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

function replaceMap = replace2map(replaceFile)
p = parseArguments(replaceFile);
replaceMap = putInMap(p);

    function p = parseArguments(replaceFile)
        % Parses the input arguments and returns the results
        p = inputParser();
        p.addRequired('replaceFile', @(x) ~isempty(x) && ischar(x));
        p.parse(replaceFile);
        p = p.Results;
    end % parseArguments

    function replaceMap = putInMap(p)
        % Put each line of a remap file in a hash map
        replaceMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
        try
            fileId = fopen(p.replaceFile);
            tLine = fgetl(fileId);
            while ischar(tLine)
                if ~isempty(tLine)
                    [originalTag, replacementTag] = parseLine(tLine);
                    if ~isempty(originalTag) && ~isempty(replacementTag)
                        replaceMap(lower(originalTag)) = replacementTag;
                    end
                end
                tLine = fgetl(fileId);
            end
            fclose(fileId);
        catch ME
            if fileId ~= -1
                fclose(fileId);
            end
            throw(ME);
        end
    end % putInMap

    function [originalTag, replacementTag] = parseLine(tLine)
        % Parses the replace file line
        [originalTag, replacementTag] = strtok(tLine, char(9));
        originalTag = strtrim(originalTag);
        if originalTag(1) == '/'
            originalTag = originalTag(2:end);
        end
        replacementTag = strtrim(replacementTag);
    end % parseLine

end % replace2map