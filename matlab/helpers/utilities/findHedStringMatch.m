% This function looks to see if a query string partially or fully matches a
% HED string or a cell array of HED strings. If exlcusive tags are present
% in the HED string then matches to other tags are nullified if they are
% not specified in the query string.
%
% Usage:
%
%   >>  matchMask = findHedStringMatch(hedStrings, queryHedString
%
% Input:
%
% hedStrings      
%                 A HED string or a cell array of HED strings. This
%                 function will check whether they match a query string.
%
% queryHedString  
%                A query string consisting of tags that you want to search
%                for. Two tags separated by a comma use the AND operator
%                by default, meaning that it will only return a true match
%                if both the tags are found. The OR (||) operator returns
%                a true match if either one or both tags are found.
%
% Optional
%
%   exclusiveTags
%                A cell array of tags that nullify matches to other tags.
%                If these tags are present in both the query string and the
%                HED string then a match will be returned.
%                By default, this argument is set to
%                {'Attribute/Intended effect', 'Attribute/Offset',
%                'Attribute/Participant indication'}.
%
% Output:
%
%   matchMask    A logical array the length of hedStrings with true values
%                where hedStrings matched queryHedString.
%
% Example
%
% >> matchMask = match_hed({'a' 'a/b/c' 'b/d/d'}, 'b')
% >> matchMask =
%
%      0
%      0
%      1
%
% Copyright (C) 2018
% Nima Bigdely Shamlo
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function matchMask = findHedStringMatch(hedStrings, queryHedString, ...
    varargin)
inputArguments = parseInputArguments(hedStrings, queryHedString, ...
    varargin{:});
exlcusiveTagsArgument = 'exclusiveTags';
orOperator = '||';
if ischar(hedStrings)
    hedStrings = {hedStrings};
end
[uniuqeHedStrings, ~, ids] = unique(hedStrings);
matchMask = false(length(hedStrings), 1);
for i = 1:length(uniuqeHedStrings)
    if strcmp(strtrim(uniuqeHedStrings{i}), strtrim(queryHedString))
        matchMask(ids == i) = true;
        break;
    end
    if isempty(strfind(lower(queryHedString), orOperator))
        matchMask(ids == i) =  findhedevents(uniuqeHedStrings{i}, ...
            queryHedString, exlcusiveTagsArgument, ...
            inputArguments.exclusiveTags);
    else
        queryParts  = strsplit(lower(queryHedString), orOperator);
        matchMask(ids == i) = false;
        for j=1:length(queryParts)
            matchMask(ids == i) = matchMask(ids == i) | ...
                findhedevents(uniuqeHedStrings{i}, queryParts{j}, ...
                exlcusiveTagsArgument, inputArguments.exclusiveTags);
        end
    end
end

    function inputArguments = parseInputArguments(hedStrings, ...
            queryString, varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addRequired('hedStrings', @(x) ischar(x) || iscellstr(x));
        parser.addRequired('queryString', @ischar);
        parser.addOptional('exclusiveTags', ...
            {'Attribute/Intended effect', 'Attribute/Offset', ...
            'Attribute/Participant indication'}, @iscellstr);
        parser.parse(hedStrings, queryString, varargin{:});
        inputArguments = parser.Results;
    end % parseInputArguments

end % findHedStringMatch