function [errors, errorTags, warnings, warningTags] = ...
    checkTakeValueTags(hedMaps, originalTags, formattedTags)
errors = '';
errorTags = {};
warnings = '';
warningTags = {};
checkTakesValueTags(originalTags, formattedTags, false);

    function checkTakesValueTags(originalTags, formattedTags, isGroup)
        % Checks the tags that take values
        numTags = length(formattedTags);
        for a = 1:numTags
            if ~ischar(formattedTags{a})
                checkTakesValueTags(originalTags{a}, formattedTags{a}, ...
                    true);
                return;
            end
            [isUnitClass, unitClassTag] = isUnitClassTag(formattedTags{a});
            if isUnitClass
                checkUnitClassTag(originalTags, formattedTags, a, ...
                    isGroup, unitClassTag);
            elseif isNumericTag(formattedTags{a})
                checkNumericalTag(originalTags, formattedTags, a, isGroup);
            end
        end
    end % checkTags

    function isNumeric = isNumericTag(tag)
        % Returns true if the tag is a numeric tag
        valueTag = convertToValueTag(tag);
        isNumeric = hedMaps.isNumeric.isKey(lower(valueTag));
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

    function checkNumericalTag(originalTag, formattedTag, ...
            numericalIndex, isGroup)
        % Checks the numerical tag
        tagName = getTagName(formattedTag{numericalIndex});
        if ~all(ismember(tagName, '<>=.0123456789'))
            generateErrorMessages(originalTag, numericalIndex, isGroup, ...
                'isNumeric', '');
        end
    end % checkNumericalTag

    function checkUnitClassTag(originalTag, formattedTag, unitIndex, ...
            isGroup, unitClassTag)
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
            generateWarningMessages(originalTag, unitIndex, isGroup, ...
                'unitClass', unitClassDefault)
        end
        if isempty(regexpi(tagName, unitsRegexp))
            generateErrorMessages(originalTag, unitIndex, isGroup, ...
                'unitClass', unitClassUnits);
        end
    end % checkUnitClassTags

    function generateErrorMessages(originalTag, valueIndex, isGroup, ...
            errorType, unitClassUnits)
        % Generates takes value and unit class tag errors
        tagString = originalTag{valueIndex};
        if isGroup
            tagString = [originalTag{valueIndex}, ' in group (' ,...
                vTagList.stringifyElement(originalTag),')'];
        end
        errors = [errors, generateErrorMessage(errorType, '', ...
            tagString, '', unitClassUnits)];
        errorTags{end+1} = originalTag{valueIndex};
    end % generateErrorMessages

    function generateWarningMessages(originalTag, valueIndex, isGroup, ...
            warningType, unitClassDefault)
        % Generates takes value and unit class tag errors
        tagString = originalTag{valueIndex};
        if isGroup
            tagString = [originalTag{valueIndex}, ' in group (' ,...
                vTagList.stringifyElement(originalTag),')'];
        end
        warnings = [warnings, generateWarningMessage(warningType, ...
            '', tagString, unitClassDefault)];
        warningTags{end+1} = originalTag{valueIndex};
    end % generateErrorMessages

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
        unitClassTag = convertToValueTag(tag);
        isUnitClass = hedMaps.unitClass.isKey(lower(unitClassTag));
    end % isUnitClassTag

    function tagName = getTagName(tag)
        % Get the tag name from the full tag path
        valueTag = textscan(tag, '%s', 'delimiter', '/', ...
            'multipleDelimsAsOne', 1)';
        tagName = valueTag{1}{end};
    end % getTagName

end % checkTakeValueTags