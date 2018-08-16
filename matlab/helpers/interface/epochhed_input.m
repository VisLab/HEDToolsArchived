% GUI for input needed to create inputs for epochhed.
%
% Menu Options:
%
%   Time-locking HED tag(s)
%                A query string consisting of tags that you want to search
%                for. Two tags separated by a comma use the AND operator
%                by default, meaning that it will only return a true match
%                if both the tags are found. The OR (||) operator returns
%                a true match if either one or both tags are found.
%
%   ...
%                Brings up search bar for specifiying Time-locking HED
%                tag(s).
%
%   Exclusive HED tag(s)
%                A comma-separated list of tags that nullify matches to
%                other tags. If these tags are present in both the EEG
%                dataset event tags and the tag string then a match will be
%                returned. The default is
%                'Attribute/Intended effect', 'Attribute/Offset'.
%
%   Epoch limits
%                Epoch latency limits [start end] in seconds relative to
%                the time-locking event. The default is [-1 2].
%
%   Name for the new dataset
%                The new dataset name. The default is "[old_dataset]
%                epochs".
%
%   Out-of-bounds EEG limits if any
%                [min max] data limits. If one positive value is given,
%                the opposite value is used for lower bound. For example,
%                use [-50 50].
%
% Outputs:
%
%   canceled
%                True if cancel was pressed in the menu.
%
%   querystring
%                A query string consisting of tags that you want to search
%                for. Two tags separated by a comma use the AND operator
%                by default, meaning that it will only return a true match
%                if both the tags are found. The OR (||) operator returns
%                a true match if either one or both tags are found.
%
%   exclusiveTags
%                A comma-separated list of tags that nullify matches to
%                other tags. If these tags are present in both the EEG
%                dataset event tags and the tag string then a match will be
%                returned. The default is
%                'Attribute/Intended effect', 'Attribute/Offset'.
%
%   newName
%                The new dataset name.
%
%   timeLim
%                Epoch latency limits [start end] in seconds relative to
%                the time-locking event {default: [-1 2]}
%
%   valueLim
%                Lower and upper bound latencies for trial data. Else if
%                one positive value is given, use its negative as the lower
%                bound. The given values are also considered outliers
%               (min max).
%
% Copyright (C) 2012-2017 Thomas Rognon tcrognon@gmail.com,
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

function [canceled, tagstring, exclusiveTags, newName, timeLim, ...
    valueLim] = epochhed_input(newName, tagstring, uniquetags)

    function searchCallback(src, event) %#ok<INUSD>
        [searchCanceled, tagstring] = hedsearch_input(uniquetags, ...
            tagstring); ...
            if ~searchCanceled
            tagsObj = findobj('tag', 'tagstring');
            set(tagsObj, 'string', tagstring);
            end
    end

    function tagsEditBoxCallback(src, ~)
        % Callback for user directly editing the HED XML editbox
        tagstring = get(src, 'String');
    end % hedEditBoxCallback

geometry = { [2 5 0.5] [2 5 0.5] [5 2 0.5] [4 3 0.5] [5 2 0.5] };
uilist = { { 'style' 'text'       'string' 'Time-locking HED tag(s)' } ...
    { 'style' 'edit'       'string' tagstring 'tag' 'tagstring' 'callback', ...
    @tagsEditBoxCallback} ...
    { 'style' 'pushbutton' 'string' '...' 'callback' @searchCallback } ...
    { 'style' 'text'       ...
    'string' 'Exclusive HED tag(s)' } ...
    { 'style' 'edit'       'string' ...
    'Attribute/Intended effect, Attribute/Offset, Attribute/Participant indication' } ...
    { } ...
    { 'style' 'text'       ...
    'string' 'Epoch limits [start, end] in seconds' } ...
    { 'style' 'edit'       'string' '-1 2' } ...
    { } ...
    { 'style' 'text'       'string' 'Name for the new dataset' } ...
    { 'style' 'edit'       ...
    'string'  fastif(isempty(newName), '', [ newName ' epochs' ]) } ...
    { } ...
    { 'style' 'text'       ...
    'string' 'Out-of-bounds EEG limits if any [min max]' } ...
    { 'style' 'edit'       'string' '' } { } };
result = inputgui( geometry, uilist, 'pophelp(''epochhed_input'')', ...
    'Extract data epochs - pop_epochhed()');
if isempty(result)
    tagstring = '';
    exclusiveTags = '';
    timeLim = '';
    newName = '';
    valueLim = '';
    canceled = true;
    return;
end
canceled = false;
tagstring = result{1};
exclusiveTags = strsplit(result{2}, ',');
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

end % epochhed_input