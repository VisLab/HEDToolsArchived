% findtags
% Creates a fieldMap object for the existing tags in a data structure
%
% Usage:
%   >>  fMap = findtags(edata)
%   >>  fMap = findtags(edata, 'key1', 'value1', ...)
%
% Description:
% fMap = findtags(edata) extracts a fieldMap object representing the
% events and their tags for the structure.
%
% tMap = findtags(edata, 'key1', 'value1', ...) specifies optional
% name/value parameter pairs:
%
%   'ExcludeFields'  A cell array containing the field names to exclude
%   'Fields'         A cell array containing the field names to extract
%                    tags for.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
% Notes:
%   The edata structure should have its events encoded as a structure
%   array edata.events. The findtags will also examinate a edata.urevents
%   structure array if it exists.
%
%   Tags are assumed to be stored in the edata.etc structure as follows:
%
%    edata.etc.tags.xml
%    edata.etc.tags.map
%       ...
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for findtags:
%
%    doc findtags
%
% See also: fMap
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
% $Log: findtags.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function fMap = findtags(edata, varargin)
% Parse the input arguments
parser = inputParser;
parser.addRequired('edata', @(x) (isempty(x) || isstruct(x)));
parser.addParamValue('ExcludeFields', ...
    {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
    @(x) (iscellstr(x)));
parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
parser.addParamValue('PreservePrefix', false, ...
    @(x) validateattributes(x, {'logical'}, {}));
parser.parse(edata, varargin{:});
p = parser.Results;
edata = p.edata;

% If edata.etc.tags exists, then extract tag information
xml = '';
tFields = {};
if isfield(edata, 'etc') && isstruct(edata.etc) && ...
        isfield(edata.etc, 'tags') && isstruct(edata.etc.tags)
    if isfield(edata.etc.tags, 'xml')
        xml = edata.etc.tags.xml;
    end
    if isfield(edata.etc.tags, 'map') && isstruct(edata.etc.tags.map) ...
            && isfield(edata.etc.tags.map, 'field')
        tFields = {edata.etc.tags.map.field};
    end
end
fMap = fieldMap('XML', xml, 'PreservePrefix', p.PreservePrefix);
if ~isempty(p.Fields)
    tFields = intersect(p.Fields, tFields);
end


for k = 1:length(tFields)
    thisField = edata.etc.tags.map(k).field;
    if sum(strcmpi(thisField, tFields) == 1)
        fMap.addValues(thisField, edata.etc.tags.map(k).values);
    end
end

efields = {};
if isfield(edata, 'event') && isstruct(edata.event)
    efields = fieldnames(edata.event);
end
if isfield(edata, 'urevent') && isstruct(edata.urevent)
    efields = union(efields, fieldnames(edata.urevent));
end

efields = setdiff(efields, p.ExcludeFields);
if ~isempty(p.Fields)
    efields = intersect(p.Fields, efields);
end

for k = 1:length(efields)
    if isfield(edata.event, 'usertags')
        tMap = extractTags(edata, efields{k});
        tMapValues = getValues(tMap);
        for j = 1:length(tMapValues)
            fMap.addValues(efields{k}, tMapValues{j});
        end
    end
    tValues = getutypes(edata.event, efields{k});
    if isfield(edata, 'urevent')
        tValues = union(tValues, getutypes(edata.urevent, efields{k}));
    end
    if isempty(tValues)
        continue
    end
    valueForm = tagList.empty(0,length(tValues));
    for j = 1:length(tValues)
        valueForm(j) = tagList(num2str(tValues{j})); 
    end
    fMap.addValues(efields{k}, valueForm);
end
end %findtags