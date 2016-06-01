% selectmaps
% Allows a user to select the fields to be used
%
% Usage:
%   >>  [fMap, excluded] = selectmaps(fMap)
%   >>  [fMap, excluded] = selectmaps(fMap, 'key1', 'value1', ...)
%
% Description
% [fMap, excluded] = selectmaps(fMap) removes the fields that are excluded
% by the user during selection.
%
% [fMap, excluded] = selectmaps(fMap, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%   'SelectFields'   If true (default), the user is presented with a GUI
%                    that allows users to select which fields to tag.
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for selectmaps:
%
%    doc selectmaps
%
% See also: pop_tageeg, pop_tagstudy, pop_tagdir, pop_tagcsv
%
% Copyright (C) Kay Robbins, Jeremy Cockfield, and Thomas Rognon, UTSA,
% 2011-2015, kay.robbins.utsa.edu jeremy.cockfield.utsa.edu
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
% $Log: selectmaps.m,v $
% $Revision: 2.0 10-Jul-2015 14:39:42 $
% $Initial version $
%

function [fMap, excluded, canceled] = selectmaps(fMap, varargin)
p = parseArguments();

title = 'Please select the fields that you would like to tag';
canceled = false;

% Figure out the fields to be used
fields = fMap.getFields();
excluded = {};

if isempty(fields) || ~p.SelectFields
    return;
end

primaryField = p.PrimaryField;
if sum(strcmp(fields, p.PrimaryField)) == 0
    primaryField = '';
end

loader = javaObjectEDT('edu.utsa.tagger.FieldSelectLoader', title, ...
    {}, fields, primaryField);
[notified, submitted] = checkStatus(loader);
while (~notified)
    pause(0.5);
    [notified, submitted] = checkStatus(loader);
end
excludeUser = cell(loader.getExcludeFields());
primaryField = char(loader.getPrimaryField());
if ~submitted
    canceled = true;
end

if ~isempty(primaryField)
    fMap.setPrimaryMap(primaryField);
end

if isempty(excludeUser)
    return;
end

% Remove the excluded fields
for k = 1:length(excludeUser)
    fMap.removeMap(excludeUser{k});
end

excluded = union(excluded, excludeUser);

    function [notified, submitted] = checkStatus(loader)
        notified = loader.isNotified();
        submitted = loader.isSubmitted();
    end

    function p = parseArguments()
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
        parser.addParamValue('PrimaryField', '', @(x) ...
            (isempty(x) || ischar(x)))
        parser.addParamValue('SelectFields', true, @islogical);
        parser.parse(fMap, varargin{:});
        p = parser.Results;
    end
end % selectmaps