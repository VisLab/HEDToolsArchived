function test_suite = test_checkslashes%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
values.Tags1 = {};
values.Tags2 = {'Event/Category'
    'Action/Control Vehicle/Drive/Collide/'};
values.Tags3 = {'Event/Label/Test', {'Participant', '~', ...
    'Action/Control Vehicle/Drive/Collide/', '~', ...
    'Item/Object/Vehicle/Car'}};

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testRequireChildTags(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checkrequirechild\n');

fprintf(['\nIt should return no warnings when there are no' ...
    ' tags present\n']);
[warnings, tags] = checkslashes(values.Tags1);
assertTrue(isempty(warnings));
assertTrue(isempty(tags));


fprintf('\nIt should return warnings when the tag ends with a slash');
[warnings, tags] = checkslashes(values.Tags2);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);

fprintf(['\nIt should return warnings when a tag in a tag group ends' ...
    ' with a slash']);
[warnings, tags] = checkslashes(values.Tags3);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);