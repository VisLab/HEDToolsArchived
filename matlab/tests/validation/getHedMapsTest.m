function tests = getHedMapsTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)

end % setupOnce


%% Test Functions
function testBasicInput(testCase)
hedMaps = getHedMaps();
testCase.assertInstanceOf(hedMaps, 'struct');
end % testBasicInput