% Allows a user to tag an entire tree directory of similar EEG .set files.
% First the events and tags from all data files are extracted and
% consolidated into a single fieldMap object by merging all of the
% existing tags. Then the user is presented with a GUI for choosing
% which fields to tag. The ctagger GUI is displayed so that users can
% edit/modify the tags. The GUI is launched in asynchronous mode.
% Finally the tags are rewritten to the data files.
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
%   'DoSubDirs'
%                    If true (default), the entire inDir directory tree is
%                    searched. If false, only the inDir directory is
%                    searched.
%
%   'ExcludeFields'
%                    A one-dimensional cell array of field names in the
%                    .event substructure to ignore during the tagging
%                    process. By default the following subfields of the
%                    .event structure are ignored: .latency, .epoch,
%                    .urevent, .hedtags, and .usertags. The user can
%                    over-ride these tags using this name-value parameter.
%
%   'Fields'
%                    A one-dimensional cell array of fields to tag. If this
%                    parameter is non-empty, only these fields are tagged.
%
%   'PreservePrefix'
%                    If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
%   'PrimaryField'
%                    The name of the primary field. Only one field can be
%                    the primary field. A primary field requires a label,
%                    category, and a description. The default is the type
%                    field.
%
%   'SaveDatasets'
%                    If true, save the tags to the underlying
%                    dataset files in the directory. If false (default),
%                    do not save the tags to the underlying dataset files
%                    in the directory.
%
%   'SaveMapFile'
%                    A string representing the file name for saving the
%                    final, consolidated fieldMap object that results from
%                    the tagging process.
%
%   'SelectFields'
%                    If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%
%   'UseGui'
%                    If true (default), the CTAGGER GUI is displayed after
%                    initialization.
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
%   canceled
%                    True if the user canceled the tagging. False if
%                    otherwise.
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

function [fMap, fPaths, canceled] = tagdir(inDir, varargin)
p = parseArguments(inDir, varargin{:});
fPaths = getfilelist(p.InDir, '.set', p.DoSubDirs);
if isempty(fPaths)
    fMap = '';
    canceled = '';
    warning('tagdir:nofiles', 'No files met tagging criteria\n');
    return;
end
[fMap, dirFields] = findDirTags(p, fPaths);
fMap = mergeBaseTags(fMap, p.BaseMap);
[fMap, fields, excluded, canceled] = extractSelectedFields(p, ...
    fMap, dirFields);
if p.UseGui && ~canceled
    [fMap, canceled] = editmaps(fMap, 'PreservePrefix', ...
        p.PreservePrefix, 'ExcludeField', excluded, 'Fields', fields);
end
if ~canceled
    write2dir(p, fMap);
    fprintf('Tagging complete\n');
    return;
end
fprintf('Tagging was canceled\n');

    function [fMap, fields, excluded, canceled] = ...
            extractSelectedFields(p, fMap, dirFields)
        % Exclude the appropriate tags from baseTags
        if ~p.UseGui
            p.SelectFields = false;
        end
        excluded = intersect(p.ExcludeFields, dirFields);
        [fMap, fields, excluded, canceled] = selectmaps(fMap, ...
            'ExcludeFields', excluded, 'Fields', p.Fields, ...
            'PrimaryField', p.PrimaryField, 'SelectFields', ...
            p.SelectFields);
    end % extractSelectedFields

    function [fMap, dirFields] = findDirTags(p, fPaths)
        % Find the existing tags from the directory datasets
        fMap = fieldMap('PreservePrefix',  p.PreservePrefix);
        dirFields = {};
        fprintf('\n---Loading the data files to merge the tags---\n');
        for k = 1:length(fPaths) % Assemble the list
            eegTemp = pop_loadset(fPaths{k});
            dirFields = union(dirFields, fieldnames(eegTemp.event));
            fMapTemp = findtags(eegTemp, 'PreservePrefix', ...
                p.PreservePrefix, 'ExcludeFields', {}, 'Fields', {});
            fMap.merge(fMapTemp, 'Merge', {}, fMapTemp.getFields());
        end
    end % findDirTags

    function fMap = mergeBaseTags(fMap, baseMap)
        % Merge baseMap and fMap tags
        if isa(baseMap, 'fieldMap')
            baseTags = baseMap;
        else
            baseTags = fieldMap.loadFieldMap(baseMap);
        end
        fMap.merge(baseTags, 'Update', {}, fMap.getFields());
    end % mergeBaseTags

    function write2dir(p, fMap)
        % Writes the tags to the directory datasets
        if ~isempty(p.SaveMapFile)
            savefmap(fMap, p.SaveMapFile);
        end
        if p.SaveDatasets
            overwritedataset(fMap, p.InDir, 'DoSubDirs', p.DoSubDirs, ...
                'PreservePrefix', p.PreservePrefix);
        end
    end % write2dir

    function p = parseArguments(inDir, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('InDir', @(x) (~isempty(x) && ischar(x)));
        parser.addParamValue('BaseMap', '', ...
            @(x) isa(x, 'fieldMap') || ischar(x));
        parser.addParamValue('DoSubDirs', true, @islogical);
        parser.addParamValue('ExcludeFields', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
            @(x) (iscellstr(x)));
        parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
        parser.addParamValue('PreservePrefix', false, @islogical);
        parser.addParamValue('PrimaryField', 'type', @(x) ...
            (isempty(x) || ischar(x)))
        parser.addParamValue('SaveDatasets', false, @islogical);
        parser.addParamValue('SaveMapFile', '', @(x)(ischar(x)));
        parser.addParamValue('SelectFields', true, @islogical);
        parser.addParamValue('UseGui', true, @islogical);
        parser.parse(inDir, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tagdir