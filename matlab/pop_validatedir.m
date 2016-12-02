% Allows a user to validate a directory of EEG .set datasets using a GUI.
%
% Usage:
%
%   >>  [fPaths, com] = pop_validatedir()
%
%   >>  [fPaths, com] = pop_validatedir(inDir)
%
%   >>  [fPaths, com] = pop_validatedir(inDir, 'key1', value1 ...)
%
% Input:
%
%   inDir
%                   A directory containing EEG datasets that will be
%                   validated.
%
%   Optional (key/value):
%
%   'doSubDirs'
%                   If true (default), the entire inDir directory tree is
%                   searched. If false, only the inDir directory is
%                   searched.
%
%   'generateWarnings'
%                   If true, include warnings in the log file in addition
%                   to errors. If false (default), only errors are included
%                   in the log file.
%
%   'hedXML'
%                   The full path to a HED XML file containing all of the
%                   tags. This by default will be the HED.xml file
%                   found in the hed directory.
%
%   'outDir'
%                   The directory where the log files are written to.
%                   There will be a log file generated for each directory
%                   dataset validated. The default directory will be the
%                   current directory.
%
% Output:
%
%   fPaths           A list of full file names of the datasets to be
%                    validated.
%
%   com              String containing call to tagdir with all
%                    parameters.
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA


function [fPaths, com] = pop_validatedir(inDir, varargin)
canceled = false;

if nargin == 0
    inDir = '';
end

if nargin < 2
    [canceled, inDir, varargin] = validatedir_input(inDir);
end

if canceled
    fPaths = '';
    com = '';
    return;
end

fPaths = validatedir(inDir, varargin{:});
com = char(['pop_validatedir(' '''' inDir ''', '...
    keyvalue2str(varargin{:}) ');']);

end % pop_validatedir