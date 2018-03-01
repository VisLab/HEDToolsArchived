function tests = warningReporterTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.warningsTypes = {'cap', 'required', 'unitClass'};
end % setupOnce


%% Test Functions
function testWarningReporter(testCase)
numberOfWarningTypes = length(testCase.TestData.warningsTypes);
for a = 1:numberOfWarningTypes
    warningReport = warningReporter(testCase.TestData.warningsTypes{a});
    testCase.verifyClass(warningReport, 'char');
end
end % testErrorReporter