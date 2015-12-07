function test_suite = test_checkslashes%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
values.Tags1 = {};
values.Tags2 = {'Event/Category', '/Event/Label'};
values.Tags3 = {'/Event/Category'
    '/Action/Type/Control Vehicle/Drive/Collide/'};
values.Tags4 = {'/Event/Label/Test', {'Participant', '~', ...
    '/Action/Type/Control vehicle/Drive/Collide', '~', ...
    '/Item/Object/Vehicle/Car'}};
values.Tags5 = {'/Event/Label/Test', {'/Participant', '~', ...
    '/Action/Type/Control Vehicle/Drive/Collide/', '~', ...
    '/Item/Object/Vehicle/Car'}};

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

fprintf(['\nIt should return warnings when the tag does not start with' ...
    ' a slash\n']);
[warnings, tags] = checkslashes(values.Tags2);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);

fprintf('\nIt should return warnings when the tag ends with a slash');
[warnings, tags] = checkslashes(values.Tags3);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);

fprintf(['\nIt should return warnings when a tag in a tag group does' ...
    ' not start with a slash\n']);
[warnings, tags] = checkslashes(values.Tags4);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);

fprintf(['\nIt should return warnings when a tag in a tag group ends' ...
    ' with a slash']);
[warnings, tags] = checkslashes(values.Tags5);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);