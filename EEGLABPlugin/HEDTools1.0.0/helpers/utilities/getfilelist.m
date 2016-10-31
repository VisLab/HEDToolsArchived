% Gets a list of the files in a directory tree.
%
% Usage:
%
%   >>  fPaths = getfilelist(inDir, fileExt, doSubDirs)
%
% Input:
%
%   Required:
%
%   inDir
%                    The full path to a directory tree.
%
%   fileExt
%                    The file extension of the files to search for in the
%                    inDir directory tree.
%
%   doSubDirs        If true (default) the entire inDir directory tree is
%                    searched. If false only the inDir directory is
%                    searched.
%
% Output:
%
%   fPaths
%                    A one-dimensional cell array of full file names that
%                    have the file extension 'fileExt'.
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function fPaths = getfilelist(inDir, fileExt, doSubDirs)
fPaths = {};
directories = {inDir};
while ~isempty(directories)
    nextDir = directories{end};
    files = dir(nextDir);
    fileNames = {files.name}';
    fileDirs = cell2mat({files.isdir}');
    compareIndex = ~strcmp(fileNames, '.') & ~strcmp(fileNames, '..');
    subDirs = strcat([nextDir filesep], fileNames(compareIndex & fileDirs));
    fileNames = fileNames(compareIndex & ~fileDirs);
    if nargin > 1 && ~isempty(fileExt) && ~isempty(fileNames);
        fileNames = processExts(fileNames, fileExt);
    end
    fileNames = strcat([nextDir filesep], fileNames);
    directories = [directories(1:end-1); subDirs(:)];
    fPaths = [fPaths(:); fileNames(:)];
    if nargin > 2 && ~doSubDirs
        break;
    end
end

    function fileNames = processExts(fileNames, fileExt)
        % Return a cell array of file names with the specified file extension
        fExts = cell(length(fileNames), 1);
        for k = 1:length(fileNames)
            [x, y, fExts{k}] = fileparts(fileNames{k}); %#ok<ASGLU>
        end
        matches = strcmp(fExts, fileExt);
        fileNames = fileNames(matches);
    end % processExts

end % getfilelist