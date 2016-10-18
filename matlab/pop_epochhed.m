% Allows a user to extract epochs based on HED tags using a GUI.
%
% Usage:
%   >>  pop_hedepoch(EEG);
%
% Inputs:
%
%   EEG        Input dataset. Data may already be epoched; in this case,
%              extract (shorter) subepochs time locked to epoch events.
%
% Outputs:
%
%   EEG        Output dataset that has extracted data epochs.
%
%   com        A command string that calls the underlying hedepoch
%              function.
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

function [EEG, indices, com] = pop_epochhed(EEG)
indices = [];
com = '';
% Display help if inappropriate number of arguments
if nargin < 1
    help pop_epochhed;
    return;
end;

% Find all the unique tags in the events
uniquetags = finduniquetags(arrayfun(@concattags, EEG.event, ...
        'UniformOutput', false));

% Get input arguments from GUI
[canceled, tags, newName, timeLim, valueLim] = ...
    epochhed_input(EEG.setname, uniquetags);

if canceled
    return;
end

[EEG, indices] = epochhed(EEG, tags, 'timelim', timeLim, ...
    'newname', newName, 'valuelim', valueLim);

com = char(['epochhed(EEG,' ...
    '''timelim'', ' vector2str(timeLim) ', ' ...
    '''newname'', ''' newName ''', ' ...
    '''valuelim'', ' vector2str(valueLim) ')']);

end % pop_epochhed