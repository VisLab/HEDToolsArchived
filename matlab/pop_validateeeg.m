% Allows a user to validate a EEG structure using a GUI.
%
% Usage:
%
%   >>  [issues, com] = pop_validateeeg(EEG)
%
%   >>  [issues, com] = pop_validateeeg(EEG, 'key1', value1 ...)
%
%   Optional:
%
%   'generateWarnings'
%                   True to include warnings in the log file in addition
%                   to errors. If false (default) only errors are included
%                   in the log file.
%
%   'hedXML'
%                   The full path to a HED XML file containing all of the
%                   tags. This by default will be the HED.xml file
%                   found in the hed directory.
%
%   'outDir'
%                   The directory where the validation output is written
%                   to. There will be a log file generated for each study
%                   dataset validated.
%
%   'writeOutput'
%                   If true (default), write the validation issues to a
%                   log file in addition to the workspace. If false only
%                   write the issues to the workspace.
%
% Output:
%
%   issues
%                   A cell array containing all of the issues found through
%                   the validation. Each cell corresponds to the issues
%                   found on a particular line.
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

function [issues, com] = pop_validateeeg(EEG, varargin)
issues = '';
com = '';
canceled = false;

% Display help if inappropriate number of arguments
if nargin < 1
    help pop_validateeeg;
    return;
end;

if nargin == 1
    [canceled, varargin] = validateeeg_input();
end

if canceled
    return;
end

issues = validateeeg(EEG, varargin{:});
com = char(['pop_validateeeg(' inputname(1) ', '...
    keyvalue2str(varargin{:}) ');']);

end % pop_validateeeg