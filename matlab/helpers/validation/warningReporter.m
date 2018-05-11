% This function generates the output for the HED tag validation warnings.
%
% Usage:
%
%   >>  warning = warningReporter(warningType, varargin);
%
% Input:
%
%   warningType
%         The type of warnings.
%
% Input (Optional):
%
%   defaultUnit
%         The default unit class unit associated with the warning.
%
%   tag
%         The tag that generated the error. The original tag not the
%         formatted one.
%
%   tagPrefix
%         The tag prefix that generated the error.
%

%
% Output:
%
%   warning
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

function warning = warningReporter(warningType, varargin)
p = parseArguments(warningType, varargin{:});

switch(warningType)
    case 'cap'
        warning = sprintf(['\tWARNING: First word not capitalized or' ...
            ' camel case - "%s"\n'], p.tag);
    case 'required'
        warning = sprintf(['\tWARNING: Tag with prefix "%s" is' ...
            ' required\n'], p.tagPrefix);
    case 'unitClass'
        warning = sprintf(['\tWARNING: No unit specified. Using "%s" as' ...
            ' the default - "%s"\n'], p.defaultUnit, p.tag);
end

    function p = parseArguments(warningType, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('warningType',  @(x) ~isempty(x) && ischar(x));
        p.addParamValue('defaultUnit', '', @(x)  ~isempty(x) && ischar(x));
        p.addParamValue('tag', '', @(x)  ~isempty(x) && ischar(x));
        p.addParamValue('tagPrefix', '', @(x)  ~isempty(x) && ischar(x));
        p.parse(warningType, varargin{:});
        p = p.Results;
    end % parseArguments

end % warningReporter