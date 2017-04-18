function test_suite = test_findhedevents %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Function executed before each test
values.event(1).usertags = 'a/b, b/c/d';
values.event(2).usertags = 'a/b';
values.event(3).usertags = 'b/c';
values.event(4).usertags = 'a/b, b/c';
values.event(5).usertags = 'e/a/b';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testFindHedEvents(values) %#ok<DEFNU>
fprintf(['\nIt should return no matches when the tag search string is' ...
    ' empty\n']);
numMatches = 0;
tags = '';
positions = findhedevents(values, 'tags', tags);
assertEqual(length(positions), numMatches);

fprintf('\nIt should return 2 matches\n');
numMatches = 2;
tags = 'a/b, b/c';
positions = findhedevents(values, 'tags', tags);
assertEqual(length(positions), numMatches);

fprintf('\nIt should return 1 matches\n');
numMatches = 1;
tags = 'e/a/b';
positions = findhedevents(values, 'tags', tags);
assertEqual(length(positions), numMatches);

fprintf('\nIt should return 3 matches\n');
numMatches = 3;
tags = 'b/c';
positions = findhedevents(values, 'tags', tags);
assertEqual(length(positions), numMatches);