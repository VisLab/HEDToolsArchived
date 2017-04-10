% This function takes in a cell array of HED tags associated with a
% particular study and validates them based on the tags and attributes in
% the HED XML file.
%
% Usage:
%
%   >>  issues = parseCellTags(hedMaps, extensionAllowed);
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
%   cell
%                   A cell array containing HED tags.
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

function issues = parsecell(hedMaps, cell, generateWarnings)
p = parseArguments(hedMaps, cell, generateWarnings);
issues = readCell(p);

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

    function p = parseArguments(hedMaps, cell, extensionAllowed)
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedMaps', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('cell', @(x) (~isempty(x) && iscell(x)));
        parser.addRequired('generateWarnings', @islogical);
        parser.parse(hedMaps, cell, extensionAllowed);
        p = parser.Results;
    end % parseArguments

    function issues = readCell(p)
        % Read the tags in a cell array and validates them
        try
            p.cellTags = hed2cell(p.cell, false);
            p.formattedCellTags = hed2cell(p.cell, true);
            issues = validateCellTags(p);
        catch
            warning(['Unable to parse tags in cell array. Please check' ...
                ' the format of it.']);
            issues = '';
        end
    end % readCell

    function issues = validateCellTags(p)
        % Validates the tags in a cell array
        if ~isempty(p.cellTags)
            issues = findErrors(p);
            if(p.generateWarnings)
                warnings = findWarnings(p);
                issues = [issues warnings];
            end  
        end
    end % validateCellTags

end % parseCellTags