% pop_tagstudy
% Allows a user to tag a EEGLAB study using a GUI
%
% Usage:
%   >>  [fMap, com] = pop_tagstudy()
%
% Outputs:
%    fMap   - a fieldMap object that contains the tag map information
%    com    - string containing call to tagstudy with all parameters
%
% Notes:
%  -  pop_tagstudy() is meant to be used as the callback under the
%     EEGLAB Study menu. It is a singleton and clicking
%     the menu item again will not create a new window if one already
%     exists.
%  -  The function first brings up a GUI to enter the parameters to
%     override the default values for tagstudy and then optionally allows
%     the user to use the ctagger GUI to modify the tags.
%
% See also:
%   eeglab, tageeg, tagdir, and eegplugin_ctagger
%
%
% Copyright (C) 2012-2013 Thomas Rognon tcrognon@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: pop_ctagger.m,v $
% Revision 1.0 21-Apr-2013 09:25:25  kay
% Initial version
%

function com = pop_validatestudy()
% Create the tagger for this EEG study
[cancelled, errorLogOnly, extensionsAllowed, hedXML, ...
    outDir, studyFile] = validatestudy_input();
if cancelled
    com = '';
    return;
end
validatestudy(studyFile, ...
    'errorLogOnly', errorLogOnly, ...
    'extensionAllowed', extensionsAllowed, ...
    'hedXML', hedXML, ...
    'outDir', outDir);

com = char(['tagstudy(''' studyFile ''', ' ...
    '''errorLogOnly'', ' logical2str(errorLogOnly) ', ' ...
    '''extensionAllowed'', ' logical2str(extensionsAllowed) ', ' ...
    '''hedXML'', ''' hedXML ''', ' ...
    '''outDir'', ''' outDir ''', '')']);
end % pop_tagstudy

function s = logical2str(b)
if b
    s = 'true';
else
    s = 'false';
end
end