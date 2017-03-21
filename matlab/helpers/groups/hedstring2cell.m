% Converts a HED string, composed of any number of nested paranthesis
% and tildes, to a cell array with nested (string) tags, or
% struct('subject', 'verb', 'object') structures.
%
% Usage:
%
%   >>  [hedCell, idToPartMap] = hedstring2cell(hedString)
%
%   >>  [hedCell, idToPartMap] = hedstring2cell(hedString, varargin)
%
%
% Input:
%
%   hedString
%                   A string containing HED tags that are validated.
%
%
%   Optional:
%
%   'groupFormat'
%                   The options are 'cell' or 'struct'. The 'cell' option
%                   converts a group tag string into a cell array. The
%                   'struct' option converts a group tag string into
%                   stucture array. The structure array has three fields
%                   representing 'subject', 'verb', and 'object'
%
%   'idToPartMap'
%                   A map container containing parts of the tag string.
%
%   'keepTildes'
%                   If the 'cell' format option is selected and
%                   'keepTildes' is true, then the tildes are kept inside
%                   the cell array. If false, the tildes are removed.
%
% Output:
%
%   hedCell
%                   A structure array containing the tags in the tag
%                   string.
%
%   idToPartMap
%                   A map container containing parts of the tag string.
%
% Copyright (C) 2015 Nima Bigdely-Shamlo nima.bigdely@qusp.io,
% Jeremy Cockfield, UTSA jeremy.cockfield@gmail.com, and
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

function [hedCell, idToPartMap] = hedstring2cell(hedString, varargin)


p = parseArguments(hedString, varargin{:});
idToPartMap = p.idToPartMap;

[paranthesisGroup,  paranthesisDepth] = processparanthesis(hedString);

newHEDSting = hedString;
for i=1:max(paranthesisGroup)
    parathesisString = hedString(paranthesisGroup == i);
    newId = ['@id_' getuuid];
    idToPartMap(newId) = ...
        hedstring2cell(parathesisString(2:(end-1)), ...
        'idToPartMap', idToPartMap, 'groupFormat', p.groupFormat, ...
        'keepTildes', p.keepTildes); % excluce the paranthesis when mapping to id
    newHEDSting = strrep(newHEDSting, parathesisString, newId);
end;

hedCell = processtildes(newHEDSting, p.groupFormat, p.keepTildes);

if ischar(hedCell)
    hedCell = strtrim(strsplit(hedCell, ','));
    
    if length(hedCell) == 1 % no commas so no need to place inside a cell
        hedCell = hedCell{1};
    end;
end;

% replace ids with parts
hedCell = hedreplaceidswithpart(hedCell, idToPartMap);

    function p = parseArguments(hedString, varargin)
        % Parses arguments
        parser = inputParser;
        parser.addRequired('hedString', @(x) ~isempty(x) && ischar(x));
        parser.addParamValue('groupFormat', 'cell', @(x) ...
            any(strcmpi({'cell', 'struct'}, x)));
        parser.addParamValue('idToPartMap', containers.Map, @(x) ...
            isa(x, 'containers.Map'));
        parser.addParamValue('keepTildes', false, @islogical);
        parser.parse(hedString, varargin{:});
        p = parser.Results;
    end % parseArguments

end % hedstring2cell