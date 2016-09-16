% This function remaps the tags in a ESS structure object.
%
% Usage:
%
%   >>  ESS = replaceess(replaceFile, ESS);
%
%   >>  ESS = replaceess(replaceFile, ESS, 'key1', 'value1', ...);
%
% Input:
%
%       replaceFile
%                   The name or the path of the replace file containing
%                   the mappings of old HED tags to new HED tags. This
%                   file is a two column tab-delimited file with the old
%                   HED tags in the first column and the new HED tags are
%                   in the second column.
%
%       ESS
%                   An ESS structure containing HED tags.
%
% Output:
%
%       ESS
%                   An ESS structure containing the replaced HED tags.
%
% Examples:
%                   To replace the old HED tags in Five-Box task ESS 
%                   structure with new HED tags in the .
%
%                   replaceess('Five-Box_remap.tsv', ...
%                   'study_description.xml');
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

function ESS = replaceess(replaceFile, ESS)
p = parseArguments(replaceFile, ESS);
replaceMap = remap2Map(p.replaceFile);
ESS.eventCodesInfo = readEventCodes(p.ESS.eventCodesInfo, replaceMap);

    function p = parseArguments(replaceFile, ESS)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('replaceFile', @(x) ~isempty(x) && ischar(x));
        p.addRequired('ESS', @(x) ~isempty(x));
        p.parse(replaceFile, ESS);
        p = p.Results;
    end % parseArguments

    function eventCodes = readEventCodes(eventCodes, replaceMap)
        % Reads the tag columns from a tab-delimited row
        numEvents = length(eventCodes);
        for a = 1:numEvents
            strTags = eventCodes(a).condition.tag;
            if ~isempty(strTags)
                cellTags = hed2cell(strTags, true);
                replacedCellTags = replaceTags(cellTags, replaceMap);
                replacedStrTags = cell2str(replacedCellTags);
                eventCodes(a).condition.tag = replacedStrTags;
            end
        end
    end % readEventCodes

    function remappedTags = replaceTags(tags, replaceMap)
        % Remaps the old tags with the new tags
        remappedTags = {};
        for a = 1:length(tags)
            if iscellstr(tags{a})
                remappedTags{end+1} = replaceTags(tags{a}); %#ok<AGROW>
            else
                if replaceMap.isKey(lower(tags{a}))
                    remappedTags{end+1} = ...
                        replaceMap(lower(tags{a}));   %#ok<AGROW>
                else
                    remappedTags{end+1} = tags{a}; %#ok<AGROW>
                end
            end
        end
    end % replaceTags

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

end % remapESSTags