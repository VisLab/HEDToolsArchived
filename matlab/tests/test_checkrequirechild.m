function test_suite = test_checkrequirechild%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
values.Tags1 = {};
values.Tags2 = {'Event/Label/Test', ...
    'Event/Category/Participant response', 'Event/Duration/100 s'};
values.Tags3 = {'Event/Label/Test', ...
    {'Event/Category/Participant response', 'Event/Duration/100 s'}};
values.Tags4 = {'Event/Category', 'Event/Duration'};
values.Tags5 = {'Event/Label/Test', {'Event/Category', ...
    'Event/Duration'}};
load('HEDMaps.mat');
values.hedMaps = hedMaps;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testCheckRequireChild(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checkrequirechild\n');

fprintf('\nIt should return no errors when there are no tags present');
[errors, tags] = checkrequirechild(values.hedMaps, values.Tags1, ...
    values.Tags1);
assertTrue(isempty(errors));
assertTrue(isempty(tags));
assertEqual(length(tags), 0);

fprintf(['\nIt should return no errors when there are children tags' ...
    ' present\n']);
[errors, tags] = checkrequirechild(values.hedMaps, values.Tags2, ...
    values.Tags2);
assertTrue(isempty(errors));
assertTrue(isempty(tags));
assertEqual(length(tags), 0);

fprintf(['\nIt should return no errors when there are children tags' ...
    ' present in a tag group\n']);
[errors, tags] = checkrequirechild(values.hedMaps, values.Tags3, ...
    values.Tags3);
assertTrue(isempty(errors));
assertTrue(isempty(tags));
assertEqual(length(tags), 0);

fprintf(['\nIt should return errors when there are tags that require' ...
    ' children present\n']);
[errors, tags] = checkrequirechild(values.hedMaps, values.Tags4, ...
    values.Tags4);
assertFalse(isempty(errors));
assertFalse(isempty(tags));
assertEqual(length(tags), 2);

fprintf(['\nIt should return errors when there are tags in a tag group' ...
    ' that require children present\n']);
[errors, tags] = checkrequirechild(values.hedMaps, values.Tags5, ...
    values.Tags5);
assertFalse(isempty(errors));
assertFalse(isempty(tags));
assertEqual(length(tags), 2);