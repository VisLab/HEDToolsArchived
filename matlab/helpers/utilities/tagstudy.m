% Allows a user to tag a study file and its associated EEG .set files
% First all of the tag information and potential fields are extracted from
% EEG.event, EEG.urevent, and EEG.etc.tags structures. After existing event
% tags are extracted and merged with an optional input fieldMap, the user
% is presented with a GUI to accept or exclude potential fields from
% tagging. Then the user is presented with the CTagger GUI to edit and tag.
% Finally, the tags are rewritten to the EEG structure.
%
% Usage:
%
%   >>  [fMap, fPaths, excluded] = tagstudy(studyFile)
%
%   >>  [fMap, fPaths, excluded] = tagstudy(studyFile, 'key1', ...
%       'value1', ...)
%
% Input:
%
%   Required:
%
%   studyFile
%                    The path to a EEG study.
%
%   Optional (key/value):
%
%   'BaseMap'
%                    A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used for initial tag
%                    information.
%
%   'EditXml'
%                    If false (default), the HED XML cannot be modified
%                    using the tagger GUI. If true, then the HED XML can be
%                    modified using the tagger GUI.
%
%   'ExcludeFields'
%                    A cell array of field names in the .event and .urevent
%                    substructures to ignore during the tagging process.
%                    By default the following subfields of the event
%                    structure are ignored: .latency, .epoch, .urevent,
%                    .hedtags, and .usertags. The user can over-ride these
%                    tags using this name-value parameter.
%
%   'Fields'
%                    A cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty,
%                    only these fields are tagged.
%
%   'PreservePrefix'
%                    If false (default), tags of the same event type that
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
%                    If true (default), save the tags to the underlying
%                    dataset files in the directory.
%
%   'SaveMapFile'
%                    The full path name of the file for saving the final,
%                    consolidated fieldMap object that results from the
%                    tagging process.
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
%                    information
%
%   fPaths
%                    A fieldMap object that contains the tag map
%                    information
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

function [fMap, fPaths, canceled] = tagstudy(studyFile, varargin)
p = parseArguments(studyFile, varargin{:});
[study, fPaths] = loadstudy(p.StudyFile);
if isempty(fPaths)
    fMap = '';
    canceled = '';
    warning('tagstudy:nofiles', 'No files in study\n');
    return;
end
[fMap, studyFields] = findStudyTags(p, fPaths);
fMap = mergeBaseTags(fMap, p.BaseMap);
[fMap, fields, excluded, canceled] = extractSelectedFields(p, fMap, ...
    studyFields);
if p.UseGui && ~canceled
    [fMap, canceled] = editmaps(fMap, 'EditXml', p.EditXml, ...
        'PreservePrefix', p.PreservePrefix, 'ExcludedField', ...
        excluded, 'Fields', fields);
end
if ~canceled
    write2study(p, fPaths, fMap, study);
    fprintf('Tagging complete\n');
    return;
