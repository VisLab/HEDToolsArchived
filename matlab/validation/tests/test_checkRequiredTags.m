function test_suite = test_checkRequiredTags%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
load('HEDMaps.mat');
values.hedMaps = hedMaps;
requiredTags = values.hedMaps.required.values();
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
[errors, tags] = checkRequiredTags(values.hedMaps, values.Tags1);
assertFalse(isempty(errors));
assertEqual(length(tags), length(values.hedMaps.required.values()));
assertEqual(tags, values.hedMaps.required.values());

fprintf(['\nIt should return errors when there is one required tag' ...
    ' present and the others are missing\n']);
[errors, tags] = checkRequiredTags(values.hedMaps, values.Tags2);
assertFalse(isempty(errors));
assertEqual(length(tags), length(values.hedMaps.required.values())-1);

fprintf('\nIt should return no errors when all required tags are present');
[errors, tags] = checkRequiredTags(values.hedMaps, values.Tags3);
assertTrue(isempty(errors));
assertEqual(length(tags), 0);