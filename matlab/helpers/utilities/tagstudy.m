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
% Input:
%
%       Required:
%
%       studyFile
%                    The path to a EEG study.
%
%       Optional (key/value):
%
%       'BaseMap'
%                    A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used for initial tag
%                    information.
%
%       'EditXml'
%                    If false (default), the HED XML cannot be modified
%                    using the tagger GUI. If true, then the HED XML can be
%                    modified using the tagger GUI.
%
%       'ExcludeFields'
%                    A cell array of field names in the .event and .urevent
%                    substructures to ignore during the tagging process.
%                    By default the following subfields of the event
%                    structure are ignored: .latency, .epoch, .urevent,
%                    .hedtags, and .usertags. The user can over-ride these
%                    tags using this name-value parameter.
%
%       'Fields'
%                    A cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty,
%                    only these fields are tagged.
%
%       'PreservePrefix'
%                    If false (default), tags of the same event type that
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
%                    The full path name of the file for saving the final,
%                    consolidated fieldMap object that results from the
%                    tagging process.
%
%       'SelectFields'
%                    If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%
%       'UseGui'
%                    If true (default), the CTAGGER GUI is displayed after
%                    initialization.
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

function [fMap, fPaths, excluded] = tagstudy(studyFile, varargin)
% Tag all of the EEG files in a study
p = parseArguments(studyFile, varargin{:});
canceled = false;
excluded = '';

% Consolidate all of the tags from the study
[s, fPaths] = loadstudy(p.StudyFile);
[fMap, fMapTag] = findtags(s.STUDY, 'ExcludeFields', p.ExcludeFields, ...
    'Fields', p.Fields, 'PreservePrefix', p.PreservePrefix);

% Merge the tags for the study from individual files
if isempty(fPaths)
    warning('tagstudy:nofiles', 'No files in study\n');
    return;
end

allFields = {};
for k = 1:length(fPaths) % Assemble the list
    eegTemp = pop_loadset(fPaths{k});
    allFields = union(allFields, fieldnames(eegTemp.event));
    [tMapNew, tMapTagNew] = findtags(eegTemp, 'PreservePrefix', ...
        p.PreservePrefix, 'ExcludeFields', p.ExcludeFields, 'Fields', ...
        p.Fields);
    fMap.merge(tMapNew, 'Merge', p.ExcludeFields, tMapNew.getFields());
    fMapTag.merge(tMapTagNew, 'Merge', p.ExcludeFields, p.Fields);
end
% Exclude the appropriate tags from baseTags
fields = {};
excluded = intersect(p.ExcludeFields, allFields);
if p.UseGui && p.SelectFields && isempty(p.Fields)
    fprintf('\n---Now select the fields you want to tag---\n');
    [fMapTag, fields, exc, canceled] = selectmaps(fMapTag, 'PrimaryField', ...
        p.PrimaryField);
    excluded = union(excluded, exc);
else
    fMapTag.setPrimaryMap(p.PrimaryField);
    for k = 1:length(excluded)
        fMapTag.removeMap(excluded{k});
    end
end
if isa(p.BaseMap, 'fieldMap')
    baseTags = p.BaseMap;
else
    baseTags = fieldMap.loadFieldMap(p.BaseMap);
end
if ~isempty(baseTags) && ~isempty(p.Fields)
    excluded = setdiff(baseTags.getFields(), p.Fields);
end;
fMap.merge(baseTags, 'Merge', excluded, p.Fields);
fMapTag.merge(baseTags, 'Update', excluded, p.Fields);


if p.UseGui && ~canceled
    [fMapTag, canceled] = editmaps(fMapTag, 'EditXml', p.EditXml, ...
        'PreservePrefix', p.PreservePrefix, 'Fields', fields);
end

if ~canceled
    % Replace the existing tags, and then add any new codes found
    fMap.merge(fMapTag, 'Replace', p.ExcludeFields, fMapTag.getFields());
    fMap.merge(fMapTag, 'Merge', p.ExcludeFields, fMapTag.getFields());
    % Save the tags file for next step
    if ~isempty(p.SaveMapFile) && ~fieldMap.saveFieldMap(p.SaveMapFile, ...
            fMap)
        warning('tagstudy:invalidFile', ...
            ['Couldn''t save fieldMap to ' p.SaveMapFile]);
    end
    
    if p.SaveDatasets
        % Rewrite all of the EEG files with updated tag information
        fprintf('\n---Now rewriting the tags to the individual data files---\n');
        for k = 1:length(fPaths) % Assemble the list
            EEG = pop_loadset(fPaths{k});
            EEG = writetags(EEG, fMap, 'PreservePrefix', p.PreservePrefix);
            EEG = pop_saveset(EEG, 'filename', EEG.filename, ...
                'filepath', EEG.filepath);
        end
    end
    
    % Rewrite to the study file
    s.STUDY = writetags(s.STUDY, fMap, 'PreservePrefix', ...
        p.PreservePrefix);  %#ok<NASGU>
    save(p.StudyFile, '-struct', 's');
    fprintf('Tagging complete\n');
    return;
end
fprintf('Tagging was canceled\n');

    function [s, fNames] = loadstudy(studyFile)
        % Set baseTags if tagsFile contains an tagMap object
        try
            s = load('-mat', studyFile);
            sPath = fileparts(studyFile);
            fNames = getstudyfiles(s.STUDY, sPath);
        catch ME %#ok<NASGU>
            warning('tagstudy:loadStudyFile', 'Invalid study file');
            s = '';
            fNames = '';
        end
    end % loadstudy

    function fNames = getstudyfiles(study, sPath)
        % Set baseTags if tagsFile contains an tagMap object
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