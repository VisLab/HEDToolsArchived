function tests = TagValidatorTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
load('hedMaps.mat');
requiredTags = hedMaps.required.keys();
numericTags = hedMaps.isNumeric.keys();
unitClassTags = hedMaps.unitClass.keys();
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


end % setupOnce


%% Test Functions
function checkCapsTest(testCase)
warnings = testCase.TestData.tagValidator.checkCaps(...
    testCase.TestData.validCapsTag);
testCase.verifyEmpty(warnings);
warnings = testCase.TestData.tagValidator.checkCaps(...
    testCase.TestData.invalidCapsTag);
testCase.verifyNotEmpty(warnings);
end % checkCapsTest

function checkCommasTest(testCase)
errors = testCase.TestData.tagValidator.checkCommas(...
    testCase.TestData.validHedStringWithCommas);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkCommas(...
    testCase.TestData.commaMissingBeforeOpeningParenthesis);
testCase.verifyNotEmpty(errors);
errors = testCase.TestData.tagValidator.checkCommas(...
    testCase.TestData.commaMissingAfterClosingParenthesis);
testCase.verifyNotEmpty(errors);
end

function checkGroupBracketsTest(testCase)
errors = testCase.TestData.tagValidator.checkGroupBrackets(...
    testCase.TestData.validGroupWithEqualBrackets);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkGroupBrackets(...
    testCase.TestData.validGroupWithUnequalBrackets);
testCase.verifyNotEmpty(errors);
end

function checkRequiredChildTagsTest(testCase)
errors = testCase.TestData.tagValidator.checkRequiredChildTags(...
    testCase.TestData.validRequireChildTag, ...
    testCase.TestData.validRequireChildTag);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkRequiredChildTags(...
    testCase.TestData.invalidRequireChildTag, ...
    testCase.TestData.invalidRequireChildTag);
testCase.verifyNotEmpty(errors);
end

function checkRequiredTagsTest(testCase)
errors = testCase.TestData.tagValidator.checkRequiredTags(...
    testCase.TestData.formattedTopLevelTagsWithAllRequiredTags);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkRequiredTags(...
    testCase.TestData.formattedTopLevelTagsWithOneRequiredTag);
testCase.verifyNotEmpty(errors);
end

function checkNumericalTagTest(testCase)
errors = testCase.TestData.tagValidator.checkNumericalTag(...
    testCase.TestData.validNumericTag, testCase.TestData.validNumericTag);
testCase.verifyEmpty(errors);
errors = testCase.TestData.tagValidator.checkNumericalTag(...
    testCase.TestData.invalidNumericTag, ...
    testCase.TestData.invalidNumericTag);
testCase.verifyNotEmpty(errors);
end

