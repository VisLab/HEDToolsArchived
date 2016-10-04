% Allows a user to tag a EEG structure using a GUI.
%
% Usage:
%
%   >>  [EEG, com] = pop_tageeg(EEG)
%
% Input:
%
%   Required:
%
%   EEG
%                    The EEG dataset structure that will be tagged. The
%                    dataset will need to have a .event field.
%
% Output:
%
%   EEG
%                    The EEG dataset structure that has been tagged. The
%                    tags will be written to the .usertags field under
%                    the .event field.
%
%   com
%                    String containing call to tageeg with all parameters.
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

function [EEG, com] = pop_tageeg(EEG)
% Create the tagger for a single EEG file
com = '';

% Display help if inappropriate number of arguments
if nargin < 1
    help pop_tageeg;
    return;
end;

% Get the input parameters
[baseMap, canceled, extensionsAllowed, extensionsAnywhere, ...
    preservePrefix, selectFields, useGUI] = tageeg_input();
if canceled
    return;
end

% Tag the EEG structure
[EEG, fMap, canceled] = tageeg(EEG, 'BaseMap', baseMap, ...
    'ExtensionsAllowed', extensionsAllowed, 'ExtensionsAnywhere', ...
    extensionsAnywhere, 'PreservePrefix', preservePrefix, ...
    'SelectFields', selectFields, 'UseGUI', useGUI);
if canceled
    return;
end

[overwriteDataset, savefMap, fMapPath, fMapDescription] = savetags_input();

if fMapDescription
    fMap.setDescription(fMapDescription);
    EEG.etc.tags.description = fMapDescription;
end

if savefMap && ~isempty(fMapPath)
    savefmap(fMap, fMapPath);
end

if overwriteDataset
    EEG = overwritedataset(fMap, EEG, 'PreservePrefix', preservePrefix);
end

% Create command string
com = char(['tageeg(''BaseMap'', ''' baseMap ''', ' ...
    '''ExtensionsAllowed'', ' logical2str(extensionsAllowed) ', ' ...
    '''ExtensionsAnywhere'', ' logical2str(extensionsAnywhere) ', ' ...
    '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
    '''SaveDataset'', ''' logical2str(overwriteDataset) ''', ' ...
    '''SaveMapFile'', ''' fMapPath ''', ' ...
    '''SelectFields'', ' logical2str(selectFields) ', ' ...
    '''UseGui'', ' logical2str(useGUI) ')']);

    function s = logical2str(b)
        % Converts a logical to a string
        if b
            s = 'true';
        else
            s = 'false';
        end
    end % logical2str

end % pop_tageeg