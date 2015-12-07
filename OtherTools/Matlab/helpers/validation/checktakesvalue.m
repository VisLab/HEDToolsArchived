function [errors, errorTags, warnings, warningTags] = ...
    checktakesvalue(Maps, original, canonical)
errors = '';
errorTags = {};
warnings = '';
warningTags = {};
isNumericTags = Maps.isNumeric.values();
unitClassTags = Maps.unitClass.keys();
digitRegexp = '^(>|>=|<|<=)?\s*\d*\.?\d+\s*$';
checkTakesValueTags(original, canonical, false);

    function checkTakesValueTags(original, canonical, isGroup)
        % Checks the tags that take values
        for a = 1:length(original)
            if iscellstr(original{a})
                checkTakesValueTags(original{a}, canonical{a}, true);
                return;
            end
            [unitClassIndexes, numericalIndexes] = ...
                findIndexes(canonical{a});
            if any(unitClassIndexes)
                checkUnitClassTag(original, canonical, a, isGroup, ...
                    unitClassIndexes);
            elseif any(numericalIndexes)
                checkNumericalTag(original, canonical, a, isGroup);
            end
        end
    end % checkTags

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

    function checkNumericalTag(original, canonical, numericalIndex, ...
            isGroup)
        % Checks the numerical tag
        tagName = getTagName(canonical{numericalIndex});
        if isempty(regexpi(tagName, digitRegexp))
            generateErrors(original, numericalIndex, isGroup, 'isNumeric');
        end
    end % checkNumericalTag

    function checkUnitClassTag(original, canonical, unitIndex, isGroup, ...
            unitClassMatch)
        % Checks the unit class tag
        tagName = getTagName(canonical{unitIndex});
        unitClasses = Maps.unitClass(unitClassTags{unitClassMatch});
        unitClasses = strsplit(unitClasses, ',');
        unitClassDefault = Maps.default(lower(unitClasses{1}));
        unitClassUnits = Maps.unitClasses(lower(unitClasses{1}));
        for a = 2:length(unitClasses)
            unitClassUnits = [unitClassUnits, ',', ...
                Maps.unitClasses(lower(unitClasses{a}))]; %#ok<AGROW>
        end
        unitsRegexp = buildUnitsRegexp(unitClassUnits);
        if ~isempty(regexpi(tagName, digitRegexp))
            generateWarnings(original, unitIndex, isGroup, 'unitClass', ...
            unitClassDefault)
        end
        if isempty(regexpi(tagName, unitsRegexp))
            generateErrors(original, unitIndex, isGroup, 'unitClass', ...
                unitClassUnits);
        end
    end % checkUnitClassTags

    function generateErrors(original, valueIndex, isGroup, errorType, ...
            unitClassUnits)
        % Generates takes value and unit class tag errors
        tagString = original{valueIndex};
        if isGroup
            tagString = [original{valueIndex}, ' in group (' ,...
                tagList.stringifyElement(original),')'];
        end
        if strcmpi(errorType, 'unitClass')
            errors = [errors, generateerror('unitClass', '', tagString, ...
                '', unitClassUnits)];
        else
            errors = [errors, generateerror('isNumeric', '', tagString, ...
                '', '')];
        end
        errorTags{end+1} = original{valueIndex};
    end % generateErrors

    function generateWarnings(original, valueIndex, isGroup, errorType, ...
            unitClassDefault)
        % Generates takes value and unit class tag errors
        tagString = original{valueIndex};
        if isGroup
            tagString = [original{valueIndex}, ' in group (' ,...
                tagList.stringifyElement(original),')'];
        end
        if strcmpi(errorType, 'unitClass')
            warnings = [warnings, generatewarning('unitClass', '', ...
                tagString, unitClassDefault)];
        else
            warnings = [warnings, generatewarning('unitClass', '', ...
                tagString, unitClassDefault)];
        end
        warningTags{end+1} = original{valueIndex};
    end % generateErrors

    function valueTag = convertToValueTag(tag)
        % Strips the tag name and replaces it with #
        valueTag = strsplit(tag, '/');
        valueTag = valueTag(1:end-1);
        valueTag = [strjoin(valueTag,'/'), '/#'];
    end % convertToValueTag

    function [unitClassIndexes, numericalIndexes] = findIndexes(tag)
        % Finds the indexes for tags that take values
        valueTag = convertToValueTag(tag);
        unitClassIndexes = ~cellfun(@isempty, ...
            regexpi(unitClassTags, ['^',valueTag,'$']));
        numericalIndexes = ~cellfun(@isempty, ...
            regexpi(isNumericTags, ['^',valueTag,'$']));
    end % findIndexes

    function tagName = getTagName(tag)
        % Get the tag name from the full tag path
        valueTag = strsplit(tag, '/');
        tagName = valueTag{end};
    end % getTagName

end % checktakesvalue