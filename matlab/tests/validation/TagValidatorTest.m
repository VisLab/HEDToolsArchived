function tests = TagValidatorTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
load('hedMaps.mat');
testCase.TestData.tagValidator = TagValidator(hedMaps);
testCase.TestData.validCapsTag = 'This is/A/Valid tag';
testCase.TestData.invalidCapsTag = 'This Is/A/invalid tag';
end % setupOnce


%% Test Functions
function checkCapsTest(testCase)
warnings = testCase.TestData.tagValidator.checkCaps(...
    testCase.TestData.validCapsTag);
testCase.verifyEmpty(warnings);
warnings = testCase.TestData.tagValidator.checkCaps(...
    testCase.TestData.invalidCapsTag);
testCase.verifyNotEmpty(warnings);
end % testErrorReporter