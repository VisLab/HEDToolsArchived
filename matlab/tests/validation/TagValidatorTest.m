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
end % checkPathNameCapsTest

function checkForMissingCommasTest(testCase)
issues = testCase.TestData.tagValidator.checkForMissingCommas(...
    testCase.TestData.validHedStringWithCommas);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkForMissingCommas(...
    testCase.TestData.commaMissingBeforeOpeningParenthesis);
testCase.verifyNotEmpty(issues);
issues = testCase.TestData.tagValidator.checkForMissingCommas(...
    testCase.TestData.commaMissingAfterClosingParenthesis);
testCase.verifyNotEmpty(issues);
end % checkForMissingCommasTest

function checkNumberOfGroupBracketsTest(testCase)
issues = testCase.TestData.tagValidator.checkNumberOfGroupBrackets(...
    testCase.TestData.validGroupWithEqualBrackets);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkNumberOfGroupBrackets(...
    testCase.TestData.validGroupWithUnequalBrackets);
testCase.verifyNotEmpty(issues);
end % checkNumberOfGroupBracketsTest

function checkIfTagRequiresAChildTest(testCase)
issues = testCase.TestData.tagValidator.checkIfTagRequiresAChild(...
    testCase.TestData.validRequireChildTag, ...
    testCase.TestData.validRequireChildTag);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkIfTagRequiresAChild(...
    testCase.TestData.invalidRequireChildTag, ...
    testCase.TestData.invalidRequireChildTag);
testCase.verifyNotEmpty(issues);
end % checkIfTagRequiresAChildTest

function checkIfRequiredTagsPresentTest(testCase)
issues = testCase.TestData.tagValidator.checkIfRequiredTagsPresent(...
    testCase.TestData.formattedTopLevelTagsWithAllRequiredTags, false);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkIfRequiredTagsPresent(...
    testCase.TestData.formattedTopLevelTagsWithOneRequiredTag, false);
testCase.verifyNotEmpty(issues);
end % checkIfRequiredTagsPresentTest

function checkIfValidNumericalTagTest(testCase)
issues = testCase.TestData.tagValidator.checkIfValidNumericalTag(...
    testCase.TestData.validNumericTag, testCase.TestData.validNumericTag);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkIfValidNumericalTag(...
    testCase.TestData.invalidNumericTag, ...
    testCase.TestData.invalidNumericTag);
testCase.verifyNotEmpty(issues);
end % checkIfValidNumericalTagTest

function checkUnitClassTagHasUnitsTest(testCase)
warnings = testCase.TestData.tagValidator.checkUnitClassTagHasUnits(...
    testCase.TestData.validUnitClassTagWithUnits, ...
    testCase.TestData.validUnitClassTagWithUnits);
testCase.verifyEmpty(warnings);
warnings = testCase.TestData.tagValidator.checkUnitClassTagHasUnits(...
    testCase.TestData.validUnitClassTagWithNoUnits, ...
    testCase.TestData.validUnitClassTagWithNoUnits);
testCase.verifyNotEmpty(warnings);
end % checkUnitClassTagHasUnitsTest

function checkUnitClassTagHasValidUnitsTest(testCase)
issues = testCase.TestData.tagValidator.checkUnitClassTagHasValidUnits(...
    testCase.TestData.validUnitClassTagWithUnits, ...
    testCase.TestData.validUnitClassTagWithUnits);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkUnitClassTagHasValidUnits(...
    testCase.TestData.unitClassWithInvalidUnits, ...
    testCase.TestData.unitClassWithInvalidUnits);
testCase.verifyNotEmpty(issues);
end % checkUnitClassTagHasValidUnitsTest

function checkNumberOfGroupTildesTest(testCase)
issues = testCase.TestData.tagValidator.checkNumberOfGroupTildes(...
    testCase.TestData.groupWithLessThanTwoTildes);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkNumberOfGroupTildes(...
    testCase.TestData.groupWithLessThanMoreThanTwoTildes);
testCase.verifyNotEmpty(issues);
end % checkNumberOfGroupTildesTest

function checkForMultipleUniquePrefixesTest(testCase)
issues = testCase.TestData.tagValidator.checkForMultipleUniquePrefixes(...
    testCase.TestData.tagsWithOneUniquePrefix);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkForMultipleUniquePrefixes(...
    testCase.TestData.tagsWithMultipleUniquePrefix);
testCase.verifyNotEmpty(issues);
end % checkForMultipleUniquePrefixesTest

function checkIfTagIsValidTest(testCase)
issues = testCase.TestData.tagValidator.checkIfTagIsValid(...
    testCase.TestData.validTag, testCase.TestData.validTag);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkIfTagIsValid(...
    testCase.TestData.validExtensionAllowedTag, ...
    testCase.TestData.validExtensionAllowedTag);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkIfTagIsValid(...
    testCase.TestData.invalidTag, testCase.TestData.invalidTag);
testCase.verifyNotEmpty(issues);
end % checkIfTagIsValidTest

function checkForDuplicateTagsTest(testCase)
issues = testCase.TestData.tagValidator.checkForDuplicateTags(...
    testCase.TestData.noDuplicateTags, testCase.TestData.noDuplicateTags);
testCase.verifyEmpty(issues);
issues = testCase.TestData.tagValidator.checkForDuplicateTags(...
    testCase.TestData.duplicateTags, testCase.TestData.duplicateTags);
testCase.verifyNotEmpty(issues);
end % checkForDuplicateTagsTest

