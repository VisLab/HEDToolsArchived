% This function generates the output for the HED tag validation errors.
%
% Usage:
%
%   >>  error = generateerror(type, line, tag, prefix, units);
%
% Input:
%
%   type            The type of error that is generated.
%
%   line            The line that the error was generated on.
%
%   tag             The tag or tag group that generated the error.
%
%   prefix          The tag prefix that is associated with the tag.
%
%   units           The units that are associated with tag. Only unit
%                   class tags will have units.
% Output:
%
%   error           A string that consists of the error that was
%                   generated.
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

function error = generateerror(type, line, tag, prefix, units)
switch(type)
    case 'bracket'
        error = sprintf(['\tERROR: Number of opening and closing' ...
            ' brackets are unequal. "%s" opening brackets. "%s" ' ...
            'closing brackets\n'], num2str(line), num2str(tag));
    case 'comma'
        error = sprintf('\tERROR: Comma missing after - \"%s\"\n', tag);
    case 'cell'
        error = sprintf('Errors in cell %s:\n', num2str(line));
    case 'correct'
        error = sprintf('No errors were found.');
    case 'empty'
        error = sprintf('There are no tags present. Please add tags.\n');
    case 'event'
        error = sprintf('Errors in event %s:\n', num2str(line));
    case 'isNumeric'
        error = sprintf('\tERROR: Invalid numeric tag - "%s"\n', tag);
    case 'line'
        error = sprintf('Errors on line %s:\n', num2str(line));
    case 'required'
        error = sprintf('\tERROR: Tag with prefix "%s" is required\n', tag);
    case 'requireChild'
        error = sprintf('\tERROR: Descendant tag required - "%s"\n', tag);
    case 'valid'
        error = sprintf('\tERROR: Invalid HED tag - "%s"\n', tag);
    case 'tilde'
        error = sprintf('\tERROR: Too many tildes - group "%s"\n', tag);
    case 'unique'
        error = sprintf('\tERROR: Multiple unique tags (prefix "%s") - "%s"\n', prefix, tag);
    case 'unitClass'
        error = sprintf('\tERROR: Invalid unit - "%s" (valid units are "%s")\n', ...
            tag, units);
end % generateerror