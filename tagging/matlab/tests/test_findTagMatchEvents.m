function test_suite = test_findTagMatchEvents %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Function executed before each test
values.events(1).usertags = 'a/b, b/c/d';
values.events(2).usertags = 'a/b';
values.events(3).usertags = 'b/c';
values.events(4).usertags = 'a/b, b/c';
values.events(5).usertags = 'e/a/b';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidTagSearch(values) %#ok<DEFNU>
% Unit test for fieldMap adding structure events
fprintf('\nUnit tests for valid tag search in event structure\n');
numMatches = 2;
tags = 'a/b, b/c';
positions = findTagMatchEvents(values.events, tags);
assertEqual(sum(positions), numMatches);

function testEmptyTagSearch(values) %#ok<DEFNU>
% Unit test for fieldMap adding structure events
fprintf('\nUnit tests for invalid tag search in event structure\n');
numMatches = 2;
tags = 'a/b, b/c,';
positions = findTagMatchEvents(values.events, tags);
assertEqual(sum(positions), numMatches);

tags = 'a/b, b/c, ';
positions = findTagMatchEvents(values.events, tags);
assertEqual(sum(positions), numMatches);

tags = 'a/b, , , b/c';
positions = findTagMatchEvents(values.events, tags);
assertEqual(sum(positions), numMatches);