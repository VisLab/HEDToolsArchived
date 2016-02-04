% This function converts a boolean search string into a short-circuit
% logical expression.
%
% Usage:
%
%   >>  exp = createlogexp(numGroups, search)
%
% Inputs:
%
%   numgroups    The number of tag groups in the event.
%
%   search       A search string consisting of tags to extract data epochs.
%                The tag search uses boolean operators (AND, OR, NOT) to
%                widen or narrow the search. Two tags separated by a comma
%                use the AND operator by default which will only return
%                events that contain both of the tags. The OR operator
%                looks for events that include either one or both tags
%                being specified. The NOT operator looks for events that
%                contain the first tag but not the second tag. Groups can
%                also be searched for by enclosing the tags in parentheses.
%                The operators explained above also apply to tags in
%                groups. To nest or organize the search statements use
%                square brackets. Nesting will change the order in which
%                the search statements are evaluated. For example,
%                "/attribute/visual/color/green AND
%                [/item/2d shape/rectangle/square OR
%                /item/2d shape/ellipse/circle]".
%
% Outputs:
%
%  exp           A short-circuit logical expression that will be evaluated.
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function exp = createlogexp(numgroups, search)
inGroup = false;
groupIndex = 1;
tagsAndDelimiters = splitTagsAndDelimiters(search);
exp = translateSearchExpression(tagsAndDelimiters);

    function str = translateSearchExpression(tagsAndDelimiters)
        % Creates a tag search expression that will be evaluated
        str = translateSearchComponents(tagsAndDelimiters{1});
        for a = 2:length(tagsAndDelimiters);
            str = [str ' ' ...
                translateSearchComponents(tagsAndDelimiters{a})]; %#ok<AGROW>
        end
    end % translateSearchExpression

    function tagsAndDelimiters = splitTagsAndDelimiters(boolean)
        % Splits the search string into a cell array containing all tags,
        % operators, and delimiters
        tagsAndDelimiters = {};
        delimAndOperators = {',', '(', ')', '[', ']', 'AND', 'OR', 'NOT'};
        [cellTags, cellDelimiters] = strsplit(boolean, ...
            delimAndOperators, 'CollapseDelimiters',false);
        lastTag = max(find(~cellfun(@isempty, cellTags))); %#ok<MXFND>
        delimiterPos = 1;
        for a = 1:length(cellTags)
            if isempty(strtrim(cellTags{a}));
                tagsAndDelimiters{end+1} = ...
                    strtrim(cellDelimiters{delimiterPos}); %#ok<AGROW>
                delimiterPos = delimiterPos + 1;
            else
                tagsAndDelimiters{end+1} = ...
                    strtrim(cellTags{a}); %#ok<AGROW>
                if  a ~= lastTag
                    tagsAndDelimiters{end+1} = ...
                        strtrim(cellDelimiters{delimiterPos}); %#ok<AGROW>
                    delimiterPos = delimiterPos + 1;
                end
            end
        end
        tagsAndDelimiters = putGroupsInCells(tagsAndDelimiters);
    end % splitTagsAndDelimiters

    function groupTagsAndDelimiters = putGroupsInCells(tagsAndDelimiters)
        % Puts tag groups in cellstrs
        groupTagsAndDelimiters = {};
        inGroup = false;
        group = {};
        for a = 1:length(tagsAndDelimiters)
            if tagsAndDelimiters{a} == '('
                group{end+1} = tagsAndDelimiters{a}; %#ok<AGROW>
                inGroup = true;
            elseif tagsAndDelimiters{a} == ')'
                group{end+1} = tagsAndDelimiters{a}; %#ok<AGROW>
                groupTagsAndDelimiters{end+1} = group; %#ok<AGROW>
                group = {};
                inGroup = false;
            elseif inGroup
                group{end+1} = tagsAndDelimiters{a}; %#ok<AGROW>
            else
                groupTagsAndDelimiters{end+1} = ...
                    tagsAndDelimiters{a}; %#ok<AGROW>
            end
        end
    end % putGroupsInCells

    function translatedComponent = translateSearchComponents(component)
        % Translates search component based on rules and syntax
        if iscellstr(component)
            translatedComponent = translateTagGroup(component);
        elseif isSpecialCharacter(component) || isOperator(component)
            translatedComponent = translateOperator(component);
        else
            translatedComponent = translateTag(component);
        end
    end % translateSearchComponents

    function translatedOperator = translateOperator(operator)
        % Translates a operator into a string
        switch(operator)
            case 'AND'
                translatedOperator = '&&';
            case 'OR'
                translatedOperator = '||';
            case'NOT'
                translatedOperator = '&& ~';
            case ','
                translatedOperator = '&&';
            otherwise
                translatedOperator = operator;
        end
    end % translateOperators

    function translatedTag = translateTag(tag)
        % Translates a tag into a string
        if inGroup
            translatedTag = searchGroupTags(tag);
        else
            translatedTag = searchAllTags(tag);
        end
    end % translateTag

    function translatedGroup = translateTagGroup(tagGroup)
        % Translates a tag group into a string
        inGroup = true;
        translatedGroup = translateSearchExpression(tagGroup);
        for groupIndex = 2:numgroups %#ok<FXUP>
            translatedGroup = [translatedGroup ' || ' ...
                translateSearchExpression(tagGroup)]; %#ok<AGROW>
        end
        translatedGroup = ['(' translatedGroup ')'];
        inGroup = false;
        groupIndex = 1;
    end % translateTagGroup

    function specialCharacter = isSpecialCharacter(string)
        % Returns true if the string is a operator or a special character
        specialCharacter = isNestingCharacter(string) || ...
            isGroupCharacter(string) || isComma(string);
    end % isSpecialCharacter

    function groupCharacter = isGroupCharacter(string)
        % Returns true if the string is a group character
        groupChars = {'(', ')'};
        groupCharacter = any(strcmp(groupChars, string));
    end % isGroupCharacter

    function nestingCharacter = isNestingCharacter(string)
        % Returns true if the string is a nesting character
        nestingChars = {'[', ']'};
        nestingCharacter = any(strcmp(nestingChars, string));
    end % isNestingCharacter

    function comma = isComma(string)
        % Returns true if the string is a comma
        comma = any(strcmp(',', string));
    end % isComma

    function operator = isOperator(string)
        % Returns true if the string is a boolean operator
        operators = {'AND', 'OR', 'NOT'};
        operator = any(strcmp(operators, string));
    end % isOperator

    function sequence = searchAllTags(search)
        % Searches for a tag in all event tags
        search = tagList.getCanonical(search);
        sequence = sprintf('exactmatch(tags, ''%s'')', search);
    end % searchAllTags

    function sequence = searchGroupTags(search)
        % Searches for a tag in all event tag groups
        search = tagList.getCanonical(search);
        sequence = sprintf('exactmatch(groupTags{%d}, ''%s'')', ...
            groupIndex, search);
    end % searchGroupTags

end % createlogexp