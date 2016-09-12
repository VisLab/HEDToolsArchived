% This function takes in a EEG event structure containing HED tags
% and validates them against a HED schema. The validatetsv function calls
% this function to parse the tab-separated file and generate any issues
% found through the validation. 
%
% Usage:
%
%   >>  [issues, replaceTags, success] = parseeeg(hedMaps, events, ...
%       tagField, generateWarnings)
%
% Input:
%
%       hedMaps
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
%       events
%                   The EEG event structure containing the HED tags
%                   associated with a particular study.
%
%       tagField
%                   The field in events structure that contains the HED
%                   tags. The default field containing the tags is
%                   .usertags.
%
%       generateWarnings
%                   True to include warnings in the log file in addition
%                   to errors. If false (default) only errors are included
%                   in the log file.
%
% Output:
%
%       issues
%                   A cell array containing all of the issues found through
%                   the validation. Each cell corresponds to the issues
%                   found on a particular line.
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

function [issues, replaceTags, success] = parseeeg(hedMaps, events, ...
    tagField, generateWarnings)
p = parseArguments(hedMaps, events, tagField, generateWarnings);
[issues, replaceTags, success] = readStructTags(p);

    function p = findErrors(p)
        % Finds errors in a given structure 
        [p.structErrors, structRemapTags] = ...
            checkForValidationErrors(p.hedMaps, p.cellTags, ...
            p.formattedCellTags);
        p.remapTags = union(p.remapTags, structRemapTags);
    end % findErrors

    function p = findWarnings(p)
        % Find warnings in a given structure
        p.structWarnings = checkForValidationWarnings(p.hedMaps, ...
            p.cellTags, p.formattedCellTags);
    end % findWarnings

    function [cellTags, formattedCellTags] = tags2cell(strTags)
        % Converts the tags from a str to a cellstr and formats them
        cellTags = formattags(strTags, false);
        formattedCellTags = formattags(strTags, true);
    end % tags2cell


    function p = parseArguments(hedMaps, events, tagField, ...
            generateWarnings)
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedMaps', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('events', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('tagField', @(x) (~isempty(x) && ischar(x)));
        parser.addRequired('generateWarnings', @islogical);
        parser.parse(hedMaps, events, tagField, generateWarnings);
        p = parser.Results;
    end % parseArguments

    function [issues, replaceTags, success] = readStructTags(p)
        % Extract the HED tags in a structure array and validate them
        p.issues = {};
        p.remapTags = {};
        p.issueCount = 1;
        numberEvents = length(p.events);
        for a = 1:numberEvents
            p.structNumber = a;
            [p.cellTags, p.formattedCellTags] = ...
                tags2cell(p.events(a).(p.tagField));
            p = validateStructTags(p);
        end
        issues = p.issues;
        replaceTags = p.remapTags;
        success = true;
    end % readStructTags

    function p = validateStructTags(p)
        % Validates the HED tags in a structure
        if ~isempty(p.cellTags)
            p = findErrors(p);
            p.structIssues = p.structErrors;
            if(p.generateWarnings)
                p = findWarnings(p);
                p.structIssues = [p.structErrors p.structWarnings];
            end
            if ~isempty(p.structIssues)
                p.issues{p.issueCount} = ...
                    [sprintf('Issues in event %d:\n', p.structNumber), ...
                    p.structIssues];
                p.issueCount = p.issueCount + 1;
            end
        end
    end % validateStructTags

end % parseeeg