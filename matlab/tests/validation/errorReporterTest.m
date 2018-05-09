function tests = errorReporterTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.errorTypes = {'bracket','comma','commaValid', ...
    'duplicate','isNumeric','row','column','required','requireChild', ...
    'tilde','unique','unitClass','valid'};
end % setupOnce


%% Test Functions
function testWarningReporter(testCase)
numErrors = length(testCase.TestData.errorTypes);
for a = 1:numErrors
    warningReport = errorReporter(testCase.TestData.errorTypes{a});
    testCase.verifyClass(warningReport, 'char');
end
end % testErrorReporter