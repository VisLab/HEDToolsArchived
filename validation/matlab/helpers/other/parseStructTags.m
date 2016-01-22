% This function takes in a EEG dataset containing HED tags associated with
% a particular study and validates them based on the tags and attributes in
% the HED XML file.
%
% Usage:
%
%   >>  [errors, warnings, extensions] = parseStructTags(hedMaps, ...
%        events, tagField)
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
% Output:
%
%       errors
%                   A cell array containing all of the validation errors.
%                   Each cell is associated with the validation errors on a
%                   particular line.
%
%       warnings
%                   A cell array containing all of the validation warnings.
%                   Each cell is associated with the validation warnings on
%                   a particular line.
%
%       extensions
%                   A cell array containing all of the extension allowed
%                   validation warnings. Each cell is associated with the
%                   extension allowed validation warnings on a particular
%                   line.
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

function [errors, warnings, extensions] = parseStructTags(hedMaps, ...
    events, tagField, extensionAllowed)
p = parseArguments();
errors = {};
warnings = {};
extensions = {};
errorCount = 1;
warningCount = 1;
extensionCount = 1;
validateStructureTags();

    function checkForTSVLineErrors(originalTags, formattedTags, ...
            eventNumber)
        % Errors will be generated for the line if found
        lineErrors = checkForValidationErrors(p.hedMaps, originalTags, ...
            formattedTags, p.extensionAllowed);
        if ~isempty(lineErrors)
            lineErrors = [generateErrorMessage('event', eventNumber, ...
                '', '', ''), lineErrors];
            errors{errorCount} = lineErrors;
            errorCount = errorCount + 1;
        end
    end % checkForTSVLineErrors

    function checkForTSVLineExtensions(originalTags, formattedTags, ...
            eventNumber)
        % Errors will be generated for the line if found
        lineExtensions = checkForValidationExtensions(p.hedMaps, ...
            originalTags, formattedTags, p.extensionAllowed);
        if ~isempty(lineExtensions)
            lineExtensions = [generateExtensionMessage('event', ...
                eventNumber, '', ''), lineExtensions];
            extensions{extensionCount} = lineExtensions;
            extensionCount = extensionCount + 1;
        end
    end % checkForTSVLineExtensions

    function checkForTSVLineWarnings(originalTags, formattedTags, ...
            eventNumber)
        % Warnings will be generated for the line if found
        lineWarnings = checkForValidationWarnings(p.hedMaps, ...
            originalTags, formattedTags);
        if ~isempty(lineWarnings)
            lineWarnings = [generateWarningMessage('event', eventNumber, ...
                '', ''), lineWarnings];
            warnings{warningCount} = lineWarnings;
            warningCount = warningCount + 1;
        end
    end % checkForTSVLineWarnings

    function [originalTags, formattedTags] = formatStructureTags(tags)
        % Converts the tags from a str to a cellstr
        originalTags = formatTags(tags, false);
        formattedTags = formatTags(tags, true);
    end % formatStructureTags

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        parser = inputParser;
        parser.addRequired('hedMaps', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('events', @(x) (~isempty(x) && isstruct(x)));
        parser.addRequired('tagField', @(x) (~isempty(x) && ischar(x)));
         parser.addRequired('extensionAllowed', @islogical);
        parser.parse(hedMaps, events, tagField, extensionAllowed);
        p = parser.Results;
    end % parseArguments

    function validateStructureTags()
        % This function validates the tags in a EEG structure
        numberEvents = length(p.events);
        for a = 1:length(numberEvents)
            [originalTags, formattedTags] = ...
                formatStructureTags(p.events(a).(p.tagField));
            if ~isempty(originalTags)
                checkForTSVLineErrors(originalTags, formattedTags, a);
                checkForTSVLineWarnings(originalTags, formattedTags, a);
                checkForTSVLineExtensions(originalTags, formattedTags, a);
            end
        end
    end % validateStructureTags

end % parseStructTags