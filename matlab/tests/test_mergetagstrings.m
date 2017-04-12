function test_suite = test_mergetagstrings %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.tList1 = '/a/b, /c/d';
values.tList3 = '/a/c, /e, /f/g';
values.tList2 = '/A/C, /E, /f/g/h';
values.tList4 = '/a/b, /c/d, /a/b/c';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testMergeTagListsArgumentsValid(values) %#ok<DEFNU>
% Unit test for mergeTagLists
fprintf('\nUnit tests formergetaglists with valid lists\n');

fprintf('It should merge correctly when lists are independent\n');
mergedString1 = mergetagstrings(values.tList1, values.tList2, false);
mergedList1 = regexp(mergedString1, ',', 'split');
assertEqual(length(mergedList1), 5);
mergedString2 = mergetagstrings(values.tList1, values.tList3, false);
mergedList2 = regexp(mergedString2, ',', 'split');
assertEqual(length(mergedList2), 5);

fprintf('It should ignore case differences\n')
mergedString3 = mergetagstrings(values.tList2, values.tList3, false);
mergedList3 = regexp(mergedString3, ',', 'split');
assertEqual(length(mergedList3), 3);

fprintf('It should remove prefixes by default\n');
mergedString4 = mergetagstrings(values.tList1, values.tList4, false);
mergedList4 = regexp(mergedString4, ',', 'split');
assertEqual(length(mergedList4), 2);

fprintf('It should not remove prefixes when preservePrefix is true\n');
mergedString5 = mergetagstrings(values.tList1, values.tList4, true);
mergedList5 = regexp(mergedString5, ',', 'split');
assertEqual(length(mergedList5), 3);

fprintf('It should still work when one of the lists is empty\n');
mergedString6 = mergetagstrings(values.tList1, '', true);
assertTrue(strcmpi(mergedString6, values.tList1));
mergedString7 = mergetagstrings('', values.tList1, true);
assertTrue(strcmpi(mergedString7, values.tList1));

fprintf('It should still work when both lists are empty\n');
mergedString8 = mergetagstrings('', '', true);
assertTrue(isempty(mergedString8));

fprintf('It should return a cellstr\n');
assertTrue(iscellstr(mergedList1));
assertTrue(iscellstr(mergedList2));
assertTrue(iscellstr(mergedList3));
assertTrue(iscellstr(mergedList4));
assertTrue(iscellstr(mergedList5));


function testMergeTagArguments(values) %#ok<DEFNU>
% Unit test for mergeTagLists with invalid tag lists
fprintf('\nUnit tests for mergetaglists with invalid arguments\n');
fprintf(['It should correctly reduce each list when either argument' ...
    ' is empty\n']);
mergedString1 = mergetagstrings(values.tList4, '', true);
mergedList1 = regexp(mergedString1, ',', 'split');
assertEqual(length(mergedList1), 3);
mergedString2 = mergetagstrings(values.tList4, '', false);
mergedList2 = regexp(mergedString2, ',', 'split');
assertEqual(length(mergedList2), 2);
mergedString3 = mergetagstrings('', values.tList4, true);
mergedList3 = regexp(mergedString3, ',', 'split');
assertEqual(length(mergedList3), 3);
mergedString4 = mergetagstrings('', values.tList4, false);
mergedList4 = regexp(mergedString4, ',', 'split');
assertEqual(length(mergedList4), 2);
fprintf('It should return a string when there is only one tag\n');
mergedString5 = mergetagstrings('a/b/c', '', true);
assertTrue(strcmpi(mergedString5, 'a/b/c'));
mergedString6 = mergetagstrings('', 'a/b/c', true);
assertTrue(strcmpi(mergedString6, 'a/b/c'));