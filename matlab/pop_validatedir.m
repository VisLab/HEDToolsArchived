% Allows a user to validate a directory of EEG .set datasets using a GUI.
%
% Usage:
%
%   >>  [fPaths, com] = pop_validatedir()
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


function [fPaths, com] = pop_validatedir()
fPaths = '';
com = '';

% Get the input parameters
[canceled, doSubDirs, generateWarnings, hedXML, inDir, outDir] ...
    = validatedir_input();
if canceled
    return;
end

% Validate the EEG directory
fPaths = validatedir(inDir, ...
    'doSubDirs', doSubDirs, ...
    'generateWarnings', generateWarnings, ...
    'hedXML', hedXML, ...
    'outDir', outDir);

% Create command string
com = char(['validatedir(''' inDir ''', ' ...
    '''doSubDirs'', ' logical2str(doSubDirs) ', ' ...
    '''generateWarnings'', ' logical2str(generateWarnings) ', ' ...
    '''hedXML'', ''' hedXML ''', ' ...
    '''outDir'', ''' outDir ''', '')']);

    function s = logical2str(b)
        % Converts a logical value to a string
        if b
            s = 'true';
        else
            s = 'false';
        end
    end % logical2str

end % pop_validatedir