% Usage:
%
%   >>  output = writefmap(fMap, location)
%
%   >>  output = writefmap(fMap, location, 'key1', 'value1', ...)
%
% Input:
%
%   fMap
%                    A fieldMap object that contains the tag map
%                    information.
%
%   location
%                    The location to write the fieldMap tags to. The
%                    location can be a string which is either the full
%                    path of a directory containing datasets or the full
%                    path of a EEG study. If the location is a EEG
%                    structure then the fMap will be written to the
%                    structure and the underlying dataset file.
%
%   Optional (key/value):
%
%   doSubDirs        If true (default), the entire location directory tree
%                    is searched. If false, only the location directory is
%                    searched.
%
% Output:
%
%   output
%                    A one-dimensional cell array of full file names of the
%                    datasets to be tagged is returned if the location is
%                    the full path of a directory containing datasets or
%                    the full path of a EEG study. A tagged EEG structure
%                    is returned if a structure is passed in.
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

function output = overwritedataset(fMap, location, varargin)
p = parseArguments(fMap, location, varargin{:});
if ischar(p.fMap)
    p.fMap = fieldMap.loadFieldMap(p.fMap);
end
isStudy = false;
if ischar(p.location)
    [path,~, ext] = fileparts(p.location);
    if ~isempty(ext) && strcmpi(ext, '.study')
        [study, fPaths] = loadstudy(p.location);
        isStudy = true;
    elseif ~isempty(path)
        fPaths = getfilelist(p.location, '.set', p.DoSubDirs);
    else
        warning('writefmap:invalidPath', ['Invalid path to' ...
            ' directory or study file']);
    end
elseif isstruct(p.location)
    EEG = writetags(p.location, p.fMap, 'PreservePrefix', p.PreservePrefix);
    output = pop_saveset(EEG, 'filename', p.location.filename, ...
        'filepath', p.location.filepath);
    return;
end
fprintf(['\n---Now rewriting the tags to the individual' ...
    ' data files---\n']);
for k = 1:length(fPaths) % Assemble the list
    eventFields = {};
    EEG = pop_loadset(fPaths{k});
    eventFields = union(eventFields, fieldnames(EEG.event));
    EEG = writetags(EEG, p.fMap, 'PreservePrefix', p.PreservePrefix);
    pop_saveset(EEG, 'filename', EEG.filename, 'filepath', EEG.filepath);
end
if isStudy
    % Rewrite to the study file
    study.STUDY = writetags(study.STUDY, p.fMap, 'Fields', eventFields, ...
        'PreservePrefix', p.PreservePrefix);
    save(p.location, '-struct', 'study');
end
output = fPaths;

    function p = parseArguments(fMap, location, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('fMap', @(x) isa(x, 'fieldMap') || ...
            ischar(x));
        parser.addRequired('location', @(x) ischar(x) || isstruct(x));
        parser.addParamValue('DoSubDirs', true, @islogical);
        parser.addParamValue('PreservePrefix', false, @islogical);
        parser.parse(fMap, location, varargin{:});
        p = parser.Results;
    end % parseArguments

end % overwritedataset