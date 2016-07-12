% This function generates the output for the HED tag validation warnings.
%
% Usage:
%   >>  warning = generateWarningMessage(type, line, tag, units);
%
% Input:
%
%       type        The type of warning that is generated.
%
%       line        The line that the warning was generated on.
%
%       tag         The tag of tag group that generated the warning.
%
%       units       The units that are associated with tag. Only unit
%                   class tags will have units.
% Output:
%
%       warning     A string that consists of the warning that was
%                   generated.
%
% Examples:
%                   To generate a 'cap' warning on from tag '/Event/label'.
%
%                   warning = generateWarningMessage('cap', [], ...
%                   '/Event/label', []);
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

function warning = generateWarningMessage(type, line, tag, units)
warning = '';
switch(type)
    case 'cap'
        warning = sprintf(['\tEach slash-separated string in "%s"' ...
            ' should only have the first letter captilized or be camel' ...
            ' case\n'], tag);
    case 'correct'
        warning = sprintf('No warnings were found.');
    case 'event'
        warning = sprintf('Warnings in event %s:\n', num2str(line));
    case 'line'
        warning = sprintf('Warnings on line %s:\n', num2str(line));
    case 'slash'
        warning = sprintf('\t"%s" should not end with a slash\n', tag);
    case 'unitClass'
        warning = sprintf(['\t No units were specified for "%s" so the' ...
            ' unit %s is being used by default\n'], tag, units);
end % generateWarningMessage