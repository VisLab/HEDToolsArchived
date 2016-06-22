% This function generates the output for the HED tag validation errors.
%
% Usage:
%
%   >>  error = generateErrorMessage(type, line, tag, prefix, units);
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
%       units       The units that are associated with tag. Only unit
%                   class tags will have units.
% Output:
%
%       error       A string that consists of the error that was
%                   generated.
%
% Examples:
%                   To generate a 'required' error from tag '/Event/label'.
%
%                   error = generateErrorMessage('required', [], ...
%                   '/Event/label', [], [])
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

function error = generateErrorMessage(type, line, tag, prefix, units)
switch(type)
    case 'cell'
        error = sprintf('Errors in cell %s:\n', num2str(line));
    case 'comma'
        error = sprintf(['\t"%s" may contain a comma when no commas' ...
            ' are allowed in tags'], tag);
    case 'empty'
        error = sprintf('There are no tags present. Please add tags.\n');
    case 'event'
        error = sprintf('Errors in event %s:\n', num2str(line));
    case 'isNumeric'
        error = sprintf(['\t"%s" should have a number, and optionally' ...
            ' a unit as the leaf string\n'], tag);
    case 'line'
        error = sprintf('Errors on line %s:\n', num2str(line));
    case 'required'
        error = sprintf(['\tA tag with the prefix "%s" is required in' ...
            ' every event but was not found in this event\n'], ...
            tag);
    case 'requireChild'
        error = sprintf('\t"%s" should have a child string\n', tag);
    case 'valid'
        error = sprintf('\t"%s" is not a valid HED tag\n', tag);
    case 'tilde'
        error = sprintf('\tgroup "%s" can have at most 2 tildes\n', tag);
    case 'unique'
        error = sprintf(['\t"%s" is part of the unique tag set' , ...
            ' starting with "%s" and has appeared more than once in' , ...
            ' this tag group\n'], tag, prefix);
    case 'unitClass'
        error = sprintf(['\t"%s" should have one of "%s" as a unit,' ...
            ' or, no unit\n'], tag, units);
end % generateErrorMessage