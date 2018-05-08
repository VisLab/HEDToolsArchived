% Splits up the tags in a HED string and returns diffferent types of tags.
%
% Usage:
%
%   >>  [tags, topLevelTags, groupTags, uniqueTags] = ...
%       hedStringDelimiter(hedString)
%
% Input:
%
%   Required:
%
%   hedString
%                    A HED string.
%
%   (Optional):
%
%   hedString
%                    A HED string.
%
%
% Output:
%
%   tags
%                    A cell array containing all the tags in the HED
%                    string.
%
%   topLevelTags
%                    A cell array containing all the top-level tags in the
%                    HED string.
%
%   groupTags
%                    A cell array containing all the group tags in the
%                    HED string.
%
%   uniqueTags
%                    A cell array containing all the unique tags in the
%                    HED string.
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

classdef HedStringDelimiter
    
    properties(Access=private)
        tags;
        topLevelTags;
        groupTags;
        uniqueTags;
        formattedTags;
        formattedTopLevelTags;
        formattedGroupTags;
        formattedUniqueTags;
    end % Private properties
    
    methods
        
        function obj = HedStringDelimiter(hedString)
            % HedStringDelimiter constructor
            obj.tags = hed2cell(hedString, false);
            obj.topLevelTags = obj.tags(cellfun(@ischar, obj.tags));
            obj.groupTags = obj.findGroupTags({}, obj.tags);
            obj.uniqueTags = obj.findUniqueTags(obj.tags);
            obj.formattedTags = hed2cell(hedString, true);
            obj.formattedTopLevelTags = obj.tags(cellfun(@ischar, ...
                obj.formattedTags));
            obj.formattedGroupTags = obj.findGroupTags({}, ...
                obj.formattedTags);
            obj.formattedUniqueTags = obj.findUniqueTags(obj.formattedTags);
        end % HedStringDelimiter
        
        function tags = getTags(obj)
            % Gets the tags
            tags = obj.tags;
        end % getTags
        
        function topLevelTags = getTopLevelTags(obj)
            % Gets the top-level tags
            topLevelTags = obj.topLevelTags;
        end % getTopLevelTags
        
        function groupTags = getGroupTags(obj)
            % Gets the group tags
            groupTags = obj.groupTags;
        end % groupTags
        
        function uniqueTags = getUniqueTags(obj)
            % Gets the unique tags
            uniqueTags = obj.uniqueTags;
        end % getUniqueTags
        
        
                function formattedTags = getFormattedTags(obj)
            % Gets the formatted tags
            formattedTags = obj.formattedTags;
        end % getFormattedTags
        
        function formattedTopLevelTags = getFormattedTopLevelTags(obj)
            % Gets the formatted top-level tags
            formattedTopLevelTags = obj.formattedTopLevelTags;
        end % getFormattedTopLevelTags
        
        function formattedGroupTags = getFormattedGroupTags(obj)
            % Gets the formatted group tags
            formattedGroupTags = obj.formattedGroupTags;
        end % getFormattedGroupTags
        
        function formattedUniqueTags = getFormattedUniqueTags(obj)
            % Gets the formattted unique tags
            formattedUniqueTags = obj.formattedUniqueTags;
        end % getFormattedUniqueTags
        
    end % Public methods
    
    methods(Access=private)
        
        
        function uniqueTags = findUniqueTags(obj, tags)
            % Finds all unique tags in a cell array
            [uniqueTags, nestedCellsPresent] = obj.unnestGroupTags(tags);
            while nestedCellsPresent
                [uniqueTags, nestedCellsPresent] = ...
                    unNestGroupTags(uniqueTags);
            end
            uniqueTags = unique(uniqueTags);
        end % getAllUniqueTags
        
        function groups = findGroupTags(obj, groups, tags)
            % Finds all tag groups in cell array
            numTags = length(tags);
            for tagIndex = 1:numTags
                if iscellstr(tags{tagIndex})
                    groups{end+1} = tags{tagIndex}; %#ok<AGROW>
                elseif iscell(tags{tagIndex})
                    groups{end+1} = tags{tagIndex}; %#ok<AGROW>
                    groups = getGroupTags(groups, tags{tagIndex});
                end
            end
        end % getAllGroups
        
        function [tags, nestedCellsPresent] = unnestGroupTags(obj, tags)
            % Unest group tags in cell array
            if ~iscellstr(tags)
                tags = [tags{:}];
            end
            nestedCellsPresent = ~iscellstr(tags);
        end % unNestGroupTags
        
    end % Private methods
    
end % HedStringDelimiter