end
fprintf('Tagging was canceled\n');

    function write2study(p, fPaths, fMap, study)
        % Writes the tags to the directory datasets
        if ~isempty(p.SaveMapFile) && ...
                ~fieldMap.saveFieldMap(p.SaveMapFile, fMap)
            warning('tagstudy:invalidFile', ...
                ['Couldn''t save fieldMap to ' p.SaveMapFile]);
        end
        if p.SaveDatasets
            % Rewrite all of the EEG files with updated tag information
            fprintf(['\n---Now rewriting the tags to the individual' ...
                ' data files---\n']);
            for k = 1:length(fPaths) % Assemble the list
                EEG = pop_loadset(fPaths{k});
                EEG = writetags(EEG, fMap, 'PreservePrefix', ...
                    p.PreservePrefix);
                pop_saveset(EEG, 'filename', EEG.filename, ...
                    'filepath', EEG.filepath);
            end
        end
        % Rewrite to the study file
        study.STUDY = writetags(study.STUDY, fMap, 'PreservePrefix', ...
            p.PreservePrefix);  
        save(p.studyFile, '-struct', 's');
    end % write2study

    function fMap = mergeBaseTags(fMap, baseMap)
        % Merge baseMap and fMap tags
        if isa(baseMap, 'fieldMap')
            baseTags = baseMap;
        else
            baseTags = fieldMap.loadFieldMap(baseMap);
        end
        fMap.merge(baseTags, 'Update', {}, fMap.getFields());
    end % mergeBaseTags

    function [fMap, fields, excluded, canceled] = ...
            extractSelectedFields(p, fMap, studyFields)
        % Extract the selected fields from the fMap
        if ~p.UseGui
            p.SelectFields = false;
        end
        excluded = intersect(p.ExcludeFields, studyFields);
        [fMap, fields, excluded, canceled] = selectmaps(fMap, ...
            'ExcludeFields', excluded, 'Fields', p.Fields, ...
            'PrimaryField', p.PrimaryField, 'SelectFields', ...
            p.SelectFields);
    end % extractSelectedFields

    function [fMap, studyFields] = findStudyTags(p, fPaths)
        % Find the existing tags from the study datasets
        fMap = fieldMap('PreservePrefix',  p.PreservePrefix);
        studyFields = {};
        for k = 1:length(fPaths) % Assemble the list
            eegTemp = pop_loadset(fPaths{k});
            studyFields = union(studyFields, fieldnames(eegTemp.event));
            fMapTemp = findtags(eegTemp, 'PreservePrefix', ...
                p.PreservePrefix, 'ExcludeFields', {}, 'Fields', {});
            fMap.merge(tMapNew, 'Merge', p.ExcludeFields, ...
                tMapNew.getFields());
            fMap.merge(fMapTemp, 'Merge', {}, fMapTemp.getFields());
        end
    end % findStudyTags

    function [study, fNames] = loadstudy(studyFile)
        % Load the study file 
        try
            study = load('-mat', studyFile);
            sPath = fileparts(studyFile);
            fNames = getstudyfiles(study.STUDY, sPath);
        catch ME %#ok<NASGU>
            warning('tagstudy:loadStudyFile', 'Invalid study file');
            study = '';
            fNames = '';
        end
    end % loadstudy

    function fNames = getstudyfiles(study, sPath)
        % Go through the study and find all of the dataset file paths
        datasets = {study.datasetinfo.filename};
        paths = {study.datasetinfo.filepath};
        validPaths = true(size(paths));
        fNames = cell(size(paths));
        for ik = 1:length(paths)
            fName = fullfile(paths{ik}, datasets{ik}); % Absolute path
            if ~exist(fName, 'file')  % Relative to stored study path
                fName = fullfile(study.filepath, paths{ik}, datasets{ik});
            end
            if ~exist(fName, 'file') % Relative to actual study path
                fName = fullfile(sPath, paths{ik}, datasets{ik});
            end
            if ~exist(fName, 'file') % Give up
                warning('tagstudy:getStudyFiles', ...
                    ['Study file ' fname ' doesn''t exist']);
                validPaths(ik) = false;
            end
            fNames{ik} = fName;
        end
        fNames(~validPaths) = [];  % Get rid of invalid paths
    end % getstudyfiles

    function p = parseArguments(studyFile, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('StudyFile', ...
            @(x) (~isempty(x) && exist(studyFile, 'file')));
        parser.addParamValue('BaseMap', '', ...
            @(x)(isempty(x) || (ischar(x))));
        parser.addParamValue('EditXml', false, @islogical);
        parser.addParamValue('ExcludeFields', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
            @(x) (iscellstr(x)));
        parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
        parser.addParamValue('PreservePrefix', false, @islogical);
        parser.addParamValue('PrimaryField', 'type', @(x) ...
            (isempty(x) || ischar(x)))
        parser.addParamValue('SaveDatasets', true, @islogical);
        parser.addParamValue('SaveMapFile', '', ...
            @(x)(isempty(x) || (ischar(x))));
        parser.addParamValue('SelectFields', true, @islogical);
        parser.addParamValue('UseGui', true, @islogical);
        parser.parse(studyFile, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tagstudy