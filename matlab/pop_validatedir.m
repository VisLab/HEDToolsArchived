% Allows a user to validate a directory of datasets using a GUI
%
% Usage:
%   >>  [fPaths, com] = pop_validatedir()
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


function [fPaths, com] = pop_validatedir()
fPaths = '';
com = '';
[cancelled, errorLogOnly, extensionsAllowed, hedXML, inDir, ...
    outDir, doSubDirs] = validatedir_input();
if cancelled
    return;
end
fPaths = validatedir(inDir, ...
    'doSubDirs', doSubDirs, ...
    'errorLogOnly', errorLogOnly, ...
    'extensionAllowed', extensionsAllowed, ...
    'hedXML', hedXML, ...
    'outDir', outDir);

com = char(['validatedir(''' inDir ''', ' ...
    '''doSubDirs'', ' logical2str(doSubDirs) ', ' ...
    '''errorLogOnly'', ' logical2str(errorLogOnly) ', ' ...
    '''extensionAllowed'', ' logical2str(extensionsAllowed) ', ' ...
    '''hedXML'', ''' hedXML ''', ' ...
    '''outDir'', ''' outDir ''', '')']);

end % pop_validatedir

function s = logical2str(b)
% Converts a logical value to a string
if b
    s = 'true';
else
    s = 'false';
end % logical2str

end % pop_validatedir