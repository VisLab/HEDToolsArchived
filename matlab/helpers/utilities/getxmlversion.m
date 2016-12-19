% This function takes in a XML text file containing all of the HED tags,
% their attributes, and unit classes and looks for the version number.
%
% Usage:
%
%   >>  version = getxmlversion(hedXML);
%
% Input:
%
%   hedXML
%                   The name or the path of the HED XML file containing
%                   all of the tags.
%
% Output:
%
%   version
%                   The version of the HED XML file. Will return an empty
%                   string if there is no version number in the file.
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

function version = getxmlversion(hed)
version = '';
try
    xDoc = xmlread(hed);
    xRoot = xDoc.getDocumentElement;
    version =  strtrim(char(xRoot.getAttribute('version')));
catch
    hedMaps = loadHEDMap();
    mapVersion = hedMaps.version;
    warning(['No version number was found in the HED file ... using' ...
        ' default version %s'], mapVersion);
end

    function hedMaps = loadHEDMap()
        % Loads a structure that contains Maps associated with the HED XML
        % tags
        Maps = load('hedMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHEDMap

end % getxmlversion