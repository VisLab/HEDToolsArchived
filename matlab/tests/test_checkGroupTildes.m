function test_suite = test_checkGroupTildes%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
values.Tags1 = {};
values.Tags2 = {{'Participant', '~', ...
    'Action/Control vehicle/Drive/Collide', '~', ...
    'Item/Object/Vehicle/Car'}};
values.Tags3 = {{'~', 'Participant', '~', ...
    'Action/Control vehicle/Drive/Collide', '~', ...
    'Item/Object/Vehicle/Car'}};

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testRequireChildTags(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checktakesvalue\n');

fprintf('\nIt should return no errors when there are no tags present');
[errors, tags] = checkGroupTildes(values.Tags1);
assertTrue(isempty(errors));
assertTrue(isempty(tags));

fprintf(['\nIt should return no errors when there is a tag group present ' ...
    ' with 2 tildes\n']);
[errors, tags] = checkGroupTildes(values.Tags2);
assertTrue(isempty(errors));
assertTrue(isempty(tags));

fprintf(['\nIt should return errors when there is a tag group present ' ...
    ' with more than 2 tildes\n']);
[errors, tags] = checkGroupTildes(values.Tags3);
assertFalse(isempty(errors));
assertFalse(isempty(tags));
assertEqual(length(tags), 1);