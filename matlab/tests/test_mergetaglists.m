function test_suite = test_mergetaglists %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.tList1 = {'/a/b', '/c/d'};
values.tList3 = {'/a/c', '/e','/f/g'};
values.tList2 = {'/A/C', '/E', '/f/g/h'};
values.tList4 = {'/a/b', '/c/d', '/a/b/c'};
values.tList5 = {'/a', '/c', '/a/b/c/d'};

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testMergeTagListsArgumentsValid(values) %#ok<DEFNU>
% Unit test for mergeTagLists
fprintf('\nUnit tests for mergetaglists with valid lists\n');

fprintf('It should merge correctly when lists are independent\n');
mergedList1 = mergetaglists(values.tList1, values.tList2, false);
assertEqual(length(mergedList1), 5);
mergedList2 = mergetaglists(values.tList1, values.tList3, false);
assertEqual(length(mergedList2), 5);

fprintf('It should ignore case differences\n')
mergedList3 = mergetaglists(values.tList2, values.tList3, false);
assertEqual(length(mergedList3), 3);

fprintf('It should remove prefixes by default\n');
mergedList4 = mergetaglists(values.tList1, values.tList4, false);
assertEqual(length(mergedList4), 2);

fprintf('It should not remove prefixes when preservePrefix is true\n');
mergedList5 = mergetaglists(values.tList4, values.tList5, true);
assertEqual(length(mergedList5), 6);

fprintf('It should still work when one of the lists is empty\n');
mergedList6 = mergetaglists(values.tList1, '', true);
assertElementsAlmostEqual(sum(~strcmpi(values.tList1, mergedList6)), 0);
mergedList7 = mergetaglists('', values.tList1, true);
assertElementsAlmostEqual(sum(~strcmpi(values.tList1, mergedList7)), 0);

fprintf('It should still work when both lists are empty\n');
mergedList8 = mergetaglists('', '', true);
assertTrue(isempty(mergedList8));

fprintf('It should return either an empty string or a cellstr\n');
assertTrue(iscellstr(mergedList1));
assertTrue(iscellstr(mergedList2));
assertTrue(iscellstr(mergedList3));
assertTrue(iscellstr(mergedList4));
assertTrue(iscellstr(mergedList5));
assertTrue(iscellstr(mergedList6));
assertTrue(iscellstr(mergedList7));
assertTrue(isempty(mergedList8));


function testMergeTagArguments(values) %#ok<DEFNU>
% Unit test for mergeTagLists with invalid tag lists
fprintf('\nUnit tests for mergetaglists with invalid arguments\n');
fprintf(['It should correctly reduce each list when either argument' ...
    ' is empty\n']);
mergedList1 = mergetaglists(values.tList4, '', true);
assertEqual(length(mergedList1), 3);
mergedList2 = mergetaglists(values.tList4, '', false);
assertEqual(length(mergedList2), 2);
mergedList3 = mergetaglists('', values.tList4, true);
assertEqual(length(mergedList3), 3);
mergedList4 = mergetaglists('', values.tList4, false);
assertEqual(length(mergedList4), 2);
fprintf('It should return a string when there is only one tag\n');
mergedList5 = mergetaglists('a/b/c', '', true);
assertTrue(ischar(mergedList5));
mergedList6 = mergetaglists('', 'a/b/c', true);
assertTrue(ischar(mergedList6));