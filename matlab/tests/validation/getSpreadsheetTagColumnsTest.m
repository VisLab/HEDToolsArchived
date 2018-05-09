function tests = getSpreadsheetTagColumnsTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.otherColumns = [2,3];
testCase.TestData.specificColumns.label = 1;
testCase.TestData.spreadsheetColumnCount = 4;
end % setupOnce


%% Test Functions
function basicInputTest(testCase)
tagColumns = getSpreadsheetTagColumns(testCase.TestData.otherColumns, ...
    testCase.TestData.specificColumns, ...
    testCase.TestData.spreadsheetColumnCount);
testCase.verifyClass(tagColumns, 'double');
expected = [1,2,3];
testCase.verifyEqual(tagColumns,expected)
end % basicInputTest