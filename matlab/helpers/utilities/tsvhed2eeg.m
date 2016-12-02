% Reads in a tab-separated file containing HED tags and writes them to a
% EEG event structure with matching field values.
%
% Usage:
%
%   >>  EEG = tsvhed2eeg(EEG, tsvfile)
%
%   >>  EEG = tsvhed2eeg(EEG, tsvfile, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   EEG
%                    A EEG structure that contains matching event types
%                    (codes).
%
%   tsvfile
%                    The full path of a tab-separated file containing tags
%                    associated with the EEG dataset.
%
%   Optional (key/value):
%
%   EventsTagField
%                    The field name ('usertags' or 'hedtags') in the EEG
%                    events structure to write the tab-separated tags to.
%                    The default is 'usertags'.
%
%   EventsTagUpdateType
%                    The update type ('merge' or 'replace') that determines
%                    how to write the tags to the 'EventsTagField' field.
%                    The 'merge' update type merges the existing tags with
%                    the tags from the tab-separated file. The 'replace'
%                    update type replaces the existing tags with the tags
%                    from the tab-separated file.
%
%   EventsTsvTagField
%                    The field name in the EEG structure that is associated
%                    with the values in a tab-separated file. The default
%                    field name is 'type'.
%
%   TsvAttributeColumn
%                    The column in the tab-separated file reserved for the
%                    attribute tag. If the column value doesn't start with
%                    the prefix Attribute/ then it will be prepended to the
%                    column value.
%
%   TsvCategoryColumn
%                    The column in the tab-separated file reserved for the
%                    category tags. If the column values don't start with
%                    the prefix Event/Category/ then it will be prepended
%                    to the column values.
%
%   TsvDescriptionColumn
%                    The column in the tab-separated file reserved for the
%                    description tag. If the column value doesn't start
%                    with the prefix Event/Description/ then it will be
%                    prepended to the column value.
%
%   TsvEventColumn
%                    The column in the tab-separated file used to identify
%                    the events in the EEG structure. This is a
%                    scalar integer. The default is 1 which is the first
%                    column.
%
%   TsvFileHasHeader
%                   True, which is the default if the the tab-separated
%                   file has a header.
%
%   TsvLabelColumn
%                    The column in the tab-separated file reserved for the
%                    label tag. If the column value doesn't start
%                    with the prefix Event/Label/ then it will be
%                    prepended to the column value.
%
%   TsvLongnameColumn
%                    The column in the tab-separated file reserved for the
%                    longname tag. If the column value doesn't start
%                    with the prefix Event/Long name/ then it will be
%                    prepended to the column value.
%
%   TsvTagColumns
%                    The tag column(s) in the tab-separated file. This can
%                    be a scalar integer or an integer vector. The default
%                    is 2 which is the second column.
%
% Output:
%
%   EEG
%                    A EEG structure with the tab-separated tags written to
%                    its events.
%
% Examples:
%
%  Write HED tags in column '2' of a tab separated file
%  'BCI Data Specification.tsv' to an EEG structure containing matching
%  event types (codes) in column '1'.
%
%  EEG = tagtsv(EEG, 'BCI Data Specification.tsv', 'TsvEventColumn', 1,
%  'TsvTagColumns', 2)
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

function EEG = tsvhed2eeg(EEG, tsvfile, varargin)
p = parseArguments(EEG, tsvfile, varargin{:});
if ~isfield(EEG.event, p.EventsTsvTagField)
    warning(['Field "%s" is not present in the EEG event structure.' ...
        ' ... Exiting function '], p.EventsTsvTagField);
    return;
end
inputArgs = getkeyvalue({'TsvAttributeColumn', 'TsvCategoryColumn', ...
    'TsvDescriptionColumn', 'TsvEventColumn','EventsTsvTagField', ...
    'TsvFileHasHeader', 'TsvLabelColumn', 'TsvLongnameColumn', ...
    'TsvTagColumns'}, varargin{:});
tsvMap = tsvhed2map(tsvfile, inputArgs{:});
uniqueValues = tsvMap.getCodes();
numUniqueValues = length(uniqueValues);
[values, positions] = getValues(p, EEG);
merge = isfield(EEG.event, p.EventsTagField) && strcmp('merge', ...
    p.EventsTagUpdateType);
for a = 1:numUniqueValues
    matches = positions(strcmpi(uniqueValues{a}, values));
    tList = getValue(tsvMap, uniqueValues{a});
    if merge
        mergedTags = cellfun(@(x) sorttags(mergetagstrings(x, ...
            tagList.stringify(tList.getTags()), ...
            p.PreserveTagPrefixes)), ...
            {EEG.event(matches).(p.EventsTagField)}, 'UniformOutput', ...
            false);
        [EEG.event(matches).(EventsTagField)] = deal(mergedTags{:});
    else
        [EEG.event(matches).(p.EventsTagField)] = ...
            deal(sorttags(tagList.stringify(tList.getTags())));
    end
end

    function [values, positions] = getValues(p, EEG)
        % Get all the non-empty values and positions assoicated with a
        % particular field
        positions = find(arrayfun(@(x) ...
            ~isempty(x.(p.EventsTsvTagField)), EEG.event));
        values = {EEG.event(positions).(p.EventsTsvTagField)};
        values = cellfun(@num2str, values, 'UniformOutput', false);
    end % getValues

    function p = parseArguments(EEG, tsvfile, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('EEG', @(x) ~isempty(x) && ...
            isstruct(x) && isfield(x, 'event'));
        parser.addRequired('tsvfile', @(x) ~isempty(x) && ...
            ischar(tsvfile));
        parser.addParamValue('EventsTagField', 'usertags', @(x) ...
            any(validatestring(lower(x), {'hedtags', 'usertags'})));
        parser.addParamValue('EventsTagUpdateType', 'merge', ...
            @(x) any(validatestring(lower(x), {'merge', 'replace'})));
        parser.addParamValue('EventsTsvTagField', 'type', @(x) ...
            ~isempty(x) && ischar(x));
        parser.addParamValue('PreserveTagPrefixes', false, @islogical);
        parser.addParamValue('TsvAttributeColumn', [], @(x) ~isempty(x) ...
            && isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvCategoryColumn', [], @(x) ~isempty(x) ...
            && isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvDescriptionColumn', [], @(x) ...
            ~isempty(x) && isnumeric(x) && length(x) == 1 && ...
            rem(x,1) == 0);
        parser.addParamValue('TsvEventColumn', 1, @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvFileHasHeader', true, @islogical);
        parser.addParamValue('TsvLabelColumn', [], @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvLongnameColumn', [], @(x) ~isempty(x) ...
            && isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('TsvTagColumns', 2, @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) >= 1 && all(rem(x,1) == 0));
        parser.parse(EEG, tsvfile, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tsvhed2eeg