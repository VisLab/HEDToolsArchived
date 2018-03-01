% This function generates the output for the HED tag validation errors.
%
% Usage:
%
%   >>  error = errorReporter(errorType, varargin);
%
% Input:
%
%   errorType
%         The type of warning error.
%
% Input (Optional):
%
%   errorRow
%         The row number that the error occurred on.
%
%   errorColumn
%         The column number that the error occurred on.
%
%   tag
%         The tag that generated the error. The original tag not the
%         formatted one.
%
%   tagPrefix
%         The tag prefix that generated the error.
%
%   unitClassUnits
%         The unit class units that are associated with the error.
%
%   openingBracketCount
%         The number of opening brackets.
%
%   closingBracketCount
%         The number of closing brackets.
%
% Output:
%
%   error
%         A string that consists of the error that was generated.
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

function error = errorReporter(errorType, varargin)
p = parseArguments(errorType, varargin{:});
switch(errorType)
    case 'bracket'
        error = sprintf(['\tERRORNumber of opening and closing' ...
            ' brackets are unequal. %s opening brackets. %s ' ...
            'closing brackets\n'], num2str(p.openingBracketCount), ...
            num2str(p.closingBracketCount));
    case 'comma'
        error = sprintf('\tERRORComma missing after - "%s"\n', p.tag);
    case 'duplicate'
        error = sprintf('\tERRORDuplicate tag - "%s"\n', p.tag);
    case 'isNumeric'
        error = sprintf('\tERRORInvalid numeric tag - "%s"\n', p.tag);
    case 'row'
        error = sprintf('Issues in row %s:\n', num2str(p.errorRow));
    case 'column'
        error = sprintf('Issues in row %s column %s:\n', ...
            num2str(p.errorRow), num2str(p.errorColumn));
    case 'requireChild'
        error = sprintf('\tERRORDescendant tag required - "%s"\n', ...
            p.tag);
    case 'tilde'
        error = sprintf('\tERRORToo many tildes - group "%s"\n', ...
            p.tag);
    case 'unique'
        error = sprintf(['\tERRORMultiple unique tags with prefix' ...
            ' - "%s"\n'], p.tagPrefix);
    case 'unitClass'
        error = sprintf(['\tERRORInvalid unit - "%s" valid units are' ...
            ' "%s"\n'], p.tag, p.unitClassUnits);
    case 'valid'
        error = sprintf('\tERRORInvalid HED tag - "%s"\n', p.tag);
end

    function p = parseArguments(errorType, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('errorType',  @(x) ~isempty(x) && ischar(x));
        p.addParamValue('errorRow', 1, @(x) ~isempty(x) && isdouble(x));
        p.addParamValue('error_column', 1, @(x) ~isempty(x) && isdouble(x));
        p.addParamValue('tag', '', @(x)  ~isempty(x) && ...
            ischar(x));
        p.addParamValue('tagPrefix', '', @(x)  ~isempty(x) && ...
            ischar(x));
        p.addParamValue('unitClassUnits', '', @(x)  ~isempty(x) && ...
            ischar(x));
        p.addParamValue('openingBracketCount', 1, @(x) ~isempty(x) && ...
            isdouble(x));
        p.addParamValue('closingBracketCount', 1, @(x) ~isempty(x) && ...
            isdouble(x));
        p.parse(errorType, varargin{:});
        p = p.Results;
    end % parseArguments

end % errorReporter