function tests = HedDictionaryTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.HEDXML = 'HED.xml';
% testCase.TestData.HedDictionary = HedDictionary(testCase.TestData.HEDXML);
end % setupOnce


%% Test Functions
function testFindRootElement(testCase)
        root_element = ...
            HedDictionary.findRootElement(testCase.TestData.HEDXML);
        testCase.verifyClass(root_element, ...
            'org.apache.xerces.dom.DeferredElementImpl');
end % testErrorReporter