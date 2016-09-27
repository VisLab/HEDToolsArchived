% Go through the study and find all of the dataset file paths
%
% Input:
%
%   studyFile
%                    The path to a EEG study.
%
% Output:
%
%   study
%                    A EEG study structure.
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

function [study, fPaths] = loadstudy(studyFile)
% Load the study file
try
    study = load('-mat', studyFile);
    sPath = fileparts(studyFile);
    fPaths = getstudyfiles(study.STUDY, sPath);
catch 
    warning('loadstudy:invalidStudyFile', 'Invalid study file');
    study = '';
    fPaths = '';
end
end % loadstudy