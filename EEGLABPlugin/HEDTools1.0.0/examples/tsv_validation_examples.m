% This file contains code examples for validating and replacing HED tags in
% a tab-separated file. You want to validate tags because the HED is
% constantly updated (tags are removed, reorganized, or renamed). Also, 
% tags have attributes that need to be enforced when specified. After 
% validation, invalid tags will need to be replaced in the validated file
% so that it meets HED requirements. A replace file will contain the
% invalid tag in the first column and its replacement in the second column.
% Be sure to run the validation again to make sure the replacement meets
% HED standards. 
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
% Validate the HED tags in a tab-separated file and write the issues to a
% variable
issues = validatetsv([exampleDir filesep ... 
    'BCIT_GuardDuty_HED_tag_spec_v25.tsv'], ...
    [2,3,4,5,6]);

%% Example 2
% Validate the HED tags in a tab-separated file and write the  issues to a
% file and create a replace file in the current directory. 
validatetsv([exampleDir filesep ... 
    'BCIT_GuardDuty_HED_tag_spec_v25.tsv'], ...
    [2,3,4,5,6], 'WriteOutput', true);

%% Example 3
% Find and replace the invalid HED tags with valid ones in a tab-separated
% file and generate a new file written to the current directory. 
replacetsv([exampleDir filesep ... 
    'BCIT_GuardDuty_HED_tag_spec_v25_replace.tsv'], ...
    [exampleDir filesep 'BCIT_GuardDuty_HED_tag_spec_v25.tsv'], ...
    [2,3,4,5,6], 'outputFile', ...
    'BCIT_GuardDuty_HED_tag_spec_v25_update.tsv');