function test_suite = test_checkvalid%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
values.Tags1 = {};
values.Tags2 = {'Item/Object/Vehicle/Car', ...
    'Action/Button hold'};
values.Tags3 = {'Event/Category/Abc', ...
    'Action/Def'};
values.Tags4 = {'Item/Object/Animal/Bird', ...
    'Item/Object/Bench'};
values.Tags5 = {'Event/Label/Test' ...
    {'Item/Object/Vehicle/Car', ...
    'Action/Button hold'}};
values.Tags6 = {'Event/Label/Test' ...
    {'Event/Category/Abc', ...
    'Action/Type/Def'}};
values.Tags7 = {'Event/Label/Test' ...
    {'Item/Object/Animal/Bird', ...
    'Item/Object/Bench'}};
load('HEDMaps.mat');
values.hedMaps = hedMaps;
values.extensionAllowedTags = values.hedMaps.extensionAllowed.values;
values.takesValueTags = values.hedMaps.takesValue.values;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testRequireChildTags(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checkrequirechild\n');

fprintf(['\nIt should return no errors when there are no'  ...
    ' tags present\n']);
[errors, errorTags] = ...
    checkvalid(values.hedMaps, values.Tags1, values.Tags1);
assertTrue(isempty(errors));
assertTrue(isempty(errorTags));

fprintf(['\nIt should return no errors when there are valid'  ...
    ' tags present\n']);
[errors, errorTags] = ...
    checkvalid(values.hedMaps, values.Tags2, values.Tags2);
assertTrue(isempty(errors));
assertTrue(isempty(errorTags));

fprintf(['\nIt should return errors when there are no valid tags' ...
    ' present\n']);
[errors, errorTags] = ...
    checkvalid(values.hedMaps, values.Tags3, values.Tags3);
assertFalse(isempty(errors));
assertFalse(isempty(errorTags));
assertEqual(length(errorTags), 2);

fprintf(['\nIt should return errors when there are extension allowed' ...
    ' tags present but the extension allowed option is set to false\n']);
[errors, errorTags] = ...
    checkvalid(values.hedMaps, values.Tags4, values.Tags4);
assertFalse(isempty(errors));
assertFalse(isempty(errorTags));
assertEqual(length(errorTags), 2);

fprintf(['\nIt should return no errors when there are extension' ...
    ' allowed tags present and the extension allowed option is set to' ...
    ' true\n']);
[errors, errorTags] = ...
    checkvalid(values.hedMaps, values.Tags4, values.Tags4);
assertTrue(isempty(errors));
assertTrue(isempty(errorTags));

fprintf(['\nIt should return no errors when there are valid'  ...
    ' tags in a tag group present\n']);
[errors, errorTags] = ...
    checkvalid(values.hedMaps, values.Tags5, values.Tags5);
assertTrue(isempty(errors));
assertTrue(isempty(errorTags));

fprintf(['\nIt should return errors when there are no valid tags' ...
    ' in a tag group present\n']);
[errors, errorTags] = ...
    checkvalid(values.hedMaps, values.Tags6, values.Tags6);
assertFalse(isempty(errors));
assertFalse(isempty(errorTags));
assertEqual(length(errorTags), 2);

fprintf(['\nIt should return errors when there are extension allowed' ...
    ' tags in a tag group present but the extension allowed option is' ...
    ' set to false\n']);
[errors, errorTags] = ...
    checkvalid(values.hedMaps, values.Tags7, values.Tags7);
assertFalse(isempty(errors));
assertFalse(isempty(errorTags));
assertEqual(length(errorTags), 2);

fprintf(['\nIt should return no errors when there are extension ' ...
    ' allowed tags in a tag group present and the extension allowed' ...
    ' option is set to true\n']);
[errors, errorTags] = ...
    checkvalid(values.hedMaps, values.Tags4, values.Tags4);
assertTrue(isempty(errors));
assertTrue(isempty(errorTags));