% Allows a user to create a fieldMap object from an entire tree directory
% of similar EEG .set files. The events and tags from all data files are
% extracted and consolidated into a single fieldMap object by merging all
% of the existing tags.
%
% Usage:
%
%   >>  [fMap, fPaths, excluded] = tagdir(inDir)
%
%   >>  [fMap, fPaths, excluded] = tagdir(inDir, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   inDir
%                    A directory that contains similar EEG .set files.
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
%   fMap
%                    A fieldMap object that contains the tag map
%                    information.
%
%   fPaths
%                    A one-dimensional cell array of full file names of the
%                    datasets to be tagged.
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

function [fMap, fPaths] = tagdir(inDir, varargin)
p = parseArguments(inDir, varargin{:});
fPaths = getfilelist(p.InDir, '.set', p.DoSubDirs);
if isempty(fPaths)
    fMap = '';
    warning('tagdir:nofiles', 'No files met tagging criteria\n');
    return;
end
fMap = findDirTags(p, fPaths);
if ~isempty(p.BaseMap)
    fMap = mergeBaseTags(p, fMap);
end

    function [fMap, dirFields] = findDirTags(p, fPaths)
        % Find the existing tags from the directory datasets
        fMap = fieldMap('PreserveTagPrefixes',  p.PreserveTagPrefixes);
        dirFields = {};
        fprintf('\n---Loading the data files to merge the tags---\n');
        for k = 1:length(fPaths) % Assemble the list
            eegTemp = pop_loadset(fPaths{k});
            dirFields = union(dirFields, fieldnames(eegTemp.event));
            fMapTemp = findtags(eegTemp, 'PreserveTagPrefixes', ...
                p.PreserveTagPrefixes, 'EventFieldsToIgnore', ...
                p.EventFieldsToIgnore, 'HedXml', p.HedXml);
            fMap.merge(fMapTemp, 'Merge', p.EventFieldsToIgnore, {});
        end
    end % findDirTags

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

    function p = parseArguments(inDir, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('InDir', @(x) (~isempty(x) && ischar(x)));
        parser.addParamValue('BaseMap', '', ...
            @(x) isa(x, 'fieldMap') || ischar(x));
        parser.addParamValue('BaseMapFieldsToIgnore', {}, @iscellstr);  
        parser.addParamValue('DoSubDirs', true, @islogical);
        parser.addParamValue('EventFieldsToIgnore', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
            @(x) (iscellstr(x)));
        parser.addParamValue('HedXml', which('HED.xml'), @ischar);
        parser.addParamValue('PreserveTagPrefixes', false, @islogical);
        parser.parse(inDir, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tagdir