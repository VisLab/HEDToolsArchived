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

function [errors, warnings, extensions, uniqueErrorTags] = ...
    parseStructTags(hedMaps, events, tagField, extensionAllowed)
p = parseArguments();
errors = {};
warnings = {};
extensions = {};
uniqueErrorTags = {};
errorCount = 1;
warningCount = 1;
extensionCount = 1;
validateStructureTags();

    function checkForEventErrors(originalTags, formattedTags, ...
            eventNumber)
        % Errors will be generated for the line if found
        [eventErrors, eventErrorTags] = ...
            checkForValidationErrors(p.hedMaps, originalTags, ...
            formattedTags, p.extensionAllowed);
        if ~isempty(eventErrors)
            eventErrors = [generateErrorMessage('event', eventNumber, ...
                '', '', ''), eventErrors];
            errors{errorCount} = eventErrors;
            if ~isempty(eventErrorTags)
                uniqueErrorTags = union(uniqueErrorTags, lineErrorTags);
            end
            errorCount = errorCount + 1;
        end
    end % checkForEventErrors

    function checkForEventExtensions(originalTags, formattedTags, ...
            eventNumber)
        % Errors will be generated for the line if found
        eventExtensions = checkForValidationExtensions(p.hedMaps, ...
            originalTags, formattedTags, p.extensionAllowed);
        if ~isempty(eventExtensions)
            eventExtensions = [generateExtensionMessage('event', ...
                eventNumber, '', ''), eventExtensions];
            extensions{extensionCount} = eventExtensions;
            extensionCount = extensionCount + 1;
        end
    end % checkForEventExtensions

    function checkForEventWarnings(originalTags, formattedTags, ...
            eventNumber)
        % Warnings will be generated for the line if found
        eventWarnings = checkForValidationWarnings(p.hedMaps, ...
            originalTags, formattedTags);
        if ~isempty(eventWarnings)
            eventWarnings = [generateWarningMessage('event', ...
                eventNumber, '', ''), eventWarnings];
            warnings{warningCount} = eventWarnings;
            warningCount = warningCount + 1;
        end
    end % checkForEventWarnings

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
        for a = 1:numberEvents
            [originalTags, formattedTags] = ...
                formatStructureTags(p.events(a).(p.tagField));
            if ~isempty(originalTags)
                checkForEventErrors(originalTags, formattedTags, a);
                checkForEventWarnings(originalTags, formattedTags, a);
                checkForEventExtensions(originalTags, formattedTags, a);
            end
        end
    end % validateStructureTags

end % parseStructTags