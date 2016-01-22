% getfilelist
% Gets a list of the files in a directory tree
%
% Usage:
%   >>  fPaths = getfilelist(inDir, fileExt, doSubDirs)
%
% Description:
% fPaths = getfilelist(inDir, fileExt, doSubDirs) gets a list of the
% files in a directory tree
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for getfilelist:
%
%    doc getfilelist
%
% See also: tagdir, tagdir_input, pop_tagdir
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
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
% $Log: getfilelist.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

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
end % getFileList

function fileNames = processExts(fileNames, fileExt)
% Return a cell array of file names with the specified file extension
fExts = cell(length(fileNames), 1);
for k = 1:length(fileNames)
    [x, y, fExts{k}] = fileparts(fileNames{k}); %#ok<ASGLU>
end
matches = strcmp(fExts, fileExt);
fileNames = fileNames(matches);
end % processExts
