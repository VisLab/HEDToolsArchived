function tests = mergetagstringsTest
tests = functiontests(localfunctions);
end % mergetagstringsTest

function setupOnce(testCase)
testCase.TestData.tList1 = '/a/b, /c/d';
testCase.TestData.tList3 = '/a/c, /e, /f/g';
testCase.TestData.tList2 = '/A/C, /E, /f/g/h';
testCase.TestData.tList4 = '/a/b, /c/d, /a/b/c';
end

function testMergeTagListsArgumentsValid(testCase)
% Unit test for mergeTagLists
fprintf('\nUnit tests formergetaglists with valid lists\n');

fprintf('It should merge correctly when lists are independent\n');
mergedString1 = mergetagstrings(testCase.TestData.tList1, testCase.TestData.tList2, false);
mergedList1 = regexp(mergedString1, ',', 'split');
testCase.verifyEqual(length(mergedList1), 5);
mergedString2 = mergetagstrings(testCase.TestData.tList1, testCase.TestData.tList3, false);
mergedList2 = regexp(mergedString2, ',', 'split');
testCase.verifyEqual(length(mergedList2), 5);

fprintf('It should ignore case differences\n')
mergedString3 = mergetagstrings(testCase.TestData.tList2, testCase.TestData.tList3, false);
mergedList3 = regexp(mergedString3, ',', 'split');
testCase.verifyEqual(length(mergedList3), 3);

fprintf('It should remove prefixes by default\n');
mergedString4 = mergetagstrings(testCase.TestData.tList1, testCase.TestData.tList4, false);
mergedList4 = regexp(mergedString4, ',', 'split');
testCase.verifyEqual(length(mergedList4), 2);

fprintf('It should not remove prefixes when preservePrefix is true\n');
mergedString5 = mergetagstrings(testCase.TestData.tList1, testCase.TestData.tList4, true);
mergedList5 = regexp(mergedString5, ',', 'split');
testCase.verifyEqual(length(mergedList5), 3);

fprintf('It should still work when one of the lists is empty\n');
mergedString6 = mergetagstrings(testCase.TestData.tList1, '', true);
testCase.verifyTrue(strcmpi(mergedString6, testCase.TestData.tList1));
mergedString7 = mergetagstrings('', testCase.TestData.tList1, true);
testCase.verifyTrue(strcmpi(mergedString7, testCase.TestData.tList1));

fprintf('It should still work when both lists are empty\n');
mergedString8 = mergetagstrings('', '', true);
testCase.verifyTrue(isempty(mergedString8));

fprintf('It should return a cellstr\n');
testCase.verifyTrue(iscellstr(mergedList1));
testCase.verifyTrue(iscellstr(mergedList2));
testCase.verifyTrue(iscellstr(mergedList3));
testCase.verifyTrue(iscellstr(mergedList4));
testCase.verifyTrue(iscellstr(mergedList5));
end


function testMergeTagArguments(testCase)
% Unit test for mergeTagLists with invalid tag lists
fprintf('\nUnit tests for mergetaglists with invalid arguments\n');
fprintf(['It should correctly reduce each list when either argument' ...
    ' is empty\n']);
mergedString1 = mergetagstrings(testCase.TestData.tList4, '', true);
mergedList1 = regexp(mergedString1, ',', 'split');
testCase.verifyEqual(length(mergedList1), 3);
mergedString2 = mergetagstrings(testCase.TestData.tList4, '', false);
mergedList2 = regexp(mergedString2, ',', 'split');
testCase.verifyEqual(length(mergedList2), 2);
mergedString3 = mergetagstrings('', testCase.TestData.tList4, true);
mergedList3 = regexp(mergedString3, ',', 'split');
testCase.verifyEqual(length(mergedList3), 3);
mergedString4 = mergetagstrings('', testCase.TestData.tList4, false);
mergedList4 = regexp(mergedString4, ',', 'split');
testCase.verifyEqual(length(mergedList4), 2);
fprintf('It should return a string when there is only one tag\n');
mergedString5 = mergetagstrings('a/b/c', '', true);
testCase.verifyTrue(strcmpi(mergedString5, 'a/b/c'));
mergedString6 = mergetagstrings('', 'a/b/c', true);
testCase.verifyTrue(strcmpi(mergedString6, 'a/b/c'));
end