% The file contains examples for tagging a EEG dataset and a directory of 
% EEG datasets. You want to tag datasets so that you can describe your
% events in a standardized way that other researchers use. This allows
% collaborators to search and extract events based on HED tags instead of
% codes which only the person who produced the data knows what they mean.  
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

%% Set the example directory (PLEASE SET THIS)
exampleDir = 'path\to\HEDToolsExampleArchive';

%% Example 1
% Tag the data in the EEG structure
EEG = pop_loadset([exampleDir filesep ...
    'sample_data' filesep 'eeglab_data1.set']);
[EEG, fMap, excluded] = tageeg(EEG, 'SaveDataset', true); %#ok<*ASGLU>

%% Example 2
% Tag the data in a specified directory
[fMap, fPaths, excluded] = tagdir([exampleDir filesep 'sample_data'], ...
    'SaveDatasets', true);