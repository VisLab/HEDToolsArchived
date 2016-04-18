% tageeg
% Allows a user to tag a EEG structure
%
% Usage:
%   >>  [EEG, fMap, excluded] = tageeg(EEG)
%   >>  [EEG, fMap, excluded] = tageeg(EEG, 'key1', 'value1', ...)
%
% Description:
% [EEG, fMap, excluded] = tageeg(EEG) creates a fieldMap object called
% fMap. First all of the tag information and potential fields are
% extracted from EEG.event, EEG.urevent, and EEG.etc.tags structures.
% After existing event tags are extracted and merged with an optional
% input fieldMap, the user is presented with a GUI to accept or exclude
% potential fields from tagging. Then the user is presented with the
% ctagger GUI to edit and tag. Finally, the tags are rewritten to
% the EEG structure.
%
% [EEG, fMap, excluded] = tageeg(EEG, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%   'BaseMap'        A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
%                    information.
%   'ExcludeFields'  A cell array of field names in the .event and .urevent
%                    substructures to ignore during the tagging process.
%                    By default the following subfields of the event
%                    structure are ignored: .latency, .epoch, .urevent,
%                    .hedtags, and .usertags. The user can over-ride these
%                    tags using this name-value parameter.
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
% documentation for tageeg:
%
%    doc tageeg
%
% See also: tagdir, tagcsv, tagstudy
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
% $Log: tageeg.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function [EEG, fMap, excluded] = tageeg(EEG, varargin)
% Parse the input arguments
parser = inputParser;
parser.addRequired('EEG', @(x) (isempty(x) || isstruct(EEG)));
parser.addParamValue('BaseMap', '', ...
    @(x)(isempty(x) || ischar(x) || isa(x, 'fieldMap')));
parser.addParamValue('EditXml', false, @islogical);
parser.addParamValue('ExcludeFields', ...
    {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
    @(x) (iscellstr(x)));
parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
parser.addParamValue('PreservePrefix', false, @islogical);
parser.addParamValue('RewriteOption', 'both', ...
    @(x) any(validatestring(lower(x), ...
    {'Both', 'Individual', 'None', 'Summary'})));
parser.addParamValue('SaveMapFile', '', @(x)(isempty(x) || (ischar(x))));
parser.addParamValue('SelectOption', true, @islogical);
parser.addParamValue('Synchronize', false, @islogical);
parser.addParamValue('UseGui', true, @islogical);
parser.parse(EEG, varargin{:});
p = parser.Results;

% Get the existing tags for the EEG
fMap = findtags(p.EEG, 'PreservePrefix', p.PreservePrefix, ...
    'ExcludeFields', p.ExcludeFields, 'Fields', p.Fields);

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
    % Save the fieldmap
    if ~isempty(p.SaveMapFile) && ~fieldMap.saveFieldMap(p.SaveMapFile, fMap)
        warning('tageeg:invalidFile', ...
            ['Couldn''t save fieldMap to ' p.SaveMapFile]);
    end
    
    % Now finish writing the tags to the EEG structure
    EEG = writetags(EEG, fMap, 'ExcludeFields', excluded, ...
        'PreservePrefix', p.PreservePrefix, ...
        'RewriteOption', p.RewriteOption);
end
end % tageeg