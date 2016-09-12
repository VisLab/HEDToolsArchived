% This function takes in a cell array of HED tags associated with a
% particular study and validates them based on the tags and attributes in
% the HED XML file.
%
% Usage:
%
%   >>  [errors, warnings, extensions] = parseCellTags(hedMaps, ...
%       extensionAllowed);
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
%       replaceTags
%                   A cell array containing all of the tags that generated
%                   issues. These tags will be written to a replace file.
%
%       success
%                   True if the validation finishes without throwing any
%                   exceptions, false if otherwise.
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

function [issues, replaceTags, success] = parsecell(hedMaps, cell, ...
    generateWarnings)
p = parseArguments(hedMaps, cell, generateWarnings);
[issues, replaceTags, success] = readCell(p);

    function p = findErrors(p)
        % Errors will be generated for the cell if found
        [p.cellErrors, cellReplaceTags] = ...
            checkForValidationErrors(p.hedMaps, p.cellTags, ...
            p.formattedCellTags);
        p.replaceTags = union(p.replaceTags, cellReplaceTags);
    end % findErrors

    function p = findWarnings(p)
        % Warnings will be generated for the cell if found
        p.cellWarnings = checkForValidationWarnings(p.hedMaps, ...
            p.cellTags, p.formattedCellTags);
    end % findWarnings

    function [cellTags, formattedCellTags] = tags2cell(strTags)
        % Converts the tags from a str to a cellstr and formats them
        cellTags = formattags(strTags, false);
        formattedCellTags = formattags(strTags, true);
    end % tags2cell

    function p = parseArguments(hedMaps, cell, extensionAllowed)
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedMaps', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('cell', @(x) (~isempty(x) && iscellstr(x)));
        parser.addRequired('generateWarnings', @islogical);
        parser.parse(hedMaps, cell, extensionAllowed);
        p = parser.Results;
    end % parseArguments

    function [issues, replaceTags, success] = readCell(p)
        % Read the tags in a cell array and validates them
        p.issues = {};
        p.replaceTags = {};
        p.issueCount = 1;
        numCells = length(p.cell);
        try
            for a = 1:numCells
                [p.cellTags, p.formattedCellTags] = tags2cell(p.cell{a});
                p.cellNumber = a;
                p = validateCellTags(p);
            end
            issues = p.issues;
            replaceTags = p.replaceTags;
            success = true;
        catch ME
            warning(['Unable to parse tags in cell %d. Please check' ...
                ' tags'], a);
            issues = '';
            replaceTags = {};
            success = false;
        end
    end % readCell

    function p = validateCellTags(p)
        % Validates the tags in a cell array
        if ~isempty(p.cellTags)
            p = findErrors(p);
            p.cellIssues = p.cellErrors;
            if(p.generateWarnings)
                p = findWarnings(p);
                p.cellIssues = [p.cellErrors p.cellWarnings];
            end
            if ~isempty(p.cellIssues)
                p.issues{p.issueCount} = sprintf(['\n' p.cellIssues]);
                p.issueCount = p.issueCount + 1;
            end
        end
    end % validateCellTags

end % parseCellTags