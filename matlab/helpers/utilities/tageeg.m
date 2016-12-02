% Allows a user to tag a EEG structure. First all of the tag information
% and potential fields are extracted from EEG.event, EEG.urevent, and
% EEG.etc.tags structures. After existing event tags are extracted and
% merged with an optional input fieldMap, the user is presented with a
% GUI to accept or exclude potential fields from tagging. Then the user is
% presented with the CTagger GUI to edit and tag. Finally, the tags are
% rewritten to the EEG structure.
%
% Usage:
%
%   >>  [EEG, fMap] = tageeg(EEG)
%
%   >>  [EEG, fMap] = tageeg(EEG, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   EEG
%                    The EEG dataset structure that will be tagged. The
%                    dataset will need to have a .event field.
%
%   Optional (key/value):
%
%   'BaseMap'
%                    A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
%                    information.
%
%   'BaseMapFieldsToIgnore'
%                    A one-dimensional cell array of field names in the
%                    .event substructure to ignore when merging with a
%                    fieldMap object 'BaseMap'. 
%                    
%   'HedXml'
%                    Full path to a HED XML file. The default is the
%                    HED.xml file in the hed directory.
%
%   'EventFieldsToIgnore'
%                    A one-dimensional cell array of field names in the
%                    .event substructure to ignore during the tagging
%                    process. By default the following subfields of the
%                    .event structure are ignored: .latency, .epoch,
%                    .urevent, .hedtags, and .usertags. The user can
%                    over-ride these tags using this name-value parameter.
%
%   'PreserveTagPrefixes'
%                    If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
% Output:
%
%   EEG
%                    The EEG dataset structure that has been tagged. The
%                    tags will be written to the .usertags field under
%                    the .event field.
%
%   fMap
%                    A fieldMap object that stores all of the tags.
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [EEG, fMap] = tageeg(EEG, varargin)
p = parseArguments(EEG, varargin{:});
fMap = findtags(EEG, 'PreserveTagPrefixes', p.PreserveTagPrefixes, ...
    'EventFieldsToIgnore', p.EventFieldsToIgnore, 'HedXml', p.HedXml);
if ~isempty(p.BaseMap)
    fMap = mergeBaseTags(p, fMap);
    EEG = writetags(EEG, fMap, 'PreserveTagPrefixes', ...
        p.PreserveTagPrefixes);
end

    function fMap = mergeBaseTags(p, fMap)
        % Merge baseMap and fMap tags
        if isa(p.BaseMap, 'fieldMap')
            baseTags = p.BaseMap;
        else
            baseTags = fieldMap.loadFieldMap(p.BaseMap);
        end
        fMap.merge(baseTags, 'Update', union(p.BaseMapFieldsToIgnore, ...
            p.EventFieldsToIgnore), {});
    end % mergeBaseTags

    function p = parseArguments(EEG, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('EEG', @(x) (isempty(x) || isstruct(EEG)));
        parser.addParamValue('BaseMap', '', @(x) isa(x, 'fieldMap') || ...
            ischar(x));
        parser.addParamValue('BaseMapFieldsToIgnore', {}, @iscellstr);      
        parser.addParamValue('HedXml', which('HED.xml'), @ischar);
        parser.addParamValue('EventFieldsToIgnore', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
            @iscellstr);
        parser.addParamValue('PreserveTagPrefixes', false, @islogical);
        parser.parse(EEG, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tageeg