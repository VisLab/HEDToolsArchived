% Go through the study and find all of the dataset file paths
%
% Input:
%
%   study
%                    A EEG study structure.
%
%   sPath
%                    The path to a EEG study.
%
% Output:
%
%   fPaths
%                    A one-dimensional cell array of full file names of the
%                    study datasets.
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

function fPaths = getstudyfiles(study, sPath)
datasets = {study.datasetinfo.filename};
paths = {study.datasetinfo.filepath};
validPaths = true(size(paths));
fPaths = cell(size(paths));
for ik = 1:length(paths)
    fPath = fullfile(paths{ik}, datasets{ik}); % Absolute path
    if ~exist(fPath, 'file')  % Relative to stored study path
        fPath = fullfile(study.filepath, paths{ik}, datasets{ik});
    end
    if ~exist(fPath, 'file') % Relative to actual study path
        fPath = fullfile(sPath, paths{ik}, datasets{ik});
    end
    if ~exist(fPath, 'file') % Give up
        warning('getstudyfiles:invalidfile', ...
            ['Study file ' fname ' doesn''t exist']);
        validPaths(ik) = false;
    end
    fPaths{ik} = fPath;
end
fPaths(~validPaths) = [];  % Get rid of invalid paths
end % getstudyfiles