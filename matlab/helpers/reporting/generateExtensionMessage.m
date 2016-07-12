% This function generates the output for the HED tag validation extension
% warnings.
%
% Usage:
%   >>  extension = generateExtensionMessage(type, line, tag, prefix);
%
% Input:
%
%       type        The type of warning that is generated.
%
%       line        The line that the warning was generated on.
%
%       tag         The tag of tag group that generated the warning.
%
%       prefix      The tag prefix that is associated with the tag.
%
% Output:
%
%       extension   A string that consists of the extension warning that
%                   was generated.
%
% Examples:
%                   To generate a 'extension allowed' warning from tag
%                   'Experiment context/Outdoors/Terrain/Gravel' and
%                   prefix 'Experiment context/Outdoors/Terrain'.
%
%                   extension = generateextension('extensionAllowed', ...
%                   [], 'Experiment context/Outdoors/Terrain/Gravel', ...
%                   'Experiment context/Outdoors/Terrain');
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function extension = generateExtensionMessage(type, line, tag, prefix)
switch(type)
    case 'correct'
        extension = sprintf('No extensions allowed warnings were found.');
    case 'event'
        extension = sprintf('Warnings in event %s:\n', num2str(line));
    case 'extensionAllowed'
        extension = sprintf(['\t"%s" is not in the hierarchy but is a' ...
            ' descendant of "%s" which has the extensionAllowed' ...
            ' attribute\n'], tag, prefix);
    case 'line'
        extension = sprintf('Warnings on line %s:\n', num2str(line));
end % generateExtensionMessage