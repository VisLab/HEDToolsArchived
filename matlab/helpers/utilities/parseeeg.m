% This function takes in a EEG event structure containing HED tags
% and validates them against a HED schema. The validatetsv function calls
% this function to parse the tab-separated file and generate any issues
% found through the validation.
%
% Usage:
%
%   >>  [issues, replaceTags, success] = parseeeg(hedXml, events, ...
%        generateWarnings)
%
% Input:
%
%       hedXml
%                   The full path to a HED XML file containing all of the
%                   tags. This by default will be the HED.xml file
%                   found in the hed directory.
%
%       events
%                   The EEG event structure containing the HED tags
%                   associated with a particular study.
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

function issues = parseeeg(hedXml, events, generateWarnings)
p = parseArguments(hedXml, events, generateWarnings);
issues = readStructTags(p);

    function p = parseArguments(hedXml, events, generateWarnings)
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedXml', @(x) (~isempty(x) && ischar(x)));
        parser.addRequired('events', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('generateWarnings', @islogical);
        parser.parse(hedXml, events, generateWarnings);
        p = parser.Results;
    end % parseArguments

    function issues = readStructTags(p)
        % Extract the HED tags in a structure array and validate them
        p.issues = {};
        p.replaceTags = {};
        p.issueCount = 1;
        numberEvents = length(p.events);
        try
            for a = 1:numberEvents
                p.structNumber = a;
                p.hedString = concattags(p.events(a));
                if ~isempty(p.hedString)
                    p = validateStructTags(p);
                end
            end
            issues = p.issues;
        catch
            throw(MException('parseeeg:cannotRead', ...
                'Unable to read event %d', a));
        end
    end % readStructTags

    function p = validateStructTags(p)
        % Validates the HED tags in a structure
        p.structIssues = validateHedTags(p.hedString, ...
            'hedXml', p.hedXml, 'generateWarnings', p.generateWarnings);
        if ~isempty(p.structIssues)
            p.issues{p.issueCount} = ...
                [sprintf('Issues in event %d:\n', p.structNumber), ...
                p.structIssues];
            p.issueCount = p.issueCount + 1;
        end
    end % validateStructTags

end % parseeeg