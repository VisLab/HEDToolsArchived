function test_suite = test_checkTagCaps%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
values.Tags1 = {};
values.Tags2 = {'event/Category', ...
    'Event/description/This is the best description' ,'Event/Label'};
values.Tags3 = {'Event/Category'
    'Action/Control Vehicle/Drive/Collide'};
values.Tags4 = {'Event/Label/Test', {'Participant', '~', ...
    'action/Control vehicle/Drive/Collide', '~', ...
    'Item/Object/Vehicle/Car'}};
values.Tags5 = {'Event/Label/Test', {'Participant', '~', ...
    'Action/Control Vehicle/Drive/Collide', '~', ...
    'Item/Object/Vehicle/Car'}};
load('HEDMaps.mat');
values.hedMaps = hedMaps;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testRequireChildTags(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checkrequirechild\n');

fprintf(['\nIt should return no warnings when there are no' ...
    ' tags present\n']);
[warnings, tags] = checkTagCaps(values.hedMaps, values.Tags1, ...
    values.Tags1);
assertTrue(isempty(warnings));
assertTrue(isempty(tags));

fprintf(['\nIt should return warnings when the first letter of a event' ...
    ' level tag is not capitalized\n']);
[warnings, tags] = checkTagCaps(values.hedMaps, values.Tags2, ...
    values.Tags2);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);

fprintf(['\nIt should return warnings when a word in a event level tag' ...
    ' is not the first word and is capitilized\n']);
[warnings, tags] = checkTagCaps(values.hedMaps, values.Tags3, ...
    values.Tags3);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);

fprintf(['\nIt should return warnings when the first letter of a ' ...
    ' tag in a tag group is not capitalized\n']);
[warnings, tags] = checkTagCaps(values.hedMaps, values.Tags4, ...
    values.Tags4);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);

fprintf(['\nIt should return warnings when a word of a tag in a tag' ...
    ' group is not the first word and is capitilized\n']);
[warnings, tags] = checkTagCaps(values.hedMaps, values.Tags5, ...
    values.Tags5);
assertFalse(isempty(warnings));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);