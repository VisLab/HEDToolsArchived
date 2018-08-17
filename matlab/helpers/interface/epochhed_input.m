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
% Inputs:
%
%   canceled
%                True if cancel was pressed in the menu.
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
%   querystring
%                A query string consisting of tags that you want to search
%                for. Two tags separated by a comma use the AND operator
%                by default, meaning that it will only return a true match
%                if both the tags are found. The OR (||) operator returns
%                a true match if either one or both tags are found.
%
%   timelim
%                Epoch latency limits [start end] in seconds relative to
%                the time-locking event {default: [-1 2]}
%
%   uniquetags
%                    A cell string containing the unique HED tags in the 
%                    tags input argument.
%
%   valuelim
%                Lower and upper bound latencies for trial data. Else if
%                one positive value is given, use its negative as the lower
%                bound. The given values are also considered outliers
%               (min max).
%
% Outputs:
%
%   canceled
%                True if cancel was pressed in the menu.
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
%   querystring
%                A query string consisting of tags that you want to search
%                for. Two tags separated by a comma use the AND operator
%                by default, meaning that it will only return a true match
%                if both the tags are found. The OR (||) operator returns
%                a true match if either one or both tags are found.
%
%   timelim
%                Epoch latency limits [start end] in seconds relative to
%                the time-locking event {default: [-1 2]}
%
%   valuelim
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

function [canceled, querystring, exclusiveTags, newName, timelim, ...
    valuelim] = epochhed_input(varargin)
p = parseArguments(varargin{:});
    function searchCallback(src, event) %#ok<INUSD>
        [searchCanceled, querystring] = hedsearch_input(p.uniquetags, ...
            p.querystring); ...
            if ~searchCanceled
            tagsObj = findobj('tag', 'querystring');
            set(tagsObj, 'string', querystring);
            end
    end

    function tagsEditBoxCallback(src, ~)
        % Callback for user directly editing the HED XML editbox
        querystring = get(src, 'String');
    end % hedEditBoxCallback

geometry = { [2 5 0.5] [2 5 0.5] [5 2 0.5] [4 3 0.5] [5 2 0.5] };
uilist = { { 'style' 'text'       'string' 'Time-locking HED tag(s)' } ...
    { 'style' 'edit'       'string' p.querystring 'tag' 'querystring' ...
    'callback', @tagsEditBoxCallback} ...
    { 'style' 'pushbutton' 'string' '...' 'callback' @searchCallback } ...
    { 'style' 'text'       ...
    'string' 'Exclusive HED tag(s)' } ...
    { 'style' 'edit'       'string' ...
    strjoin(p.exclusivetags, ',')} ...
    { } ...
    { 'style' 'text'       ...
    'string' 'Epoch limits [start, end] in seconds' } ...
    { 'style' 'edit'       'string' num2str(p.timelim) } ...
    { } ...
    { 'style' 'text'       'string' 'Name for the new dataset' } ...
    { 'style' 'edit'       ...
    'string'  p.newname } ...
    { } ...
    { 'style' 'text'       ...
    'string' 'Out-of-bounds EEG limits if any [min max]' } ...
    { 'style' 'edit'       'string' num2str(p.valuelim) } { } };
result = inputgui( geometry, uilist, 'pophelp(''epochhed_input'')', ...
    'Extract data epochs - pop_epochhed()');
if isempty(result)
    querystring = '';
    exclusiveTags = '';
    timelim = '';
    newName = '';
    valuelim = '';
    canceled = true;
    return;
end
canceled = false;
querystring = result{1};
exclusiveTags = strsplit(result{2}, ',');
if isempty(result{3})
    timelim = [-1 2];
else
    timelim = str2num(result{3});  %#ok<ST2NM>
end
newName = result{4};
if isempty(result{5})
    valuelim = [-Inf Inf];
else
    valuelim = str2num(result{5});  %#ok<ST2NM>
end

    function p = parseArguments(varargin)
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addParamValue('exclusivetags', ...
            {'Attribute/Intended effect', 'Attribute/Offset', ...
            'Attribute/Participant indication'}, @iscellstr); %#ok<NVREPL>
        p.addParamValue('newname', '', @(x) ischar(x)); %#ok<NVREPL>
        p.addParamValue('querystring', '', @(x) ischar(x));
        p.addParamValue('timelim', [-1 2], @(x) isnumeric(x) && ...
            numel(x) == 2);
        p.addParamValue('uniquetags', '', @(x) iscellstr(x));
        p.addParamValue('valuelim', [-inf inf], ...
            @(x) isnumeric(x) && any(numel(x) == [1 2])) %#ok<NVREPL>
        p.parse(varargin{:});
        p = p.Results;
    end % parseArguments

end % epochhed_input