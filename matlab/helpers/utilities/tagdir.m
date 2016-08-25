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
% Description:
% [fMap, fPaths, excluded] = tagdir(inDir) extracts a consolidated
% fieldMap object from the data files in the directory tree inDir. The
% inDir must be a valid path.
%
% Input:
%
%       Required:
%
%       inDir
%                    A directory that contains similar EEG .set files.
%
%       Optional (key/value):
%
%       'BaseMap'
%                    A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
%                    information.
%
%       'DoSubDirs'
%                    If true (default), the entire inDir directory tree is
%                    searched. If false, only the inDir directory is
%                    searched.
%
%       'EditXml'
%                    If false (default), the HED XML cannot be modified
%                    using the tagger GUI. If true, then the HED XML can be
%                    modified using the tagger GUI.
%
%       'ExcludeFields'
%                    A cell array of field names in the .event and .urevent
%                    substructures to ignore during the tagging process. By
%                    default the following subfields of the event structure
%                    are ignored: .latency, .epoch, .urevent, .hedtags, and
%                    .usertags. The user can over-ride these tags using
%                    this name-value parameter.
%
%       'Fields'
%                    A cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty, only
%                    these fields are tagged.
%
%       'PreservePrefix'
%                    If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
%       'PrimaryField'
%                    The name of the primary field. Only one field can be
%                    the primary field. A primary field requires a label,
%                    category, and a description. The default is the type
%                    field.
%
%       'SaveDatasets'
%                    If true (default), save the tags to the underlying
%                    dataset files in the directory.
%
%       'SaveMapFile'
%                    A string representing the file name for saving the
%                    final, consolidated fieldMap object that results from
%                    the tagging process.
%
%       'SelectFields'
%                    If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%
%       'UseGui'
%                    If true (default), the CTAGGER GUI is displayed after
%                    initialization.
%
% Output:
%
%       fMap         A fieldMap object that contains the tag map
%                    information.
%
%       fPaths       A list of full file names of the datasets to be
%                    tagged.
%
%       excluded     A cell array containing the fields that were excluded
%                    from tagging.
%
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013,
% krobbins@cs.utsa.edu
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

function [fMap, fPaths, excluded] = tagdir(inDir, varargin)
p = parseArguments(inDir, varargin{:});
canceled = false;
[fPaths, fMap, dirFields] = findDirTags(p);
fMap = mergeBaseTags(fMap, p.BaseMap);
[fMapTag, fields, excluded, canceled] = extractSelectedFields(p, ...
    fMap, dirFields);

if p.UseGui && ~canceled
    [fMapTag, canceled] = editmaps(fMapTag, 'EditXml', p.EditXml, ...
        'PreservePrefix', p.PreservePrefix, 'Fields', fields);
end

if ~canceled
    write2dir(fPaths, fMap, fMapTag, excluded, p.PreservePrefix, ...
        p.SaveMapFile, p.SaveDatasets);
    fprintf('Tagging complete\n');
    return;
end
fprintf('Tagging was canceled\n');

    function [fMapTag, fields, excluded, canceled] = ...
            extractSelectedFields(p, fMap, dirFields)
        % Exclude the appropriate tags from baseTags
        if ~p.UseGui
            p.SelectFields = false;
        end
        excluded = intersect(p.ExcludeFields, dirFields);
        fMapTag = clone(fMap);
        [fMapTag, fields, excluded, canceled] = selectmaps(fMapTag, ...
            'ExcludeFields', excluded, 'Fields', p.Fields, ...
            'PrimaryField', p.PrimaryField, 'SelectFields', ...
            p.SelectFields);
    end % extractSelectedFields

    function [fPaths, fMap, dirFields] = findDirTags(p)
        % Find the existing tags from the directory datasets
        fPaths = getfilelist(p.InDir, '.set', p.DoSubDirs);
        if isempty(fPaths)
            warning('tagdir:nofiles', 'No files met tagging criteria\n');
            return;
        end
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

    function write2dir(fPaths, fMap, fMapTag, excluded, preservePrefix, ...
            saveMapFile, saveDatasets)
        % Merges the tags and writes them to the directory EEG dataset
        % structures
        fMap.merge(fMapTag, 'Replace', excluded, fMapTag.getFields());
        % Save the tags file for next step
        if ~isempty(saveMapFile) && ~fieldMap.saveFieldMap(saveMapFile, ...
                fMap)
            warning('tagdir:invalidFile', ...
                ['Couldn''t save fieldMap to ' saveMapFile]);
        end
        if saveDatasets
            % Rewrite all of the EEG files with updated tag information
            fprintf(['\n---Now rewriting the tags to the individual' ...
                ' data files---\n']);
            for k = 1:length(fPaths) % Assemble the list
                EEG = pop_loadset(fPaths{k});
                EEG = writetags(EEG, fMap, 'PreservePrefix', ...
                    preservePrefix);
                EEG = pop_saveset(EEG, 'filename', EEG.filename, ...
                    'filepath', EEG.filepath);
            end
        end
    end %  write2dir

    function p = parseArguments(inDir, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('InDir', @(x) (~isempty(x) && ischar(x)));
        parser.addParamValue('BaseMap', '', ...
            @(x)(isempty(x) || (ischar(x))));
        parser.addParamValue('DoSubDirs', true, @islogical);
        parser.addParamValue('EditXml', false, @islogical);
        parser.addParamValue('ExcludeFields', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
            @(x) (iscellstr(x)));
        parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
        parser.addParamValue('PreservePrefix', false, @islogical);
        parser.addParamValue('PrimaryField', 'type', @(x) ...
            (isempty(x) || ischar(x)))
        parser.addParamValue('SaveDatasets', true, @islogical);
        parser.addParamValue('SaveMapFile', '', @(x)(ischar(x)));
        parser.addParamValue('SelectFields', true, @islogical);
        parser.addParamValue('UseGui', true, @islogical);
        parser.parse(inDir, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tagdir