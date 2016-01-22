% GUI for input needed to create inputs for hedepoch.
%
% Options:
%
%   Time-locking A comma separated list of tags or a tag search string
%   HED tag(s)   consisting of tags to extract data epochs.
%                The tag search uses boolean operators (AND, OR, NOT) to
%                widen or narrow the search. Two tags separated by a comma
%                use the AND operator by default which will only return
%                events that contain both of the tags. The OR operator
%                looks for events that include either one or both tags
%                being specified. The NOT operator looks for events that
%                contain the first tag but not the second tag. To nest or
%                organize the search statements use square brackets.
%                Nesting will change the order in which the search
%                statements are evaluated. For example,
%                "/attribute/visual/color/green AND
%                [/item/2d shape/rectangle/square OR
%                /item/2d shape/ellipse/circle]".
%
%   Epoch limits Epoch latency limits [start end] in seconds relative to
%                the time-locking event. The default is [-1 2].
%
%   New dataset  New dataset name. The default is "[old_dataset] epochs".
%
%   Out-of-      [min max] data limits. If one positive value is given,
%   bounds EEG   the opposite value is used for lower bound. For example,
%   limits       use [-50 50].
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

function [canceled, tags, matchType, newName, timeLim, valueLim] = ...
    hedepoch_input(setname, uniquetags)

    function searchCallback(src, event) %#ok<INUSD>
        [searchCanceled, searchtags, searchmatchType] ...
            = hedsearch_input(uniquetags); ...
            if ~searchCanceled
            tagsObj = findobj('tag', 'tags'); ...
                set(tagsObj, 'string', searchtags); ...
                matchtypeObj = findobj('tag', 'matchtype'); ...
                set(matchtypeObj, 'string', searchmatchType);
            end
    end
geometry = { [2 1 0 0.5] [2 1 0.5] [2 1.5] [2 1 0.5] };
uilist = { { 'style' 'text'       'string' 'Time-locking HED tag(s)' } ...
    { 'style' 'edit'       'string' '' 'tag' 'tags' } ...
    { 'style' 'edit'       'string' '' 'tag' 'matchtype' ...
    'visible', 'off'} ...
    { 'style' 'pushbutton' 'string' '...' 'callback' @searchCallback } ...
    { 'style' 'text'       ...
    'string' 'Epoch limits [start, end] in seconds' } ...
    { 'style' 'edit'       'string' '-1 2' } ...
    { } ...
    { 'style' 'text'       'string' 'Name for the new dataset' } ...
    { 'style' 'edit'       ...
    'string'  fastif(isempty(setname), '', [ setname ' epochs' ]) } ...
    { 'style' 'text'       ...
    'string' 'Out-of-bounds EEG limits if any [min max]' } ...
    { 'style' 'edit'       'string' '' } { } };
result = inputgui( geometry, uilist, 'pophelp(''hedepoch_input'')', ...
    'Extract data epochs - pop_hedepoch()');
if isempty(result)
    tags = '';
    matchType = '';
    timeLim = '';
    newName = '';
    valueLim = '';
    canceled = true;
    return;
end
canceled = false;
tags = result{1};
if isempty(result{2})
    matchType = 'Exact';
else
    matchType = result{2};
end
if isempty(result{3})
    timeLim = [-1 2];
else
    timeLim = str2num(result{3});  %#ok<ST2NM>
end
newName = result{4};
if isempty(result{5})
    valueLim = [-Inf Inf];
else
    valueLim = str2num(result{5});  %#ok<ST2NM>
end

end % hedepoch_input