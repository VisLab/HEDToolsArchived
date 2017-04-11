% This function takes in a file containing the HED tags associated with a
% particular study and replaces the old HED tags with the new HED tags
% that are specified in a remap file.
%
% Usage:
%
%   >>  replacetsv(replaceFile, tsvFile, tagColumns)
%
%   >>  replacetsv(replaceFile, tsvFile, tagColumns, 'key1', 'value1', ...)
%
% Input:
%
%   replaceFile
%                   The name or the path of the remap file containing
%                   the mappings of old HED tags to new HED tags. This
%                   file is a two column tab-delimited file with the old
%                   HED tags in the first column and the new HED tags are
%                   in the second column.
%
%   tsvFile
%                   The name or the path of a tab-delimited text file
%                   containing HED tags associated with a particular study
%                   or experiment.
%
%   tagColumns
%                   The columns that contain the study or experiment HED
%                   tags. The columns can be a scalar value or a vector
%                   (e.g. 2 or [2,3,4]).
%
%   Optional (key/value):
%
%   'hasHeader'
%                   True(default)if the tab-delimited file containing
%                   the HED study tags has a header. The header will be
%                   skipped and not validated. False if the file doesn't
%                   have a header.
%
%   'outputFile'
%                   The name or the path to the file that the output is
%                   written to. The output file will be a tab-delimited
%                   text file consisting of the new HED tags which replaced
%                   the old HED tags in each specified columns.
%
% Examples:
%                   To replace the old HED tags in file
%                   'Reward Two Back Study.txt' with new HED tags in the
%                   fourth column using HED remap file 'HEDRemap.txt'.
%
%                   replacetsv('HEDRemap.txt', ...
%                   'Reward Two Back Study.txt', 4)
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

function replacetsv(replaceFile, tsvFile, tagColumns, varargin)
p = parseArguments(replaceFile, tsvFile, tagColumns, varargin{:});
p.output = '';
p.replaceMap = replace2map(p.replaceFile);
p.wildCardTags = getWildCardTags(p);
try
    inputFileId = fopen(p.tsvFile);
    [p.output, p.tLine] = checkForHeader(p, inputFileId);
    while ischar(p.tLine)
        p.output = readTags(p);
        p.tLine = fgetl(inputFileId);
    end
    fclose(inputFileId);
    writeOutput(p)
catch ME
    fclose(inputFileId);
    throw(ME);
end

    function [output, tLine] = checkForHeader(p, fileId)
        % Checks to see if the file has a header line
        tLine = fgetl(fileId);
        output = p.output;
        if p.hasHeader
            output = sprintf('%s\n', tLine);
            tLine = fgetl(fileId);
        end
    end % checkForHeader

    function tagStr = convertTag(tag)
        % Converts a cell array containing a tag or a tag group into a
        % string
        if iscellstr(tag)
            tagStr = joinTagGroup(tag);
        else
            tagStr = tag;
        end
    end % convertTag

    function wildCardTags = getWildCardTags(p)
        keys = p.replaceMap.keys();
        wildCardTags = keys(cellfun(@(x) ~isempty(strfind(x, '*')), keys));
        wildCardTags = cellfun(@(x) x(1:end-1), ...
            wildCardTags, 'UniformOutput', false);
    end % getWildCardTags

    function found = isWildCardTag(p, tag)
        % Checks to see if tag is a wildcard tag
        matches = cellfun(@(x) strncmp(x, tag, length(x)), ...
            p.wildCardTags);
        found = any(matches);
    end % isWildCardTag

    function groupStr = joinTagGroup(group)
        % Joins a cell array containing a tag group into a comma delimited
        % string
        numTags = size(group, 2);
        groupStr = ['(' group{1}];
        previousTag = false;
        for a = 2:numTags
            if strcmp('~', group{a})
                previousTag = false;
                groupStr = [groupStr ' ' group{a}]; %#ok<AGROW>
            elseif previousTag
                groupStr = [groupStr ',' group{a}]; %#ok<AGROW>
            else
                groupStr = [groupStr ' ' group{a}]; %#ok<AGROW>
                previousTag = true;
            end
        end
        groupStr = [groupStr ')'];
    end % joinTagGroup

    function p = parseArguments(replaceFile, tsvFile, tagColumns, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('replaceFile', @(x) ~isempty(x) && ischar(x));
        p.addRequired('tsvFile', @(x) ~isempty(x) && ischar(x));
        p.addRequired('tagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        [path, file] = fileparts(tsvFile);
        p.addParamValue('hasHeader', true, @islogical);
        p.addParamValue('outputFile', ...
            fullfile(path, [file '_update.tsv']), ...
            @(x) ~isempty(x) && ischar(x));
        p.parse(replaceFile, tsvFile, tagColumns, varargin{:});
        p = p.Results;
    end % parseArguments

    function output = readTags(p)
        % Reads the tag columns from a tab-delimited row
        splitLine = textscan(p.tLine, '%s', 'delimiter', '\t', ...
            'multipleDelimsAsOne', 1)';
        numCols = size(splitLine{1}, 1);
        for a = 1:numCols
            if ismember(a, p.tagColumns)
                splitTags = splitLine{1}{a};
                splitCellTags = hed2cell(splitTags, true);
                replacedTags = replaceTags(p, splitCellTags);
                replacedTags = vTagList.stringify(replacedTags);
                p.output = sprintf('%s%s\t', p.output, replacedTags);
            else
                p.output = sprintf('%s%s\t', p.output, splitLine{1}{a});
            end
        end
        output = sprintf('%s\n', p.output);
    end % readTags

    function tags = replaceTags(p, tags)
        % Replaces the old tags with the new tags
        numTags = length(tags);
        for a = 1:numTags
            if iscell(tags{a})
                tags{a} = replaceTags(p, tags{a});
                continue;
            elseif p.replaceMap.isKey(lower(tags{a}))
                tags{a} = p.replaceMap(lower(tags{a}));
            elseif isWildCardTag(p, lower(tags{a}))
                tags{a} = ...
                    replaceWildCardTag(lower(tags{a}));
            end
        end
    end % replaceTags

    function replacementTag = replaceWildCardTag(p, tag)
        % Replaces the wildcard tag with new remap tag
        matchedTag = p.wildCardTags(cellfun(@(x) strncmp(x, tag, ...
            length(x)), p.wildCardTags));
        matchedTag = matchedTag{1};
        numCharacters = length(matchedTag);
        restOfTag = tag(numCharacters+1:end);
        valueTag = p.replaceMap([matchedTag '*']);
        replacementTag = strrep(valueTag, '*', restOfTag);
    end % replaceWildCardTag

    function writeOutput(p)
        % Writes the output to the file
        outputFileId = fopen(p.outputFile,'w');
        p.output = regexprep(p.output,'\n$', '');
        fprintf(outputFileId, '%s', p.output);
        if outputFileId ~= -1
            fclose(outputFileId);
        end
    end % writeOutput

end % replacetsv