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
eegWithHedTags.event(1).hedtags = '/a/b/c, e/f/g';
eegWithHedTags.event(2).hedtags = 'a/b';
testCase.TestData.eegWithHedTags = eegWithHedTags;
testCase.TestData.queryString1 = 'a';
testCase.TestData.queryString2 = 'e/f/g';

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
[matchMask, tags] = findEEGHedEvents(testCase.TestData.eegWithUserTags, ...
    testCase.TestData.queryString1);
testCase.verifyEqual(matchMask, true(1, ...
    length(testCase.TestData.eegWithUserTags.event)));
testCase.verifyNotEmpty(tags);
[matchMask, tags] = findEEGHedEvents(testCase.TestData.eegWithUserTags, ...
    testCase.TestData.queryString2);
testCase.verifyEqual(matchMask, [true false]);
testCase.verifyNotEmpty(tags);
end % usertagsTest

function hedtagsTest(testCase)
[matchMask, tags] = findEEGHedEvents(testCase.TestData.eegWithHedTags, ...
    testCase.TestData.emptyQueryString);
testCase.verifyEqual(matchMask, false(1, ...
    length(testCase.TestData.eegWithUserTags.event)));
testCase.verifyEmpty(tags);
[matchMask, tags] = findEEGHedEvents(testCase.TestData.eegWithHedTags, ...
    testCase.TestData.queryString1);
testCase.verifyEqual(matchMask, true(1, ...
    length(testCase.TestData.eegWithHedTags.event)));
testCase.verifyNotEmpty(tags);
[matchMask, tags] = findEEGHedEvents(testCase.TestData.eegWithHedTags, ...
    testCase.TestData.queryString2);
testCase.verifyEqual(matchMask, [true false]);
testCase.verifyNotEmpty(tags);
end % usertagsTest