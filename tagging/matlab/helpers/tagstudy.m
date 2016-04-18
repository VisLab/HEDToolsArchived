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
%   'ExcludeFields'  A cell array of field names in the .event and .urevent
%                    substructures to ignore during the tagging process.
%                    By default the following subfields of the event
%                    structure are ignored: .latency, .epoch, .urevent,
%                    .hedtags, and .usertags. The user can over-ride these
%                    tags using this name-value parameter.
%   'Fields'         A cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty,
%                    only these fields are tagged.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'RewriteOption'  A string indicating how tag information should be
%                    written to the datasets. The options are 'Both',
%                    'Individual', 'None', 'Summary'.
%   'SaveMapFile'    The full path name of the file for saving the final,
%                    consolidated fieldMap object that results from the
%                    tagging process.
%   'SelectOption'   If true (default), the user is presented with dialog
%                    GUIs that allow users to select which fields to tag.
%   'Synchronize'    If false (default), the CTAGGER GUI is run with
%                    synchronization done using the MATLAB pause. If true,
%                    synchronization is done within Java. This latter
%                    option is usually reserved when not calling the GUI
%                    from MATLAB.
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
parser.addParamValue('RewriteOption', 'both', ...
    @(x) any(validatestring(lower(x), ...
    {'Both', 'Individual', 'None', 'Summary'})));
parser.addParamValue('SaveMapFile', '', ...
    @(x)(isempty(x) || (ischar(x))));
parser.addParamValue('SelectOption', true, @islogical);
parser.addParamValue('Synchronize', false, @islogical);
parser.addParamValue('UseGui', true, @islogical);
parser.parse(studyFile, varargin{:});
p = parser.Results;
excluded = '';

% Consolidate all of the tags from the study
[s, fPaths] = loadstudy(p.StudyFile);
fMap = findtags(s, 'ExcludeFields', p.ExcludeFields, ...
    'Fields', p.Fields, 'PreservePrefix', p.PreservePrefix);

% Merge the tags for the study from individual files
if isempty(fPaths)
    warning('tagstudy:nofiles', 'No files in study\n');
    return;
end

for k = 1:length(fPaths) % Assemble the list
    eegTemp = pop_loadset(fPaths{k});
    tMapNew = findtags(eegTemp, 'PreservePrefix', p.PreservePrefix, ...
        'ExcludeFields', p.ExcludeFields, 'Fields', p.Fields);
    fMap.merge(tMapNew, 'Merge', p.ExcludeFields, p.Fields);
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
fMap.merge(baseTags, 'Merge', excluded);
canceled = false;
if p.SelectOption
    fprintf('\n---Now select the fields you want to tag---\n');
    [fMap, exc, canceled] = selectmaps(fMap, 'Fields', p.Fields);
    excluded = union(excluded, exc);
end

if p.UseGui && ~canceled
    [fMap, canceled] = editmaps(fMap, 'EditXml', p.EditXml, 'PreservePrefix', ...
        p.PreservePrefix, 'Synchronize', p.Synchronize);
end

if ~canceled
    % Save the tags file for next step
    if ~isempty(p.SaveMapFile) && ~fieldMap.saveFieldMap(p.SaveMapFile, fMap)
        warning('tagstudy:invalidFile', ...
            ['Couldn''t save fieldMap to ' p.SaveMapFile]);
    end
    
    if isempty(fPaths) || strcmpi(p.RewriteOption, 'none')
        return;
    end
    
    % Rewrite all of the EEG files with updated tag information
    fprintf('\n---Now rewriting the tags to the individual data files---\n');
    for k = 1:length(fPaths) % Assemble the list
        teeg = pop_loadset(fPaths{k});
        teeg = writetags(teeg, fMap, 'ExcludeFields', excluded, ...
            'PreservePrefix', p.PreservePrefix, ...
            'RewriteOption', p.RewriteOption);
        pop_saveset(teeg, 'filename', fPaths{k});
    end
    
    % Rewrite to the study file
    if strcmpi(p.RewriteOption, 'Both') || strcmpi(p.RewriteOption, 'Summary')
        s = writetags(s, fMap, 'ExcludeFields', excluded, ...
            'PreservePrefix', p.PreservePrefix, ...
            'RewriteOption', p.RewriteOption);  %#ok<NASGU>
        save(p.StudyFile, 's', '-mat');
    end
end

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
end % tagstudy