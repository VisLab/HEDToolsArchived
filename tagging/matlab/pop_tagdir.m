% pop_tagdir
% Allows a user to tag a directory of datasets using a GUI
%
% Usage:
%   >>  [fMap, fPaths, com] = pop_tagdir()
%
% [fMap, fPaths, com] = pop_tagdir() first brings up a GUI to allow the
% user to set parameters for the tagdir function, and then calls tagdir
% to consolidate the tags from all of the data files in the specified
% directories. Depending on the arguments, tagdir may bring up select
% menus to allow the user to choose which fields should be tagged. The
% tagdir function may also bring up the ctagger GUI to allow users to
% edit the tags. The pop_tagdir function returns a fieldMap object
% containing all of the tag information, a list of full file names of
% the datasets to be tagged, and a string with the actual arguments to
% the tagdir function for use in a script.
%
% Note: The primary purpose of pop_tagdir is to package up parameter input
% and calling of tagdir for use as a plugin for EEGLAB.
%
% See also:
%   eeglab, tageeg, tagdir, tagstudy, and eegplugin_ctagger
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

% $Log: pop_tagdir.m,v $
% Revision 1.0 21-Apr-2013 09:25:25  kay
% Initial version
%


function [fMap, fPaths, com] = pop_tagdir()
% Create the tagger for this EEG set
fMap = '';
fPaths = '';
com = '';
[inDir, baseMap, doSubDirs, EditXml, preservePrefix, ...
    rewriteOption, saveMapFile, selectOption, useGUI, cancelled] =  ...
    tagdir_input();
if cancelled
    return;
end
[fMap, fPaths] = tagdir(inDir, 'BaseMap', baseMap, ...
    'DoSubDirs', doSubDirs,  ...
    'EditXml', EditXml, ...
    'PreservePrefix', preservePrefix, ...
    'RewriteOption', rewriteOption, ...
    'SaveMapFile', saveMapFile, ...
    'SelectOption', selectOption, ...
    'UseGUI', useGUI);

com = char(['tagdir(''' inDir ''', ' ...
    '''BaseMap'', ''' baseMap ''', ' ...
    '''DoSubDirs'', ' logical2str(doSubDirs) ', ' ...
    '''EditXml'', ' logical2str(EditXml) ', ' ...
    '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
    '''RewriteOption'', ' logical2str(rewriteOption) ', ' ...
    '''SaveMapFile'', ''' saveMapFile ''', ' ...
    '''SelectOption'', ' logical2str(selectOption) ', ' ...
    '''UseGui'', ' logical2str(useGUI) ')']);
end % pop_tagdir

function s = logical2str(b)
if b
    s = 'true';
else
    s = 'false';
end
end
