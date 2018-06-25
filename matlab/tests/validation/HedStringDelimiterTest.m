function tests = HedStringDelimiterTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.hedStringNoGroups = ...
    ['Event/Category/Experimental stimulus,' ...
    'Event/Label/LAuditory non-animal,' ...
    'Event/Description/A non-animal name in auditory form is presented from the left speaker.'];
testCase.TestData.hedStringGroups = ...
    ['Event/Category/Experimental stimulus, (Item,' ...
    'Sensory presentation/Auditory/Human Voice,' ...
    'Attribute/Location/Reference frame/Relative to Participant/Left,' ...
    'Attribute/Language/Unit/Word/Noun/Common/Non-animal,' ...
    'Participant/Effect/Auditory,' ...
    'Participant/Effect/Cognitive/Expected/Non-target)' ...
    'Event/Label/LAuditory non-animal,' ...
    'Event/Description/A non-animal name in auditory form is presented from the left speaker.'];
testCase.TestData.hedStringEmptyTags = ...
    ['Event/Category/Experimental stimulus,' ...
    'Event/Label/LAuditory non-animal,' ...
    'Event/Description/A non-animal name in auditory form is presented from the left speaker.'];
testCase.TestData.hedStringEqualBrackets = '()';
testCase.TestData.hedStringUnequalBrackets = '(()';
testCase.TestData.nestedGroup = '(a/b/c/d, b/c/d (d/e/f/,c/d/e)) d/e/f';
testCase.TestData.nestedGroupCellArray = {{'a/b/c/d', 'b/c/d', {'d/e/f/', 'c/d/e'}}, 'd/e/f'};
end

%% Test Functions
function basicConstructorTest(testCase)
hedStringDelimiter = HedStringDelimiter('');
testCase.verifyClass(hedStringDelimiter, 'HedStringDelimiter');
end % basicConstructorTest

function noGroupTest(testCase)
hedStringDelimiter = HedStringDelimiter(testCase.TestData.hedStringNoGroups);
tags = hedStringDelimiter.getTags();
testCase.verifyEqual(length(tags), 3);
topLevelTags = hedStringDelimiter.getTopLevelTags();
testCase.verifyEqual(length(topLevelTags), 3);
groupTags = hedStringDelimiter.getGroupTags();
testCase.verifyEqual(length(groupTags), 0);
uniqueTags = hedStringDelimiter.getUniqueTags();
testCase.verifyEqual(length(uniqueTags), 3);
end % noGroupTest

function groupTest(testCase)
hedStringDelimiter = HedStringDelimiter(testCase.TestData.hedStringGroups);
tags = hedStringDelimiter.getTags();
testCase.verifyEqual(length(tags), 4);
topLevelTags = hedStringDelimiter.getTopLevelTags();
testCase.verifyEqual(length(topLevelTags), 3);
groupTags = hedStringDelimiter.getGroupTags();
testCase.verifyEqual(length(groupTags{1}), 6);
uniqueTags = hedStringDelimiter.getUniqueTags();
testCase.verifyEqual(length(uniqueTags), 9);
end % groupTest

function hedString2CellTest(testCase)
cellArray =  HedStringDelimiter.hedString2Cell(...
    testCase.TestData.hedStringEqualBrackets);
testCase.verifyEqual(cellArray, {{}});
cellArray =  HedStringDelimiter.hedString2Cell(...
    testCase.TestData.hedStringUnequalBrackets);
testCase.verifyEqual(cellArray, {});
cellArray =  HedStringDelimiter.hedString2Cell(...
    testCase.TestData.nestedGroup);
testCase.verifyEqual(cellArray, testCase.TestData.nestedGroupCellArray);
end % hedString2CellTest