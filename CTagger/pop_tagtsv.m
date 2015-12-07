% pop_tagtsv
% Allows a user to create a tagMap from a tab-delimited file
%
% Usage:
%   >>  [tsvTagMap, com] = pop_tagtsv()
%
% [tsvTagMap, com] = pop_tagtsv() brings up a GUI to enter parameters for
% tagtsv, and calls tagtsv to extracts the values from a tab-delimited
% file into a tagMap.
%
% Note: The primary purpose of pop_tagtsv is to package up parameter input
% and calling of tagtsv.
%
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

% $Log: pop_tageeg.m,v $
% Revision 1.0 21-Apr-2013 09:25:25  kay
% Initial version
%


function [tsvTagMap, com] = pop_tagtsv()
% Create the tagger for a single EEG file
com = '';
tsvTagMap = tagMap();

% Get the tagger input parameters
[filename, fieldname, eventColumn, tagColumns, cancelled] = tagtsv_input();
if cancelled
    return;
end

% Tag the EEG structure and return the command string
tsvTagMap = tagtsv(filename, fieldname, eventColumn, tagColumns);
tagColStr = num2str(tagColumns);
if length(tagColumns) > 1
    tagColStr = ['[' num2str(tagColumns) ']'];
end
com = char(['tagtsv(''' filename ''',' ...
    '''' fieldname ''',', ...
    num2str(eventColumn) ',',  ...
    tagColStr ');' ]);
end % pop_tageeg

function s = logical2str(b)
if b
    s = 'true';
else
    s = 'false';
end
end % logical2str