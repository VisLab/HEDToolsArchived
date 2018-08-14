% This function loads A structure that contains Maps associated with the
% HED XML.
%
% Usage:
%
%   >>  hedMaps = getHedMaps()
%
%   >>  hedMaps = getHedMaps(hedXml)
%
% Input:
%
%   Required:
%
%   hedXml
%                   The path to a HED XML file.
%
% Output:
%
%   hedMaps
%                   A structure that contains Maps associated with the HED
%                   XML.
%
% Copyright (C) 2017
% Jeremy Cockfield jeremy.cockfield@gmail.com
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

function hedMaps = getHedMaps(varargin)
% Gets a structure that contains Maps associated with the HED XML
% tags
inputArgs = parseInputArguments(varargin{:});
hedMaps = loadHedMaps();
mapVersion = hedMaps.version;
if hedXmlFileExist(inputArgs.hedXml) 
    xmlVersion = getxmlversion(inputArgs.hedXml);
    if ~isempty(xmlVersion) && ~strcmp(mapVersion, xmlVersion)
        hedMaps = mapattributes(p.HedXml);
    end
end

    function fileExist = hedXmlFileExist(hedXml)
        % Returns true if the HED XML file exists. False, if otherwise.
        fileExist = ~isempty(hedXml) && exist(hedXml, 'file') == 2;
    end % hedXmlFileExist

    function hedMaps = loadHedMaps()
        % Loads a structure that contains Maps associated with the HED XML
        % tags
        Maps = load('HEDMaps.mat');
        hedMaps = Maps.hedMaps;
    end % loadHEDMap

    function inputArgs = parseInputArguments(varargin)
        % Parses the input arguments and returns them in a structure
        parser = inputParser();
        parser.addOptional('hedXml',  '', @ischar);
        parser.parse(varargin{:});
        inputArgs = parser.Results;
    end % parseInputArguments

end % getHEDMaps