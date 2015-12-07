function test_suite = test_checkunique%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
latestHed = 'HED 2.026.xml';
values.Maps = parsehedxml(latestHed);
values.Tags1 = {};
values.Tags2 = {'/Event/Description/Description 1', ...
    '/Event/Description/Description 2'};
values.Tags3 = {'/Event/Label/Test', ...
    {'/Event/Description/Description 1', ...
    '/Event/Description/Description 2'}};

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testRequiredTags(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checkunique\n');

fprintf('\nIt should return no errors when there are no tags present');
[errors, tags] = checkunique(values.Maps, values.Tags1, values.Tags1);
assertTrue(isempty(errors));
assertTrue(isempty(tags));

fprintf(['\nIt should return errors when there are multiple unique' ...
    ' tags with the same prefix present\n']);
[errors, tags] = checkunique(values.Maps, values.Tags2, values.Tags2);
assertFalse(isempty(errors));
assertFalse(isempty(tags));
assertEqual(length(tags), 2);

fprintf(['\nIt should return errors when there are multiple unique' ...
    ' tags in a tag group with the same prefix present\n']);
[errors, tags] = checkunique(values.Maps, values.Tags3, values.Tags3);
assertFalse(isempty(errors));
assertFalse(isempty(tags));
assertEqual(length(tags), 2);