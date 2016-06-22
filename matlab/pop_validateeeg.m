% Allows a user to validate a EEG structure using a GUI
%
% Usage:
%   >>  [errorLog, warningLog, extensionLog, com] = pop_validateeeg(EEG);
%
% Note: The primary purpose of pop_tageeg is to package up parameter input
% and calling of tageeg for use as a plugin for EEGLAB (Edit menu).
%
%
% See also:
%   eeglab, tageeg, tagdir, tagstudy, and eegplugin_ctagger
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


function [errorLog, warningLog, extensionLog, com] = pop_validateeeg(EEG)
errorLog = '';
warningLog = '';
extensionLog = '';
com = '';

if nargin < 1
    help pop_validateeeg;
    return;
end;

[cancelled, errorLogOnly, extensionsAllowed, hedXML, outDir] = ...
    validateeeg_input();
if cancelled
    return;
end

[errorLog, warningLog, extensionLog] = validateeeg(EEG, ...
    'errorLogOnly', errorLogOnly, ...
    'extensionAllowed', extensionsAllowed, ...
    'hedXML', hedXML, ...
    'outDir', outDir, ...
    'writeOutput', true);
com = char(['validateeeg(EEG, ' ...
    '''errorLogOnly'', ' logical2str(errorLogOnly) ', ' ...
    '''extensionAllowed'', ' logical2str(extensionsAllowed) ', ' ...
    '''hedXML'', ''' hedXML ''', ' ...
    '''outDir'', ''' outDir ''', ' ...
    '''writeOutput'', ' 'true)']);
end % pop_validateeeg

function s = logical2str(b)
% Converts a logical value to a string
if b
    s = 'true';
else
    s = 'false';
end
end % logical2str