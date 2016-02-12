% This function takes in a file containing the HED tags associated with a
% particular study and replaces the old HED tags with the new HED tags
% that are specified in a remap file.
%
% Usage:
%
%   >>  remapTSVTags(remapFile, tsvFile, tsvTagColumns);
%
%   >>  remapTSVTags(remapFile, tsvFile, tsvTagColumns, varargin);
%
% Input:
%
%       remapFile
%                   The name or the path of the remap file containing
%                   the mappings of old HED tags to new HED tags. This
%                   file is a two column tab-delimited file with the old
%                   HED tags in the first column and the new HED tags are
%                   in the second column.
%
%       tsvFile
%                   The name or the path of a tab-delimited text file
%                   containing HED tags associated with a particular study
%                   or experiment.
%
%       tsvTagColumns
%                   The columns that contain the study or experiment HED
%                   tags. The columns can be a scalar value or a vector
%                   (e.g. 2 or [2,3,4]).
%
%       Optional:
%
%       'outputFile'
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
%                   remapTSVTags('HEDRemap.txt', ...
%                   'Reward Two Back Study.txt', 4)
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
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

function outStruct = remapStructTags(remapFile, essStruct)
p = parseArguments();
outStruct = essStruct;
remapMap = remap2Map(p.remapFile);
outStruct.eventCodes.eventCode = ...
    readEventCodes(essStruct.eventCodes.eventCode);

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('remapFile', @(x) ~isempty(x) && ischar(x));
        p.addRequired('essStruct', @(x) ~isempty(x) && isstruct(x));
        p.parse(remapFile, essStruct);
        p = p.Results;
    end % parseArguments

    function eventCodes = readEventCodes(eventCodes)
        % Reads the tag columns from a tab-delimited row
        numEvents = size(eventCodes, 1);
        for a = 1:numEvents
            fprintf('a: %d\n', a);
            strTags = eventCodes(a).condition.tag;
            if ~isempty(strTags)
                cellTags = str2cell(strTags);
                replacedCellTags = remapTags(cellTags);
                replacedStrTags = cell2str(replacedCellTags);
                eventCodes(a).condition.tag = replacedStrTags;
            end
        end
    end % readEventCodes

    function remappedTags = remapTags(tags)
        % Remaps the old tags with the new tags
        remappedTags = {};
        for a = 1:length(tags)
            if iscellstr(tags{a})
                remappedTags{end+1} = remapTags(tags{a}); %#ok<AGROW>
            else
                if remapMap.isKey(lower(tags{a}))
                    remappedTags{end+1} = ...
                        remapMap(lower(tags{a}));   %#ok<AGROW>
                else
                    remappedTags{end+1} = tags{a}; %#ok<AGROW>
                end
            end
        end
    end % remapTags

    function tags = str2cell(tags)
        % Converts the tags from a string to a cell array
        tags = formatTags(tags, true);
    end % str2cell

    function tagStr = cell2str(tags)
        % Converts the tags from a cell array to a string
        numTags = size(tags, 2);
        tagStr = convertTag(tags{1});
        for a = 2:numTags
            tagStr = [tagStr ', ' convertTag(tags{a})]; %#ok<AGROW>
        end
    end % cell2str

    function tagStr = convertTag(tag)
        % Converts a cell array containing a tag or a tag group into a string
        if iscellstr(tag)
            tagStr = joinTagGroup(tag);
        else
            tagStr = tag;
        end
    end % convertTag

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

end % remapStructTags