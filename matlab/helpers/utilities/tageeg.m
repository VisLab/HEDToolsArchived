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
%                    in the tagging. If this parameter is non-empty, only
%                    these fields are tagged.
%   'PreservePrefix' If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'PrimaryField'   The name of the primary field. Only one field can be
%                    the primary field. A primary field requires a label,
%                    category, and a description.
%   'SaveMapFile'    A string representing the file name for saving the
%                    final, consolidated fieldMap object that results from
%                    the tagging process.
%   'SaveMode'       The options are 'OneFile' and 'TwoFiles'. 'OneFile'
%                    saves the EEG structure in a .set file. 'TwoFiles'
%                    saves the EEG structure without the data in a .set
%                    file and the transposed data in a binary float .fdt
%                    file. If the 'Precision' input argument is 'Preserve'
%                    then the 'SaveMode' is ignored and the way that the
%                    file is already saved will be retained.zzz
%   'SelectFields'   If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%   'UseGui'         If true (default), the CTAGGER GUI is displayed after
%                    initialization.
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
p = parseArguments();

% Get the existing tags for the EEG
[fMap, fMapTag] = findtags(p.EEG, 'PreservePrefix', p.PreservePrefix, ...
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
    % Save the fieldmap
    if ~isempty(p.SaveMapFile) && ~fieldMap.saveFieldMap(p.SaveMapFile, ...
            fMap)
        warning('tageeg:invalidFile', ...
            ['Couldn''t save fieldMap to ' p.SaveMapFile]);
    end
    
    % Now finish writing the tags to the EEG structure
    EEG = writetags(EEG, fMap, 'PreservePrefix', p.PreservePrefix);
end

    function p = parseArguments()
        % Parses the input arguments and returns the results
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
        parser.addParamValue('PrimaryField', '', @(x) ...
            (isempty(x) || ischar(x)))
        parser.addParamValue('SaveMapFile', '', @(x)(isempty(x) || ...
            (ischar(x))));
        parser.addParamValue('SelectFields', true, @islogical);
        parser.addParamValue('UseGui', true, @islogical);
        parser.parse(EEG, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tageeg