function tests = appendHedTagPrefixesTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.hedTagArray = {'a','b','c'};
testCase.TestData.specificColumns.label = 1;
testCase.TestData.labelPrefix = 'Event/Label/';
end % setupOnce


%% Test Functions
function basicInputTest(testCase)
hedTagArray = appendHedTagPrefixes(testCase.TestData.hedTagArray, ...
    testCase.TestData.specificColumns);
testCase.verifyClass(hedTagArray, 'cell');
expected = {[testCase.TestData.labelPrefix 'a'],'b','c'};
testCase.verifyNotEqual(hedTagArray,expected)
hedTagArray = appendHedTagPrefixes(testCase.TestData.hedTagArray, ...
    testCase.TestData.specificColumns, 'hasHeaders', false);
testCase.verifyClass(hedTagArray, 'cell');
expected = {[testCase.TestData.labelPrefix 'a'],'b','c'};
testCase.verifyEqual(hedTagArray,expected)
end % basicInputTest