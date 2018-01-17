% This function checks to see if the provided HED tags have the
% 'takesValue' attribute. Tags that have the 'takesValue' attribute can be
% numerical or non-numerical. Non-numerical tag can be a string consisting
% of any characters. A numerical tag has to be a number. Some numerical
% tags have unit associated with them such as seconds or degrees. Any tags
% not complying to these rules will generate a error.

% Usage:
%
%   >>  [errors, errorTags, warnings, warningTags] = ...
%       checkTakeValueTags(hedMaps, originalTags, formattedTags)
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
%   originalTags
%                   A cell array of HED tags. These tags are used to report
%                   the errors found.
%
%   formattedTags
%                   A cell array of HED tags. These tags are used to do the
%                   validation.
%
% Output:
%
%   errors
%                   A string containing the validation errors.
%
%   errorTags
%                   A cell array containing validation error tags.
%
%   warnings
%                   A string containing the validation warnings.
%
%   warningTags
%                   A cell array containing validation warning tags.
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

function [errors, errorTags, warnings, warningTags] = ...
    checktakevalue(hedMaps, originalTags, formattedTags)
errors = '';
errorTags = {};
warnings = '';
warningTags = {};
checkTakesValueTags(originalTags, formattedTags);

    function checkTakesValueTags(originalTags, formattedTags)
        % Checks the tags that take values
        numTags = length(formattedTags);
        for a = 1:numTags
            if ~ischar(formattedTags{a})
                checkTakesValueTags(originalTags{a}, formattedTags{a});
                return;
            end
            [isUnitClass, unitClassTag] = isUnitClassTag(formattedTags{a});
            if isUnitClass
                checkUnitClassTag(originalTags, formattedTags, a, ...
                    unitClassTag);
            elseif isNumericTag(formattedTags{a})
                checkNumericalTag(originalTags, formattedTags, a);
            end
        end
    end % checkTags

    function isNumeric = isNumericTag(tag)
        % Returns true if the tag is a numeric tag
        isNumeric = false;
        if ~hedMaps.tags.isKey(lower(tag))
            valueTag = convertToValueTag(tag);
            isNumeric = hedMaps.isNumeric.isKey(lower(valueTag));
        end
    end % isNumericTag

    function unitsRegexp = buildUnitsRegexp(units)
        % Builds a regexp for unit class units
        characterEscapes = {'.','\','+','*','?','[','^',']','$','(', ...
            ')','{','}','=','!','<','>','|',':','-'};
        splitUnits = strsplit(units, ',');
        operators = '^(>|>=|<|<=)?\s*';
        digits = '\d*\.?\d+\s*';
        unitsGroup = '(';
        for a = 1:length(splitUnits)
            if any(strcmpi(characterEscapes, strtrim(splitUnits{a})))
                unitsGroup = [unitsGroup, ['\', ...
                    strtrim(splitUnits{a})], '|']; %#ok<AGROW>
            else
                unitsGroup = [unitsGroup, strtrim(splitUnits{a}), ...
                    '|'];  %#ok<AGROW>
            end
        end
        unitsGroup = regexprep(unitsGroup, '\|$', '');
        unitsGroup = [unitsGroup,')?\s*'];
        unitsRegexp = [operators,unitsGroup,digits, unitsGroup, '$'];
    end % buildUnitsRegexp

    function checkNumericalTag(originalTag, formattedTag, numericalIndex)
        % Checks the numerical tag
        tagName = getTagName(formattedTag{numericalIndex});
        if ~all(ismember(tagName, '<>=.0123456789'))
            generateErrors(originalTag, numericalIndex, 'isNumeric', '');
        end
    end % checkNumericalTag

    function checkUnitClassTag(originalTag, formattedTag, unitIndex, ...
            unitClassTag)
        % Checks the unit class tag
        tagName = getTagName(formattedTag{unitIndex});
        unitClasses = hedMaps.unitClass(lower(unitClassTag));
        unitClasses = textscan(unitClasses, '%s', 'delimiter', ',', ...
            'multipleDelimsAsOne', 1)';
        unitClassDefault = hedMaps.default(lower(unitClasses{1}{1}));
        unitClassUnits = hedMaps.unitClasses(lower(unitClasses{1}{1}));
        numUnitClasses = size(unitClasses{1}, 1);
        for a = 2:numUnitClasses
            unitClassUnits = [unitClassUnits, ',', ...
                hedMaps.unitClasses(lower(unitClasses{1}{a}))]; %#ok<AGROW>
        end
        unitsRegexp = buildUnitsRegexp(unitClassUnits);
        if all(ismember(tagName, '<>=.0123456789'))
            generateWarnings(originalTag, unitIndex, 'unitClass', ...
                unitClassDefault)
        end
        if isempty(regexpi(tagName, unitsRegexp)) && ...
                ~isValidTimeString(tagName)
            generateErrors(originalTag, unitIndex, 'unitClass', ...
                unitClassUnits);
        end
    end % checkUnitClassTags

    function generateErrors(originalTag, valueIndex, errorType, ...
            unitClassUnits)
        % Generates takes value and unit class tag errors
        tagString = originalTag{valueIndex};
        errors = [errors, generateerror(errorType, '', tagString, '', ...
            unitClassUnits)];
        errorTags{end+1} = originalTag{valueIndex};
    end % generateErrors

    function validTimeString = isValidTimeString(timeString)
        % Returns true if the string is a valid time string. False, if
        % otherwise.
        timeExpression = '^([0-1]?[0-9]|2[0-3])(:[0-5][0-9])?$';
        if ~isempty(regexp(timeString, timeExpression, 'once'))
            validTimeString = true;
        else
            validTimeString = false;
        end
    end % isValidTimeString

    function generateWarnings(originalTag, valueIndex, warningType, ...
            unitClassUnits)
        % Generates takes value and unit class tag errors
        tagString = originalTag{valueIndex};
        warnings = [warnings, generatewarning(warningType, '', ...
            tagString, unitClassUnits)];
        warningTags{end+1} = originalTag{valueIndex};
    end % generateWarnings

    function valueTag = convertToValueTag(tag)
        % Strips the tag name and replaces it with #
        valueTag = tag;
        slashPositions = strfind(tag, '/');
        if ~isempty(slashPositions)
            valueTag = [tag(1:slashPositions(end)) '#'];
        end
    end % convertToValueTag

    function [isUnitClass, unitClassTag] = isUnitClassTag(tag)
        % Returns true if the tag requires a unit class
        isUnitClass = false;
        unitClassTag = '';
        if ~hedMaps.tags.isKey(lower(tag))
            unitClassTag = convertToValueTag(tag);
            isUnitClass = hedMaps.unitClass.isKey(lower(unitClassTag));
        end
    end % isUnitClassTag

    function tagName = getTagName(tag)
        % Get the tag name from the full tag path
        valueTag = textscan(tag, '%s', 'delimiter', '/', ...
            'multipleDelimsAsOne', 1)';
        tagName = valueTag{1}{end};
    end % getTagName

end % checktakevalue