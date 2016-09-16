% Allows a user to validate a EEG structure using a GUI
%
% Usage:
%
%   >>  [issues, com] = pop_validateeeg(EEG)
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

function [issues, com] = pop_validateeeg(EEG)
issues = '';
com = '';

% Display help if inappropriate number of arguments
if nargin < 1
    help pop_validateeeg;
    return;
end;

% Get the input parameters
[canceled, generateWarnings, hedXML, outDir] = ...
    validateeeg_input();
if canceled
    return;
end

% Validate the EEG dataset
issues = validateeeg(EEG, ...
    'generateWarnings', generateWarnings, ...
    'hedXML', hedXML, ...
    'outDir', outDir, ...
    'writeOutput', true);

% Create command string
com = char(['validateeeg(EEG, ' ...
    '''generateWarnings'', ' logical2str(generateWarnings) ', ' ...
    '''hedXML'', ''' hedXML ''', ' ...
    '''outDir'', ''' outDir ''', ' ...
    '''writeOutput'', ' 'true)']);

    function s = logical2str(b)
        % Converts a logical value to a string
        if b
            s = 'true';
        else
            s = 'false';
        end
    end % logical2str

end % pop_validateeeg