% This function takes in a string containing HED tags
% associated with a particular study and validates them based on the
% tags and attributes in the HED XML file.
%
% Usage:
%
%   >>  issues = validatehedstr(hedString);
%
%   >>  issues = validatehedstr(hedString, varargin);
%
% Input:
%
%   hedString
%                   A string containing HED tags that are validated.
%
%
%   Optional:
%
%   'generateWarnings'
%                   True to include warnings in the issues output variable 
%                   in addition to errors. If false (default) only errors
%                   are included in the issues output variable.
%
%   'hedXML'
%                   The name or the path of the XML file containing
%                   all of the HED tags and their attributes.
%
% Output:
%
%   issues
%                   A string containing all of the issues found through
%                   the validation.
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

function issues = validatehedstr(hedString, varargin)
p = parseArguments(hedString, varargin{:});
issues = validateHedTags(hedString, varargin{:});

    function p = parseArguments(str, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('hedString', @ischar);
        p.addParamValue('generateWarnings', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        p.addParamValue('hedXML', 'HED.xml', ...
            @(x) (~isempty(x) && ischar(x)));
        p.parse(str, varargin{:});
        p = p.Results;
    end % parseArguments

end % validatehedstr