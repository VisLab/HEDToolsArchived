% This function uses a tab-separated text HED replace file to check which
% tags in the old HED XML file are mapped and which tags are not mapped to
% a new HED tag or a list of new HED tags. If a old HED tag is not mapped
% in the HED replace file then the new HED XML file will be checked to see
% if it contains the old HED tag and if found then the tag will be mapped
% to itself.
%
% Usage:
%
%   >>  createmap(oldHED, newHED, replaceFile)
%
%   >>  createmap(oldHED, newHED, replaceFile, 'key1', 'value1', ...)
%
% Input:
%
%   oldHED          The name or the path to the HED XML file containing
%                   the old HED tags.
%
%   newHED          The name or the path to the HED XML file containing
%                   the new HED tags.
%
%   replaceFile     
%                   The name or the path of the tab-separated HED replace
%                   file containing the mapping of old HED tags to new HED
%                   tags. The replace file will generally not contain all
%                   of the old HED tags. The replace file accepts wilcards
%                   (*) which can be used to specify anything that matches
%                   a particular tag prefix in a old and new HED tag.
%
%   Optional (key/value):
%
%   'output'    
%                   The name or the path to the file that the output is
%                   written to. The output file will be a tab-separated
%                   text file consisting of two columns. The first column
%                   will contain all of the old HED tags from the HED XML
%                   file 'oldHed'. The second column will contain the new
%                   HED tags from the HED XML file 'newHed'. If there is no
%                   mapping then the second column will be empty and there
%                   will need to be a mapping specified by the user.
%
% Examples:
%                   To use the replace file 'HEDReplace.txt' to check which
%                   old HED tags have or have not been mapped in the HED
%                   XML file 'HED1.3.xml' to new HED tags in the HED XML
%                   file 'HED2.026.xml'.
%
%                   createhedmap('HED1.3.xml', 'HED2.026.xml', ...
%                   'HEDReplace.txt');
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

function createhedmap(oldHED, newHED, replaceFile, varargin)
p = parseArguments(oldHED, newHED, replaceFile, varargin{:});
hedMaps = mapattributes(newHED);
tagMap = hedMaps.tags;
replaceMap = replace2map(replaceFile);
wildcardTags = getWildcardTags(replaceMap);
takeValueTags = getTakeValueTags(replaceMap);
hedMaps = mapattributes(oldHED);
mapValues = hedMaps.tags.values();
output = generateOutput(mapValues);
writeOutput(output);

    function replaceTags = checkReplaceTag(tag)
        % Checks to see if the old HED tag has been mapped to a new HED tag
        try
            replaceTags = strjoin(replaceMap(lower(tag)), ',');
        catch
            replaceTags = checkWildcardTags(tag);
            if isempty(replaceTags)
                replaceTags = checkTakeValueTags(tag);
                if isempty(replaceTags)
                    try
                        replaceTags = tagMap(lower(tag));
                    catch
                    end
                end
            end
        end
    end % checkReplaceTag

    function replaceTags = checkTakeValueTags(tag)
        % Checks to see if the tag being looked for takes a value which
        % ends with a #
        replaceTags = '';
        [~, endIndexes] = regexpi(tag, takeValueTags);
        takeValueTag = takeValueTags(~cellfun(@isempty, endIndexes));
        endIndex = endIndexes(~cellfun(@isempty,endIndexes));
        if ~isempty(takeValueTag) && ~isempty(endIndex)
            replaceStr = tag(endIndex{1}+1:end);
            replaceTags = replaceMap([takeValueTag{1} '/#']);
            replaceTags = cellfun(@(x) strrep(x, '/#', replaceStr), ...
                replaceTags, 'UniformOutput', false);
            replaceTags = strjoin(replaceTags, ',');
        end
    end % checkWildcardTags

    function replaceTags = checkWildcardTags(tag)
        % Checks to see if the tag being looked for is a wildcard which
        % ends with a *
        replaceTags = '';
        [~, endIndexes] = regexpi(tag, wildcardTags);
        wildcardTag = wildcardTags(~cellfun(@isempty, endIndexes));
        endIndex = endIndexes(~cellfun(@isempty, endIndexes));
        if ~isempty(wildcardTag) && ~isempty(endIndex)
            replaceStr = tag(endIndex{1}+1:end);
            replaceTags = replaceMap([wildcardTag{1} '/*']);
            replaceTags = cellfun(@(x) strrep(x, '/*', replaceStr), ...
                replaceTags, 'UniformOutput', false);
            replaceTags = strjoin(replaceTags, ',');
        end
    end % checkWildcardTags

    function output = generateOutput(mapValues)
        % Generates the output which will be written to a file
        output = '';
        for a = 1:length(mapValues)
            output = sprintf('%s', [output mapValues{a}]);
            remapTags = checkReplaceTag(mapValues{a});
            if ~isempty(remapTags)
                output = sprintf('%s\t%s', output, remapTags);
            end
            output = sprintf('%s\n', output);
        end
    end % generateOutput

    function wildcardTags = getWildcardTags(replaceMap)
        % Gets all of the tags that are wildcards from the replace file
        remapKeys = replaceMap.keys();
        wildcardTags = remapKeys(~cellfun(@isempty, ...
            regexp(remapKeys, '/\*$')));
        wildcardTags =  cellfun(@(x) strrep(x, '/*', ''), wildcardTags, ...
            'UniformOutput', false);
    end % getWildcardTags

    function takeValueTags = getTakeValueTags(replaceMap)
        % Gets all of the tags that take in a value from the replace file
        remapKeys = replaceMap.keys();
        takeValueTags = remapKeys(~cellfun(@isempty, ...
            regexp(remapKeys, '/\#$')));
        takeValueTags =  cellfun(@(x) strrep(x, '/#', ''), ...
            takeValueTags, 'UniformOutput', false);
    end % getTakeValueTags

    function p = parseArguments(oldHED, newHED, replaceFile, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('oldHED', @(x) ~isempty(x) && ischar(x));
        p.addRequired('newHED', @(x) ~isempty(x) && ischar(x));
        p.addRequired('replaceFile', @(x) ~isempty(x) && ischar(x));
        [path, file] = fileparts(replaceFile);
        p.addOptional('output', fullfile(path, [file '_output.txt']), ...
            @(x) ~isempty(x) && ischar(x));
        p.parse(oldHED, newHED, replaceFile, varargin{:});
        p = p.Results;
    end % parseArguments

    function writeOutput(output)
        % Writes the output to the file
        outputFile = p.output;
        fileId = fopen(outputFile,'w');
        fprintf(fileId, '%s', output);
        fclose(fileId);
    end % writeOutput

end % createhedmap