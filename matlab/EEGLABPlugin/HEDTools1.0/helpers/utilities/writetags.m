% writetags
% Writes tags to a structure from the fieldMap information
%
% Usage:
%   >>  eData = writetags(eData, fMap)
%   >>  eData = writetags(eData, fMap, 'key1', 'value1', ...)
%
% Description:
% eData = writetags(eData, fMap) inserts the tags in the eData structure
% as specified by the fMap fieldMap object, both in summary form and
% individually.
%
% eData = writetags(eData, fMap, 'key1', 'value1', ...) specifies optional
% name/value parameter pairs:
%   'ExcludeFields'  A cell array containing the field names to exclude
%   'PreservePrefix' If false (default), tags associated with same value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for writetags:
%
%    doc writetags
%
% See also: tageeg, fieldMap, and tagMap
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
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
%
% $Log: writetags.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function eData = writetags(eData, fMap, varargin)
p = parseArguments();

% Prepare the values to be written
tFields = setdiff(fMap.getFields(), p.ExcludeFields);
eFields = {};
if isfield(eData, 'event') && isstruct(eData.event)
    eFields = intersect(fieldnames(eData.event), tFields);
end
urFields = {};
if isfield(eData, 'urevent') && isstruct(eData.urevent)
    urFields = intersect(fieldnames(eData.urevent), tFields);
end

% Write the etc.tags.map fields
eFields = intersect(union(eFields, urFields), tFields);

% Write summary tags in etc fields
    
    % Prepare the structure
    if isfield(eData, 'etc') && ~isstruct(eData.etc)
        eData.etc.other = eData.etc;
    end
    eData.etc.tags = '';   % clear the tags
    if isempty(tFields)
        map = '';
    else
        map(length(tFields)) = struct('field', '', 'values', '');
        for k = 1:length(tFields)
            map(k) = fMap.getMap(tFields{k}).getStruct();
        end
    end
    eData.etc.tags = struct('xml', fMap.getXml(), 'map', map);

% Write tags to individual events in usertags field
if isfield(eData, 'event') 
    for k = 1:length(eData.event)
        uTags = {};
        for l = 1:length(eFields)
            tags = fMap.getTags(eFields{l}, ...
                num2str(eData.event(k).(eFields{l})));
            uTags = merge_taglists(uTags, tags, p.PreservePrefix);
        end
        if isempty(uTags)
            eData.event(k).usertags = '';
        elseif ischar(uTags)
            eData.event(k).usertags = uTags;
        else
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
                    tagGroupString = ...
                        regexprep(tagGroupString,',','', 'once');
                    tagGroupString = ['(' tagGroupString ')']; %#ok<AGROW>
                    uTagsString = [uTagsString ',' tagGroupString]; %#ok<AGROW>
                end
            end
            uTagsString = ...
                regexprep(uTagsString,',','', 'once');
            eData.event(k).usertags = uTagsString;
        end
    end
end

    function p = parseArguments()
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('eData', @(x) (isempty(x) || isstruct(x)));
        parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
        parser.addParamValue('ExcludeFields', {}, @(x) (iscellstr(x)));
        parser.addParamValue('PreservePrefix', false, @islogical);
        parser.parse(eData, fMap, varargin{:});
        p = parser.Results;
    end % parseArguments

end %writetags