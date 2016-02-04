% tagdir
% Allows a user to tag an entire tree directory of similar EEG .set files
%
% Usage:
%   >>  [fMap, fPaths, excluded] = tagdir(inDir)
%   >>  [fMap, fPaths, excluded] = tagdir(inDir, 'key1', 'value1', ...)
%
% Description:
% [fMap, fPaths, excluded] = tagdir(inDir) extracts a consolidated
% fieldMap object from the data files in the directory tree inDir. The 
% inDir must be a valid path.
%
% First the events and tags from all data files are extracted and
% consolidated into a single fieldMap object by merging all of the
% existing tags. Then the user is presented with a GUI for choosing
% which fields to tag. The ctagger GUI is displayed so that users can
% edit/modify the tags. The GUI is launched in asynchronous mode.
% Finally the tags are rewritten to the data files.
%
% The final, consolidated and edited fieldMap object is returned in fMap,
% and fPaths is a cell array containing the full path names of all of the
% matched files that were affected. If fPaths is empty, then fMap will
% not contain any tag information.
%
% [fMap, fPaths, excluded] = tagdir(inDir, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%   'BaseMap'        A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
%                    information.
%   'DbCreds'        Name of a property file containing the database
%                    credentials. If this argument is not provided, a
%                    database is not used. (See notes.)
%   'DoSubDirs'      If true (default), the entire inDir directory tree is
%                    searched. If false, only the inDir directory is
%                    searched.
%   'ExcludeFields'  A cell array of field names in the .event and .urevent
%                    substructures to ignore during the tagging process. By
%                    default the following subfields of the event structure
%                    are ignored: .latency, .epoch, .urevent, .hedtags, and
%                    .usertags. The user can over-ride these tags using
%                    this name-value parameter.
%   'Fields'         A cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty, only
%                    these fields are tagged.
%   'PreservePrefix' If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'RewriteOption'  A string indicating how tag information should be
%                    written to the datasets. The options are 'Both',
%                    'Individual', 'None', and 'Summary'.
%   'SaveMapFile'    A string representing the file name for saving the
%                    final, consolidated fieldMap object that results from
%                    the tagging process.
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
% Notes on tag rewrite:
%   The tags are written to the data files in two ways. In both cases
%   the dataset x is assumed to be a MATLAB structure:
%   1) If the 'RewriteOption' is either 'Both' or 'Summary', the tags
%      are written to the dataset in the x.etc.tags field:
%            x.etc.tags.xml
%            x.etc.tags.map(1).field
%            x.etc.tags.map(1).values ...
%                   ...
%
%   2) If the 'RewriteOption' is either 'Both' or 'Individual', the tags
%      are also written to x.event.usertags based on the individual
%      values of their events.
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for tagdir:
%
%    doc tagdir
%
% See also: tageeg and tagstudy
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

function [fMap, fPaths, excluded] = tagdir(inDir, varargin)
% Parse the input arguments
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
    parser.addParamValue('RewriteOption', 'both', ...
        @(x) any(validatestring(lower(x), ...
        {'Both', 'Individual', 'None', 'Summary'})));
    parser.addParamValue('SaveMapFile', '', @(x)(ischar(x)));
    parser.addParamValue('SelectOption', true, @islogical);
    parser.addParamValue('Synchronize', false, @islogical);
    parser.addParamValue('UseGui', true, @islogical);
    parser.parse(inDir, varargin{:});
    p = parser.Results;

    fprintf('\n---Loading the data files to merge the tags---\n');
    fMap = '';
    excluded = '';
    fPaths = getfilelist(p.InDir, '.set', p.DoSubDirs);
    if isempty(fPaths)
        warning('tagdir:nofiles', 'No files met tagging criteria\n');
        return;
    end
    fMap = fieldMap('PreservePrefix',  p.PreservePrefix);
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

    if p.SelectOption
        fprintf('\n---Now select the fields you want to tag---\n');
        [fMap, exc] = selectmaps(fMap, 'Fields', p.Fields);
        excluded = union(excluded, exc);
    end

    if p.UseGui
    fMap = editmaps(fMap, 'EditXml', p.EditXml, 'PreservePrefix', ...
        p.PreservePrefix, 'Synchronize', p.Synchronize);
    end

    % Save the tags file for next step
    if ~isempty(p.SaveMapFile) && ~fieldMap.saveFieldMap(p.SaveMapFile, ...
            fMap)
        warning('tagdir:invalidFile', ...
            ['Couldn''t save fieldMap to ' p.SaveMapFile]);
    end

    if isempty(fPaths) || strcmpi(p.RewriteOption, 'none')
        return;
    end

    % Rewrite all of the EEG files with updated tag information
    fprintf(['\n---Now rewriting the tags to the individual data' ...
        ' files---\n']);
    for k = 1:length(fPaths) % Assemble the list
        teeg = pop_loadset(fPaths{k});
        teeg = writetags(teeg, fMap, 'ExcludeFields', excluded, ...
            'PreservePrefix', p.PreservePrefix, ...
            'RewriteOption', p.RewriteOption);
        pop_saveset(teeg, 'filename', fPaths{k});
    end
end % tagdir