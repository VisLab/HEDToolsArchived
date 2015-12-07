function test_suite = test_checktakesvalue%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
latestHed = 'HED 2.026.xml';
values.Maps = parsehedxml(latestHed);
values.Tags1 = {};
values.Tags2 = {'/Event/Category/Experiment control/Sequence/Block/abc', ...
    '/Attribute/Repetition/def'};
values.Tags3 = {'/Event/Category/Experiment control/Sequence/Block/123', ...
    '/Attribute/Repetition/456'};
values.Tags4 = {'/Event/Duration/123 m', ...
    '/Item/Symbolic/Sign/Traffic/Speed limit/456 s'};
values.Tags5 = {'/Event/Duration/123 s', ...
    '/Item/Symbolic/Sign/Traffic/Speed limit/456 mph'};
values.Tags6 = {'/Event/Duration/123', ...
    '/Item/Symbolic/Sign/Traffic/Speed limit/456'};
values.Tags7 = {'/Event/Label/Test', ...
    {'/Event/Category/Experiment control/Sequence/Block/abc', ...
    '/Attribute/Repetition/def'}};
values.Tags8 = {'/Event/Label/Test', ...
    {'/Event/Category/Experiment control/Sequence/Block/123', ...
    '/Attribute/Repetition/456'}};
values.Tags9 = {'/Event/Label/Test', ...
    {'/Event/Duration/123 m', ...
    '/Item/Symbolic/Sign/Traffic/Speed limit/456 s'}};
values.Tags10 = {'/Event/Label/Test', ...
    {'/Event/Duration/123 s', ...
    '/Item/Symbolic/Sign/Traffic/Speed limit/456 mph'}};
values.Tags11 = {'/Event/Label/Test', ...
    {'/Event/Duration/123', ...
    '/Item/Symbolic/Sign/Traffic/Speed limit/456'}};

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testRequireChildTags(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checktakesvalue\n');

fprintf('\nIt should return no errors when there are no tags present');
[errors, tags] = checktakesvalue(values.Maps, values.Tags1, values.Tags1);
assertTrue(isempty(errors));
assertTrue(isempty(tags));

fprintf(['\nIt should return errors when there are tags present ' ...
    ' that are supposed to be numeric but are not\n']);
[errors, tags] = checktakesvalue(values.Maps, values.Tags2, values.Tags2);
assertFalse(isempty(errors));
assertFalse(isempty(tags));
assertEqual(length(tags), 2);

fprintf(['\nIt should return no errors when there are numeric' ...
    ' tags present\n']);
[errors, tags] = checktakesvalue(values.Maps, values.Tags3, values.Tags3);
assertTrue(isempty(errors));
assertTrue(isempty(tags));

fprintf(['\nIt should return errors when there are tags present ' ...
    ' that are supposed to be numeric with units but have the' ...
    ' wrong units\n']);
[errors, tags] = checktakesvalue(values.Maps, values.Tags4, values.Tags4);
assertFalse(isempty(errors));
assertFalse(isempty(tags));
assertEqual(length(tags), 2);

fprintf(['\nIt should return no errors when there are numeric' ...
    ' tags that take units with the correct units present\n']);
[errors, tags] = checktakesvalue(values.Maps, values.Tags5, values.Tags5);
assertTrue(isempty(errors));
assertTrue(isempty(tags));

fprintf(['\nIt should return no errors when there are numeric' ...
    ' tags without units present\n']);
[errors, errorTags, warnings, warningTags] = ...
    checktakesvalue(values.Maps, values.Tags6, values.Tags6);
assertTrue(isempty(errors));
assertTrue(isempty(errorTags));
assertFalse(isempty(warnings));
assertFalse(isempty(warningTags));
assertEqual(length(warningTags), 2);

fprintf(['\nIt should return errors when there are tags present ' ...
    ' in a tag group that are supposed to be numeric but are not\n']);
[errors, tags] = checktakesvalue(values.Maps, values.Tags7, values.Tags7);
assertFalse(isempty(errors));
assertFalse(isempty(tags));
assertEqual(length(tags), 2);

fprintf(['\nIt should return no errors when there are numeric' ...
    ' tags in a tag group present\n']);
[errors, tags] = checktakesvalue(values.Maps, values.Tags8, values.Tags8);
assertTrue(isempty(errors));
assertTrue(isempty(tags));

fprintf(['\nIt should return errors when there are tags present in ' ...
    ' a tag group that are supposed to be numeric with units but have ' ...
    ' the wrong units\n']);
[errors, tags] = checktakesvalue(values.Maps, values.Tags9, values.Tags9);
assertFalse(isempty(errors));
assertFalse(isempty(tags));
assertEqual(length(tags), 2);

fprintf(['\nIt should return no errors when there are numeric' ...
    ' tags in a tag group that take units with the correct units' ...
    ' present\n']);
[errors, tags] = checktakesvalue(values.Maps, values.Tags10, values.Tags10);
assertTrue(isempty(errors));
assertTrue(isempty(tags));

fprintf(['\nIt should return no errors when there are numeric' ...
    ' tags in a tag group without units present\n']);
[errors, errorTags, warnings, warningTags] = ...
    checktakesvalue(values.Maps, values.Tags11, values.Tags11);
assertTrue(isempty(errors));
assertTrue(isempty(errorTags));
assertFalse(isempty(warnings));
assertFalse(isempty(warningTags));
assertEqual(length(warningTags), 2);