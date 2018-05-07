function tests = TagValidatorTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
load('hedMaps.mat');
requiredTags = hedMaps.required.keys();
numericTags = hedMaps.isNumeric.keys();
unitClassTags = hedMaps.unitClass.keys();
tags = hedMaps.tags.keys();
extensionAllowedTags = hedMaps.extensionAllowed.keys();
testCase.TestData.tagValidator = TagValidator(hedMaps);
testCase.TestData.validCapsTag = 'This is/A/Valid tag';
testCase.TestData.invalidCapsTag = 'This Is/A/invalid tag';
testCase.TestData.validHedStringWithCommas = ...
    '/This/is/a/tag, /This/is/another/tag';
testCase.TestData.commaMissingBeforeOpeningParenthesis = ...
    '/This/is/a/tag (/This/is/another/tag';
testCase.TestData.commaMissingAfterClosingParenthesis = ...
    '(/This/is/a/tag) /This/is/another/tag';
testCase.TestData.validGroupWithEqualBrackets = ...
    '(/This/is/a/tag, /This/is/another/tag)';
testCase.TestData.validGroupWithUnequalBrackets = ...
    '(/This/is/a/tag, /This/is/another/tag';
testCase.TestData.validRequireChildTag = 'Event/Label/This is a label';
testCase.TestData.invalidRequireChildTag = 'Event/Label';
testCase.TestData.formattedTopLevelTagsWithOneRequiredTag = ...
    requiredTags(1);
testCase.TestData.formattedTopLevelTagsWithAllRequiredTags = ...
    cellfun(@(x) [x '/'], requiredTags, 'UniformOutput', false);
testCase.TestData.validNumericTag = strrep(numericTags{1}, '#', ...
    '1287128127');
testCase.TestData.invalidNumericTag = strrep(numericTags{1}, '#', ...
    'sdkljdskj');
testCase.TestData.validUnitClassTagWithNoUnits = ...
    strrep(unitClassTags{1}, '#', '1287128127');
validUnits = strsplit(testCase.TestData.tagValidator.getTagUnitClassUnits(...
    unitClassTags{1}), ',');
validUnit = validUnits{1};
testCase.TestData.validUnitClassTagWithUnits = ...
    strrep(unitClassTags{1}, '#', ['1287128127 ' validUnit]);
testCase.TestData.unitClassWithInvalidUnits = ...
    strrep(unitClassTags{1}, '#', '12871 ThisIsNotAValidUnit');
testCase.TestData.groupWithLessThanTwoTildes = ...
    {'a', '~', 'b', '~', 'c'};
testCase.TestData.groupWithLessThanMoreThanTwoTildes = ...
    {'a', '~', 'b', '~', 'c', '~', 'd'};
testCase.TestData.tagsWithOneUniquePrefix = ...
    {'event/label/a', '~', 'b', '~', 'c'};
testCase.TestData.tagsWithMultipleUniquePrefix = ...
    {'event/label/a', '~', 'b', '~', 'event/label/c', '~', 'd'};
testCase.TestData.validTag = tags{1};
testCase.TestData.invalidTag = [tags{1} '/sdkfjdksfj'];
testCase.TestData.validExtensionAllowedTag = ...
    [extensionAllowedTags{1} '/sdkfjdksfj'];
testCase.TestData.noDuplicateTags = {'a','b','c','d'};
testCase.TestData.duplicateTags = {'a','b','c','d', 'a'};
end % setupOnce


%% Test Functions
function checkPathNameCapsTest(testCase)
warnings = testCase.TestData.tagValidator.checkPathNameCaps(...
    testCase.TestData.validCapsTag);
testCase.verifyEmpty(warnings);
warnings = testCase.TestData.tagValidator.checkPathNameCaps(...
    testCase.TestData.invalidCapsTag);
testCase.verifyNotEmpty(warnings);
end % checkCapsTest

function checkForMissingCommasTest(testCase)
errors = testCase.TestData.tagValidator.checkForMissingCommas(...
    testCase.TestData.validHedStringWithCommas);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkForMissingCommas(...
    testCase.TestData.commaMissingBeforeOpeningParenthesis);
testCase.verifyNotEmpty(errors);
errors = testCase.TestData.tagValidator.checkForMissingCommas(...
    testCase.TestData.commaMissingAfterClosingParenthesis);
