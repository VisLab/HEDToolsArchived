% Allows a user to validate the HED tags in a EEGLAB study and its
% associated .set files using a GUI.
%
% Usage:
%
%   >>  com = pop_validatestudy()
%
% Output:
%
%       com
%                  String containing call to tagstudy with all parameters
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
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

function com = pop_validatestudy()
% Get the input parameters
[canceled, generateWarnings, hedXML, outDir, studyFile] = ...
    validatestudy_input();
if canceled
    com = '';
    return;
end

% Validate the EEG study
validatestudy(studyFile, ...
    'generateWarnings', generateWarnings, ...
    'hedXML', hedXML, ...
    'outDir', outDir);

% Create command string
com = char(['tagstudy(''' studyFile ''', ' ...
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

end % pop_validatestudy