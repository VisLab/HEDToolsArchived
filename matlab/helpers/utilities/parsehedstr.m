% This function takes in a string of HED tags associated with a
% particular study and validates them based on the tags and attributes in
% the HED XML file.
%
% Usage:
%
%   >>  issues = parsehedstr(hedMaps, str, generateWarnings);
%
% Input:
%
%   hedMaps
%                   A structure that contains Maps associated with the HED
%                   XML tags. There is a map that contains all of the HED
%                   tags, a map that contains all of the unit class units,
%                   a map that contains the tags that take in units, a map
%                   that contains the default unit used for each unit
%                   class, a map that contains the tags that take in
%                   values, a map that contains the tags that are numeric,
%                   a map that contains the required tags, a map that
%                   contains the tags that require children, a map that
%                   contains the tags that are extension allowed, and map
%                   that contains the tags are are unique.
%
%   str
%                   A string containing HED tags.
%
%   generateWarnings
%                   True to include warnings in the log file in addition
%                   to errors. If false (default) only errors are included
%                   in the log file.
%
% Output:
%
%       issues
%                   A cell array containing all of the issues found through
%                   the validation. Each cell corresponds to the issues
%                   found in a particular cell.
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

function issues = parsehedstr(hedMaps, str, generateWarnings)
p = parseArguments(hedMaps, str, generateWarnings);
issues = readStr(p);

    function errors = findErrors(p)
        % Errors will be generated for the cell if found
        errors = checkerrors(p.hedMaps, p.cellTags, ...
            p.formattedCellTags);
    end % findErrors

    function warnings = findWarnings(p)
        % Warnings will be generated for the cell if found
        warnings = checkwarnings(p.hedMaps, p.cellTags, ...
            p.formattedCellTags);
    end % findWarnings

    function p = parseArguments(hedMaps, str, extensionAllowed)
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedMaps', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('str', @ischar);
        parser.addRequired('generateWarnings', @islogical);
        parser.parse(hedMaps, str, extensionAllowed);
        p = parser.Results;
    end % parseArguments

    function issues = readStr(p)
        % Read the tags in a string and validates them
        try
            p.cellTags = hed2cell(p.str, false);
            p.formattedCellTags = hed2cell(p.str, true);
            issues = validateStrTags(p);
        catch
            warning(['Unable to parse string. Please check' ...
                ' the format of it.']);
            issues = '';
        end
    end % readStr

    function issues = validateStrTags(p)
        % Validates the tags in a cell array from a string
        issues = '';
        if ~isempty(p.cellTags)
            issues = findErrors(p);
            if(p.generateWarnings)
                warnings = findWarnings(p);
                issues = [issues warnings];
            end
        end
    end % validateStrTags

end % parseCellTags