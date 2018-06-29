function tests = findEEGHedEventsTest
tests = functiontests(localfunctions);
end % findEEGHedEventsTest

function setupOnce(testCase)
emptyEventsEEG = [];
emptyEventsEEG.event = [];
testCase.TestData.emptyEventsEEG = emptyEventsEEG;
end

%% Test Functions
function emptyEEGTest(testCase)
[matchMask, tags] = findEEGHedEvents(testCase.TestData.emptyEventsEEG, '');
testCase.verifyEmpty(matchMask);
testCase.verifyEmpty(tags);
end % basicConstructorTest