function tests = errorReporterTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.errorTypes = {'bracket', 'row', 'isNumeric', 'requireChild', ...
    'tilde', 'unique', 'unitClass', 'valid'};
end % setupOnce


%% Test Functions
function testErrorReporter(testCase)
numberOfErrorTypes = length(testCase.TestData.errorTypes);
for a = 1:numberOfErrorTypes
    errorReport = errorReporter(testCase.TestData.errorTypes{a});
    testCase.verifyClass(errorReport, 'char');
end
end % testErrorReporter