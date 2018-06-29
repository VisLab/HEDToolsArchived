function tests = findEEGHedEventsTest
tests = functiontests(localfunctions);
end % findEEGHedEventsTest

function setupOnce(testCase)
testCase.TestData.emptyQueryString = '';
eegWithNoTags.event = [];
testCase.TestData.eegWithNoTags = eegWithNoTags;
eegWithUserTags.event(1).usertags = '/a/b/c, e/f/g';
eegWithUserTags.event(2).usertags = 'a/b';
testCase.TestData.eegWithUserTags = eegWithUserTags;
end

%% Test Functions
function emptyEEGTest(testCase)
[matchMask, tags] = findEEGHedEvents(testCase.TestData.eegWithNoTags, ...
    testCase.TestData.emptyQueryString);
testCase.verifyEmpty(matchMask);
testCase.verifyEmpty(tags);
end % emptyEEGTest

function usertagsTest(testCase)
[matchMask, tags] = findEEGHedEvents(testCase.TestData.eegWithUserTags, ...
    testCase.TestData.emptyQueryString);
testCase.verifyEqual(matchMask, false(1, ...
    length(testCase.TestData.eegWithUserTags.event)));
testCase.verifyEmpty(tags);
end % emptyEEGTest