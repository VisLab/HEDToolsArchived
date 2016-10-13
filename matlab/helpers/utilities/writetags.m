% Writes tags to a structure from the fieldMap information. The tags in the
% dataset structure are written to the .etc field and in each individual
% event in the .event field.
%
% Usage:
%
%   >>  eData = writetags(eData, fMap)
%
%   >>  eData = writetags(eData, fMap, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   eData
%                    The structure that will be tagged. The
%                    dataset will need to have a .event field.
%
%   fMap
%                    A fieldMap object that stores all of the tags.
%
%   Optional (key/value):
%
%   'ExcludeFields'
%                    A cell array containing the field names to exclude.
%
%   'PreservePrefix' If false (default), tags associated with same value
%                    that share prefixes are combined and only the most
%                    specific is retained (e.g., /a/b/c and /a/b become
%                    just /a/b/c). If true, then all unique tags are
%                    retained.
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

function eData = writetags(eData, fMap, varargin)
p = parseArguments(eData, fMap, varargin{:});

if isfield(eData, 'event') && isstruct(eData.event)
    if ~isempty(p.Fields)
        tFields = intersect(fieldnames(eData.event), ...
            intersect(fMap.getFields(), p.Fields));
    else
        tFields = intersect(fieldnames(eData.event), ...
            setdiff(fMap.getFields(), p.ExcludeFields));
    end
    %     eFields = intersect(fieldnames(eData.event), tFields);
    eData = writeIndividualTags(eData, fMap, tFields, p.PreservePrefix);
else
    tFields = intersect(fMap.getFields(), p.Fields);
end
eData = writeSummaryTags(fMap, eData, tFields);

    function eData = writeIndividualTags(eData, fMap, eFields, ...
            preservePrefix)
        % Write tags to individual events in usertags field
        primaryField = fMap.getPrimaryField();
        eFields = setdiff(eFields, primaryField);
        hasHEDTags = isfield(eData.event, 'hedtags');
        for k = 1:length(eData.event)
            uTags = fMap.getTags(primaryField, ...
                    num2str(eData.event(k).(primaryField)));
            hTags = {};
            for l = 1:length(eFields)
                tags = fMap.getTags(eFields{l}, ...
                    num2str(eData.event(k).(eFields{l})));
                hTags = merge_taglists(hTags, tags, preservePrefix);
                hTags = merge_taglists(hTags, uTags, preservePrefix, ...
                    'Diff');
                if hasHEDTags
                    oldHTags = hed2cell(eData.event(k).hedtags, false);
                    hTags = merge_taglists(hTags, oldHTags, ...
                        preservePrefix);
                end
            end
            if isempty(uTags)
                eData.event(k).usertags = '';
            elseif ischar(uTags)
                eData.event(k).usertags = uTags;
            else
                eData.event(k).usertags = addGroupTags(uTags);
            end
            if isempty(hTags)
                eData.event(k).hedtags = '';
            elseif ischar(hTags)
                eData.event(k).hedtags = hTags;
            else
                eData.event(k).hedtags = addGroupTags(hTags);
            end
        end
    end % writeIndividualTags

    function uTagsString = addGroupTags(uTags)
        % Add group tags to event
        uTagsString = '';
        for l = 1:length(uTags)
            if ischar(uTags{l})
                uTagsString = [uTagsString ',' uTags{l}];  %#ok<AGROW>
            else
                tagGroup = uTags{l};
                tagGroupString = '';
                for m = 1:length(tagGroup)
                    if strcmpi(tagGroup{m}, '~') || ...
                            ((m-1) > 0 && strcmpi(tagGroup{m-1}, '~'))
                        tagGroupString = ...
                            [tagGroupString tagGroup{m}];  %#ok<AGROW>
                    else
                        tagGroupString = ...
                            [tagGroupString ',' tagGroup{m}];  %#ok<AGROW>
                    end
                end
                tagGroupString = regexprep(tagGroupString,',','', 'once');
                tagGroupString = ['(' tagGroupString ')']; %#ok<AGROW>
                uTagsString = [uTagsString ',' tagGroupString]; %#ok<AGROW>
            end
        end
        uTagsString = regexprep(uTagsString,',','', 'once');
    end % addGroupTags

    function eData = writeSummaryTags(fMap, eData, tFields)
        % Write summary tags in etc fields
        if isfield(eData, 'etc') && ~isstruct(eData.etc)
            eData.etc.other = eData.etc;
        end
        eData.etc.tags = '';   % clear the tags
        if isempty(tFields)
            map = '';
        else
            map(length(tFields)) = struct('field', '', 'values', '');
            if isfield(eData, 'event') && isstruct(eData.event)
                for k = 1:length(tFields)
                    map(k) = removeMapValues(fMap, eData, tFields{k});
                end
            else
                for k = 1:length(tFields)
                    map(k) = fMap.getMap(tFields{k}).getStruct();
                end
            end
        end
        eData.etc.tags = struct('description', fMap.getDescription(), ...
            'xml', fMap.getXml(), 'map', map);
    end % writeSummaryTags

    function map = removeMapValues(fMap, eData, tField)
        % Remove the values from the fMap that are not found in the dataset
        map = fMap.getMap(tField).getStruct();
        mapCodes = cellfun(@num2str, {map.values.code}, ...
            'UniformOutput', false);
        fieldCodes = unique(cellfun(@num2str, {eData.event.(tField)}, ...
            'UniformOutput', false));
        positions = ~ismember(mapCodes, fieldCodes);
        map.values(:, positions) = [];
    end % removeMapValues

    function p = parseArguments(eData, fMap, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('eData', @(x) (isempty(x) || isstruct(x)));
        parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, ...
            'fieldMap')));
        parser.addParamValue('ExcludeFields', {}, @(x) (iscellstr(x)));
        parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
        parser.addParamValue('PreservePrefix', false, @islogical);
        parser.parse(eData, fMap, varargin{:});
        p = parser.Results;
    end % parseArguments

end %writetags