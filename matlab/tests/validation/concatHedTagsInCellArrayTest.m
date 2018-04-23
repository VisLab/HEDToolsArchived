function tests = concatHedTagsInCellArrayTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.hedTagArray = {'a','b','c'};
testCase.TestData.hedTagColumns1 = [1,2];
testCase.TestData.hedTagColumns2 = [1,3];
end % setupOnce


%% Test Functions
function basicInputTest(testCase)
hedString = concatHedTagsInCellArray(testCase.TestData.hedTagArray, ...
    testCase.TestData.hedTagColumns1);
testCase.verifyClass(hedString, 'char');
hedString = concatHedTagsInCellArray(testCase.TestData.hedTagArray, ...
    testCase.TestData.hedTagColumns2);
testCase.verifyClass(hedString, 'char');
end % basicInputTest