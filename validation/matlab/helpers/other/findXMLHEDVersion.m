% This function takes in a HED XML file and looks for the version number
% contained the version attribute. If there is no version found then an
% empty string will be returned.
%
% Usage:
%
%   >>  version = findXMLHEDVersion(hedXML);
%
% Input:
%
%       hedXML
%                   The name or the path of the HED XML file containing
%                   all of the tags.
%
% Output:
%
%       version
%                   The version of the HED XML file. Will return an empty
%                   string if there is no version attribute in the 
%                   document.
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

function version = findXMLHEDVersion(hed)
version = '';
try
    xDoc = xmlread(hed);
    xRoot = xDoc.getDocumentElement;
    version =  strtrim(char(xRoot.getAttribute('version')));
catch
end
end % findHEDVersion