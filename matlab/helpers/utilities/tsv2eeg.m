% Reads in a tab-separated file containing HED tags and writes them to a
% EEG event structure with matching types (codes).
%
% Usage:
%
%   >>  EEG = tsv2eeg(EEG, filename)
%
%   >>  EEG = tsv2eeg(EEG, filename, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   EEG
%                    A EEG structure that contains matching event types
%                    (codes).
%
%   filename
%                    The name (if added to the workspace) or full path
%                    (if not added to the workspace) of a tab-separated
%                    file.
%
%   Optional (key/value):
%
%   fieldname
%                    The field name in the tagMap that is associated with
%                    the values in a tab-separated file. The default value
%                    is 'type'.
%
%   eventColumn
%                    The event column in the tab-separated file. This is a
%                    scalar integer. The default value is 1
%                    (the first column).
%
%   hasHeader
%                   True (default) if the the tab-separated input file has
%                   a header. The first row will not be validated otherwise
%                   it will and this can generate issues.
%
%   tagColumn
%                    The tag column(s) in the tab-separated file. This can
%                    be a scalar integer or an integer vector. The default
%                    value is 2 (the second column).
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
%  EEG = tagtsv(EEG, 'BCI Data Specification.tsv', 'eventColumn', 1, 
%  'tagColumn', 2)
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

function EEG = tsv2eeg(EEG, filename, varargin)
p = parseArguments(EEG, filename, varargin{:});
if ~isfield(EEG.event, p.fieldname)
    warning(['Field "%s" is not present in the EEG event structure.' ...
        ' ... Exiting function '], p.fieldname);
    return;
end
tsvMap = tsv2map(filename, varargin{:});
uniqueValues = tsvMap.getCodes();
numUniqueValues = length(uniqueValues);
[values, positions] = getValues(p, EEG);
for a = 1:numUniqueValues
    matches = positions(strcmpi(uniqueValues{a}, values));
    tList = getValue(tsvMap, uniqueValues{a});
    [EEG.event(matches).usertags] = ...
        deal(sorttags(tagList.stringify(tList.getTags())));
end

    function [values, positions] = getValues(p, EEG)
        % Get all the non-empty values and positions assoicated with a
        % particular field
        positions = ...
            find(arrayfun(@(x) ~isempty(x.(p.fieldname)), EEG.event));
        values = extractfield(EEG.event(positions), p.fieldname);
        if iscell(values)
            values = cellfun(@num2str, values, 'UniformOutput', false);
        else
            values = arrayfun(@num2str, values, 'UniformOutput', false);
        end
    end % getValues

    function p = parseArguments(EEG, filename, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('EEG', @(x) ~isempty(x) && ...
            isstruct(x) && isfield(x, 'event'));
        parser.addRequired('filename', @(x) ~isempty(x) && ...
            ischar(filename));
        parser.addParamValue('fieldname', 'type', @(x) ~isempty(x) && ...
            ischar(x));
        parser.addParamValue('eventColumn', 1, @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('hasHeader', true, @islogical);
        parser.addParamValue('tagColumn', 2, @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) >= 1 && all(rem(x,1) == 0));
        parser.parse(EEG, filename, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tsv2eeg