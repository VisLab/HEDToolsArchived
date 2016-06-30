% tagstudy
% Allows a user to tag a EEGLAB study
%
% Usage:
%   >>  [fMap, fPaths, excluded] = tagstudy(studyFile)
%   >>  [fMap, fPaths, excluded] = tagstudy(studyFile, 'key1', ...
%       'value1', ...)
%
% Description:
% [fMap, fPaths, excluded] = tagstudy(studyFile)extracts a consolidated
% fMap object from the study and its associated EEGLAB .set files.
% First the events and tags from all EEGLAB .set files are extracted and
% consolidated into a single fMap object by merging all of the
% existing tags. Then any tags from the study itself are extracted.
% The ctagger GUI is then displayed so that users can
% edit/modify the tags. The GUI is launched in synchronous mode, meaning
% that it behaves like a modal dialog and must be closed before execution
% continues. Finally the tags for each EEG file are updated.
%
% The final, consolidated and edited fMap object is returned in eTags
% and fPaths is a cell array containing the full path names of all of the
% .set files that were affected.
%
%
% [fMap, fPaths, excluded] = tagstudy(studyFile, 'key1', 'value1', ...)
% specifies optional name/value parameter pairs:
%   'BaseMap'        A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used for initial tag
%                    information.
%   'EditXml'        If false (default), the HED XML cannot be modified
%                    using the tagger GUI. If true, then the HED XML can be
%                    modified using the tagger GUI.
%   'ExcludeFields'  A cell array of field names in the .event and .urevent
%                    substructures to ignore during the tagging process.
%                    By default the following subfields of the event
%                    structure are ignored: .latency, .epoch, .urevent,
%                    .hedtags, and .usertags. The user can over-ride these
%                    tags using this name-value parameter.
%   'Fields'         A cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty,
%                    only these fields are tagged.
%   'Precision'      The precision that the .data field should be converted
%                    to. The options are 'Preserve', 'Double' and 'Single'.
%                    'Preserve' retains the .data field precision, 'Double'
%                    converts the .data field to double precision, and
%                    'Single' converts the .data field to single precision.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'PrimaryField'   The name of the primary field. Only one field can be
%                    the primary field. A primary field requires a label,
%                    category, and a description.
%   'SaveDatasets'   If true (default), save the tags to the underlying
%                    dataset files in the directory.
%   'SaveMapFile'    The full path name of the file for saving the final,
%                    consolidated fieldMap object that results from the
%                    tagging process.
%   'SaveMode'       The options are 'OneFile' and 'TwoFiles'. 'OneFile'
%                    saves the EEG structure in a .set file. 'TwoFiles'
%                    saves the EEG structure without the data in a .set
%                    file and the transposed data in a binary float .fdt
%                    file. If the 'Precision' input argument is 'Preserve'
%                    then the 'SaveMode' is ignored and the way that the
%                    file is already saved will be retained.
%   'SelectFields'   If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%   'UseGui'         If true (default), the CTAGGER GUI is displayed after
%                    initialization.
%
% See also: tageeg, tagstudy
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
%
% $Log: tagdir.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function [fMap, fPaths, excluded] = tagstudy(studyFile, varargin)
% Tag all of the EEG files in a study
p = parseArguments();

excluded = '';

% Consolidate all of the tags from the study
[s, fPaths] = loadstudy(p.StudyFile);
[fMap, fMapTag] = findtags(s, 'ExcludeFields', p.ExcludeFields, ...
    'Fields', p.Fields, 'PreservePrefix', p.PreservePrefix);

% Merge the tags for the study from individual files
if isempty(fPaths)
    warning('tagstudy:nofiles', 'No files in study\n');
    return;
end

for k = 1:length(fPaths) % Assemble the list
    eegTemp = pop_loadset(fPaths{k});
    [tMapNew, tMapTagNew] = findtags(eegTemp, 'PreservePrefix', ...
        p.PreservePrefix, 'ExcludeFields', p.ExcludeFields, 'Fields', ...
        p.Fields);
    fMap.merge(tMapNew, 'Merge', p.ExcludeFields, tMapNew.getFields());
    fMapTag.merge(tMapTagNew, 'Merge', p.ExcludeFields, p.Fields);
end

% Exclude the appropriate tags from baseTags
excluded = p.ExcludeFields;
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
canceled = false;
if p.UseGui && p.SelectFields && isempty(p.Fields)
    fprintf('\n---Now select the fields you want to tag---\n');
    [fMapTag, exc, canceled] = selectmaps(fMapTag, 'PrimaryField', ...
        p.PrimaryField);
    excluded = union(excluded, exc);
elseif ~isempty(p.PrimaryField)
    fMapTag.setPrimaryMap(p.PrimaryField);
end

if p.UseGui && ~canceled
    [fMapTag, canceled] = editmaps(fMapTag, 'EditXml', p.EditXml, ...
        'PreservePrefix', p.PreservePrefix);
end

fMap.merge(fMapTag, 'Replace', p.ExcludeFields, fMapTag.getFields());
fMap.merge(fMapTag, 'Merge', p.ExcludeFields, fMapTag.getFields());

if ~canceled
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
            if isequal(p.Precision, 'double') && isa(EEG.data, 'single')
                EEG.data = double(EEG.data);
            elseif isequal(p.Precision, 'single') && isa(EEG.data, 'double')
                EEG.data = single(EEG.data);
            end
            
            if isequal(p.SaveMode, 'onefile') || isequal(p.Precision, 'double')
                pop_saveset(EEG, 'filename', EEG.filename, 'filepath', ...
                    EEG.filepath, 'savemode', 'onefile');
            elseif isequal(p.SaveMode, 'twofiles') || findDatFile()
                pop_saveset(EEG, 'filename', EEG.filename, 'filepath', ...
                    EEG.filepath, 'savemode', 'twoFiles');
            else
                pop_saveset(EEG, 'filename', EEG.filename, 'filepath', ...
                    EEG.filepath,'savemode', 'resave');
            end
        end
    end
    
    % Rewrite to the study file
    s = writetags(s, fMap, 'PreservePrefix', ...
        p.PreservePrefix);  %#ok<NASGU>
    save(p.StudyFile, 's', '-mat');
end

    function found = findDatFile()
        % Looks for a .dat file
        [~, fName] = fileparts(EEG.filename);
        found = 2 == exist([EEG.filepath filesep fName '.dat'], 'file');
    end % findDatFile

    function [s, fNames] = loadstudy(studyFile)
        % Set baseTags if tagsFile contains an tagMap object
        try
            t = load('-mat', studyFile);
            tFields = fieldnames(t);
            s = t.(tFields{1});
            sPath = fileparts(studyFile);
            fNames = getstudyfiles(s, sPath);
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

    function p = parseArguments()
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
        parser.addParamValue('Precision', 'Preserve', ...
            @(x) any(validatestring(lower(x), ...
            {'Double', 'Preserve', 'Single'})));
        parser.addParamValue('PreservePrefix', false, @islogical);
        parser.addParamValue('PrimaryField', '', @(x) ...
            (isempty(x) || ischar(x)))
        parser.addParamValue('SaveDatasets', true, @islogical);
        parser.addParamValue('SaveMapFile', '', ...
            @(x)(isempty(x) || (ischar(x))));
        parser.addParamValue('SaveMode', 'TwoFiles', ...
            @(x) any(validatestring(lower(x), {'OneFile', 'TwoFiles'})));
        parser.addParamValue('SelectFields', true, @islogical);
        parser.addParamValue('UseGui', true, @islogical);
        parser.parse(studyFile, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tagstudy