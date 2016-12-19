% Copies .set dataset files from a study or directory to another directory.
%
% Usage:
%
%   >>  fpaths = copysetfiles(fMap, source, destination)
%
%   >>  fpaths = copysetfiles(fMap, source, destination, ...
%       'key1', 'value1', ...)
%
% Input:
%
%   fMap
%                    A fieldMap object that contains the HED tags.
%
%   source
%                    The source to copy the .set files from. The
%                    source can be a cell string containing paths to
%                    datasets, a string containing the full
%                    path of a directory containing datasets, or the full
%                    path of a EEG study.
%
%   destination
%                    The directory to copy the datasets. If the directory
%                    doesn't exist then it is created.
%
%   Optional (key/value):
%
%   doSubDirs        If true (default), the entire source directory tree
%                    is searched. If false, only the source directory is
%                    searched. This argument only applies when the source
%                    is a directory.
%
% Output:
%
%   fpaths
%                    A one-dimensional cell array of full file names of the
%                    datasets that were tagged from the fieldMap object.
%                    Any files that don't exist will be ignored.
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

function fPaths = copysetfiles(fMap, source, destination, varargin)
p = parseArguments(fMap, source, destination, varargin{:});
isStudy = false;
isDir = false;
if ~isequal(p.destination(end), '/') && ~isequal(p.destination(end), '\')
    p.destination = [p.destination filesep];
end
if ischar(p.fMap)
    p.fMap = fieldMap.loadFieldMap(p.fMap);
end
if iscellstr(p.source)
    fPaths = p.source;
elseif ischar(p.source)
    [path,~, ext] = fileparts(p.source);
    if ~isempty(ext) && strcmpi(ext, '.study')
        [study, fPaths] = loadstudy(p.source);
        isStudy = true;
    elseif ~isempty(path)
        fPaths = getfilelist(p.source, '.set', p.DoSubDirs);
        isDir = true;
    else
        warning('copysetfiles:invalidPath', ['Invalid path to' ...
            ' source directory or study file']);
    end
end
if ~exist(p.destination, 'dir')
    mkdir(p.destination);
end
fprintf('\n---Now copying the individual data files---\n');
if isDir
    for k = 1:length(fPaths)
        try
            EEG = pop_loadset(fPaths{k});
            destination = p.destination;
            [~, file, ext] = fileparts(fPaths{k});
            fPathLeftOver = strrep(fPaths{k}, p.source, '');
            leftOverDir = fileparts(fPathLeftOver);
            if length(leftOverDir) > 1
                destination = fullfile(destination, leftOverDir); 
            end
            fPaths{k} = fullfile(destination, [file ext]);
            if ~exist(destination, 'dir')
                mkdir(destination);
            end
            pop_saveset(EEG, 'filepath', fPaths{k});
        catch
            warning('File %s does not exist ... ignoring file', fPaths{k});
            fPaths{k} = '';
        end
    end
else
    for k = 1:length(fPaths)
        try
            EEG = pop_loadset(fPaths{k});
            [~, file, ext] = fileparts(fPaths{k});
            fPaths{k} = [p.destination file ext];
            pop_saveset(EEG, 'filepath', fPaths{k});
        catch
            warning('File %s does not exist ... ignoring file', fPaths{k});
            fPaths{k} = '';
        end
    end
end
fPaths = fPaths(~cellfun(@isempty, fPaths));
if isStudy
    % Copy the study file
    fprintf('\n---Now copying the study file---\n');
    [study.STUDY.datasetinfo.filepath] = deal(p.destination);
    
    [~, file, ext] = fileparts(p.source);
    save([p.destination filesep file ext], '-struct', 'study');
end

    function p = parseArguments(fMap, source, destination, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('fMap', @(x) isa(x, 'fieldMap') || ...
            ischar(x));
        parser.addRequired('source', @(x) ischar(x) || iscellstr(x));
        parser.addRequired('destination', @(x) ischar(x) || iscellstr(x));
        parser.addParamValue('DoSubDirs', true, @islogical);
        parser.parse(fMap, source, destination, varargin{:});
        p = parser.Results;
    end % parseArguments

end % copysetfiles