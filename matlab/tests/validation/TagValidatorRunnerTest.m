function tests = TagValidatorRunnerTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.hedMaps = getHedMaps();
end % setupOnce


%% Test Functions
function testConstructor(testCase)
tagValidatorRunner = TagValidatorRunner(testCase.TestData.hedMaps);
testCase.assertInstanceOf(tagValidatorRunner, 'TagValidatorRunner');
end % testConstructor