testCase.verifyNotEmpty(errors);
end

function checkNumberOfGroupBracketsTest(testCase)
errors = testCase.TestData.tagValidator.checkNumberOfGroupBrackets(...
    testCase.TestData.validGroupWithEqualBrackets);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkNumberOfGroupBrackets(...
    testCase.TestData.validGroupWithUnequalBrackets);
testCase.verifyNotEmpty(errors);
end

function checkIfTagRequiresAChildTest(testCase)
errors = testCase.TestData.tagValidator.checkIfTagRequiresAChild(...
    testCase.TestData.validRequireChildTag, ...
    testCase.TestData.validRequireChildTag);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkIfTagRequiresAChild(...
    testCase.TestData.invalidRequireChildTag, ...
    testCase.TestData.invalidRequireChildTag);
testCase.verifyNotEmpty(errors);
end

function checkIfRequiredTagsPresentTest(testCase)
errors = testCase.TestData.tagValidator.checkIfRequiredTagsPresent(...
    testCase.TestData.formattedTopLevelTagsWithAllRequiredTags);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkIfRequiredTagsPresent(...
    testCase.TestData.formattedTopLevelTagsWithOneRequiredTag);
testCase.verifyNotEmpty(errors);
end

function checkIfValidNumericalTagTest(testCase)
errors = testCase.TestData.tagValidator.checkIfValidNumericalTag(...
    testCase.TestData.validNumericTag, testCase.TestData.validNumericTag);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkIfValidNumericalTag(...
    testCase.TestData.invalidNumericTag, ...
    testCase.TestData.invalidNumericTag);
testCase.verifyNotEmpty(errors);
end

function checkUnitClassTagForWarningsTest(testCase)
warnings = testCase.TestData.tagValidator.checkUnitClassTagForWarnings(...
    testCase.TestData.validUnitClassTagWithUnits, ...
    testCase.TestData.validUnitClassTagWithUnits);
testCase.verifyEmpty(warnings);
warnings = testCase.TestData.tagValidator.checkUnitClassTagForWarnings(...
    testCase.TestData.validUnitClassTagWithNoUnits, ...
    testCase.TestData.validUnitClassTagWithNoUnits);
testCase.verifyNotEmpty(warnings);
end

function checkUnitClassTagForErrorsTest(testCase)
errors = testCase.TestData.tagValidator.checkUnitClassTagForErrors(...
    testCase.TestData.validUnitClassTagWithUnits, ...
    testCase.TestData.validUnitClassTagWithUnits);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkUnitClassTagForErrors(...
    testCase.TestData.unitClassWithInvalidUnits, ...
    testCase.TestData.unitClassWithInvalidUnits);
testCase.verifyNotEmpty(errors);
end

function checkNumberOfGroupTildesTest(testCase)
errors = testCase.TestData.tagValidator.checkNumberOfGroupTildes(...
    testCase.TestData.groupWithLessThanTwoTildes);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkNumberOfGroupTildes(...
    testCase.TestData.groupWithLessThanMoreThanTwoTildes);
testCase.verifyNotEmpty(errors);
end

function checkForMultipleUniquePrefixesTest(testCase)
errors = testCase.TestData.tagValidator.checkForMultipleUniquePrefixes(...
    testCase.TestData.tagsWithOneUniquePrefix);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkForMultipleUniquePrefixes(...
    testCase.TestData.tagsWithMultipleUniquePrefix);
testCase.verifyNotEmpty(errors);
end

function checkIfTagIsValidTest(testCase)
errors = testCase.TestData.tagValidator.checkIfTagIsValid(...
    testCase.TestData.validTag, testCase.TestData.validTag);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkIfTagIsValid(...
    testCase.TestData.validExtensionAllowedTag, ...
    testCase.TestData.validExtensionAllowedTag);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkIfTagIsValid(...
    testCase.TestData.invalidTag, testCase.TestData.invalidTag);
testCase.verifyNotEmpty(errors);
end

function checkForDuplicateTagsTest(testCase)
errors = testCase.TestData.tagValidator.checkForDuplicateTags(...
    testCase.TestData.noDuplicateTags, testCase.TestData.noDuplicateTags);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkForDuplicateTags(...
    testCase.TestData.duplicateTags, testCase.TestData.duplicateTags);
testCase.verifyNotEmpty(errors);
end

