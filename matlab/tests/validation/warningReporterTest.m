function tests = warningReporterTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.warningTypes = {'cap', 'required', 'unitClass'};
end % setupOnce


%% Test Functions
function testWarningReporter(testCase)
numWarnings = length(testCase.TestData.warningTypes);
for a = 1:numWarnings
    warningReport = warningReporter(testCase.TestData.warningTypes{a});
    testCase.verifyClass(warningReport, 'char');
end
end % testErrorReporter