function tests = mergetaglistsTest
tests = functiontests(localfunctions);
end % mergetaglistsTest

function setupOnce(testCase)
testCase.TestData.tList1 = {'/a/b', '/c/d'};
testCase.TestData.tList3 = {'/a/c', '/e','/f/g'};
testCase.TestData.tList2 = {'/A/C', '/E', '/f/g/h'};
testCase.TestData.tList4 = {'/a/b', '/c/d', '/a/b/c'};
testCase.TestData.tList5 = {'/a', '/c', '/a/b/c/d'};
end

function testMergeTagListsArgumentsValid(testCase)
% Unit test for mergeTagLists
fprintf('\nUnit tests for mergetaglists with valid lists\n');

fprintf('It should merge correctly when lists are independent\n');
mergedList1 = mergetaglists(testCase.TestData.tList1, testCase.TestData.tList2, false);
testCase.verifyEqual(length(mergedList1), 5);
mergedList2 = mergetaglists(testCase.TestData.tList1, testCase.TestData.tList3, false);
testCase.verifyEqual(length(mergedList2), 5);

fprintf('It should ignore case differences\n')
mergedList3 = mergetaglists(testCase.TestData.tList2, testCase.TestData.tList3, false);
testCase.verifyEqual(length(mergedList3), 3);

fprintf('It should remove prefixes by default\n');
mergedList4 = mergetaglists(testCase.TestData.tList1, testCase.TestData.tList4, false);
testCase.verifyEqual(length(mergedList4), 2);

fprintf('It should not remove prefixes when preservePrefix is true\n');
mergedList5 = mergetaglists(testCase.TestData.tList4, testCase.TestData.tList5, true);
testCase.verifyEqual(length(mergedList5), 6);

fprintf('It should still work when one of the lists is empty\n');
mergedList6 = mergetaglists(testCase.TestData.tList1, '', true);
testCase.verifyEqual(sum(~strcmpi(testCase.TestData.tList1, mergedList6)), 0);
mergedList7 = mergetaglists('', testCase.TestData.tList1, true);
testCase.verifyEqual(sum(~strcmpi(testCase.TestData.tList1, mergedList7)), 0);

fprintf('It should still work when both lists are empty\n');
mergedList8 = mergetaglists('', '', true);
testCase.verifyTrue(isempty(mergedList8));

fprintf('It should return either an empty string or a cellstr\n');
testCase.verifyTrue(iscellstr(mergedList1));
testCase.verifyTrue(iscellstr(mergedList2));
testCase.verifyTrue(iscellstr(mergedList3));
testCase.verifyTrue(iscellstr(mergedList4));
testCase.verifyTrue(iscellstr(mergedList5));
testCase.verifyTrue(iscellstr(mergedList6));
testCase.verifyTrue(iscellstr(mergedList7));
testCase.verifyTrue(isempty(mergedList8));
end


function testMergeTagArguments(testCase)
% Unit test for mergeTagLists with invalid tag lists
fprintf('\nUnit tests for mergetaglists with invalid arguments\n');
fprintf(['It should correctly reduce each list when either argument' ...
    ' is empty\n']);
mergedList1 = mergetaglists(testCase.TestData.tList4, '', true);
testCase.verifyEqual(length(mergedList1), 3);
mergedList2 = mergetaglists(testCase.TestData.tList4, '', false);
testCase.verifyEqual(length(mergedList2), 2);
mergedList3 = mergetaglists('', testCase.TestData.tList4, true);
testCase.verifyEqual(length(mergedList3), 3);
mergedList4 = mergetaglists('', testCase.TestData.tList4, false);
testCase.verifyEqual(length(mergedList4), 2);
fprintf('It should return a string when there is only one tag\n');
mergedList5 = mergetaglists('a/b/c', '', true);
testCase.verifyTrue(ischar(mergedList5));
mergedList6 = mergetaglists('', 'a/b/c', true);
testCase.verifyTrue(ischar(mergedList6));
end