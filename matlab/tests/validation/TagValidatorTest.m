function tests = TagValidatorTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
load('hedMaps.mat');
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

