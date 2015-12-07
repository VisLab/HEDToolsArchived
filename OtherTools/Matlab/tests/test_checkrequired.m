function test_suite = test_checkrequired%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
latestHed = 'HED 2.026.xml';
values.Maps = parsehedxml(latestHed);
requiredTags = values.Maps.required.values();
values.Tags1 = {};
values.Tags2 = requiredTags(1);
values.Tags3 = requiredTags;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testRequiredTags(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checkrequired\n');

fprintf(['\nIt should return errors when there are no required tags' ...
    ' present\n']);
[errors, tags] = checkrequired(values.Maps, values.Tags1);
assertFalse(isempty(errors));
assertEqual(length(tags), length(values.Maps.required.values()));
assertEqual(tags, values.Maps.required.values());

fprintf(['\nIt should return errors when there is one required tag' ...
    ' present and the others are missing\n']);
[errors, tags] = checkrequired(values.Maps, values.Tags2);
assertFalse(isempty(errors));
assertEqual(length(tags), length(values.Maps.required.values())-1);

fprintf('\nIt should return no errors when all required tags are present');
[errors, tags] = checkrequired(values.Maps, values.Tags3);
assertTrue(isempty(errors));
assertEqual(length(tags), 0);