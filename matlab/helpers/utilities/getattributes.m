% This function returns the attributes associated with a specified HED tag.
% 
% Usage:
%
%   >> attributes = getattributes(tag)
%
% Inputs:
%
%   tag           A HED tag string. 
%
% Outputs:
%
%   attributes    A cell array containing the attributes associated with
%                 a specified HED tag. Each cell contains a single
%                 attribute represented as a key value pair string. If the
%                 tag passed in is not found in the HED then the cell array
%                 returned will be empty without any attributes. 
%
% Examples:
%
% Find the attributes associated with the HED tag 
% 'Sensory presentation/Auditory/Animal voice'. 
%
% attributes = getattributes('Sensory presentation/Auditory/Animal voice');
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

function attributes = getattributes(tag)
p = parseArguments(tag);
maps = load('HEDMaps.mat');
p.tag = lower(p.tag);
p.hedMaps = maps.hedMaps;
attributes = checkAttributes(p);

    function attributes = checkAttributes(p)
        attributes = {};
        if p.hedMaps.tags.isKey(p.tag)
            index = 1;
            attributes{index} = ['extensionAllowed = ' ...
                logical2str(p.hedMaps.extensionAllowed.isKey(p.tag))];
            index = index + 1;
            attributes{index} = ['isNumeric = ' ...
                logical2str(p.hedMaps.isNumeric.isKey(p.tag))];
            index = index + 1;
            attributes{index} = ['requireChild = ' ...
                logical2str(p.hedMaps.requireChild.isKey(p.tag))];
            index = index + 1;
            attributes{index} = ['required = ' ...
                logical2str(p.hedMaps.required.isKey(p.tag))];
            index = index + 1;
            attributes{index} = ['takesValue = ' ...
                logical2str(p.hedMaps.takesValue.isKey(p.tag))];
            index = index + 1;
            attributes{index} = ['unique = ' ...
                logical2str(p.hedMaps.unique.isKey(p.tag))];
        end
    end

    function str = logical2str(value)
        % Converts a logical value to a true or false string
        if value == 1
            str =  'true';
        else
            str =  'false';
        end
    end % logical2str

    function p = parseArguments(tag)
        % Parses the input arguments and returns the results
        parser = inputParser();
        parser.addRequired('tag', @ischar);
        parser.parse(tag);
        p = parser.Results;
    end % parseArguments

end % getattributes