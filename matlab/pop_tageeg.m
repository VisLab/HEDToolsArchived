% Allows a user to tag a EEG structure using a GUI
%
% Usage:
%   >>  [EEG, com] = pop_tageeg(EEG)
%
% Copyright (C) 2012-2013 Thomas Rognon tcrognon@gmail.com and
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

function [EEG, com] = pop_tageeg(EEG)
% Create the tagger for a single EEG file
com = '';

% Display help if inappropriate number of arguments
if nargin < 1
    help pop_tageeg;
    return;
end;

% Get the tagger input parameters
[baseMap, canceled, editXml, preservePrefix, saveMapFile, ...
    selectFields, useGUI] = tageeg_input();
if canceled
    return;
end

% Tag the EEG structure and return the command string
[EEG, ~, canceled] = tageeg(EEG, 'BaseMap', baseMap, ...
    'EditXml', editXml, ...
    'PreservePrefix', preservePrefix, ...
    'SaveMapFile', saveMapFile, ...
    'SelectFields', selectFields, ...
    'UseGUI', useGUI);
if canceled
    return;
end
com = char(['tageeg(''BaseMap'', ''' baseMap ''', ' ...
    '''EditXml'', ' logical2str(editXml) ', ' ...
    '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
    '''SaveMapFile'', ''' saveMapFile ''', ' ...
    '''SelectFields'', ' logical2str(selectFields) ', ' ...
    '''UseGui'', ' logical2str(useGUI) ')']);

    function s = logical2str(b)
        if b
            s = 'true';
        else
            s = 'false';
        end
        
    end % logical2str

end % pop_tageeg