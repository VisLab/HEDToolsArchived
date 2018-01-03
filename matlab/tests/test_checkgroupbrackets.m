function test_suite = test_checkgroupbrackets%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.EmptyString = '';
values.HEDString1 = ['(Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car)'];
values.HEDString2 = ['(Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car'];

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testCheckGroupBrackets(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checkgroupbrackets\n');

fprintf('\nIt should return no errors when there is a empty HED string');
errors = checkgroupbrackets(values.EmptyString);
assertTrue(isempty(errors));

fprintf(['\nIt should return no errors when there are equal opening' ...
    ' and closing brackets in a HED string']);
errors = checkgroupbrackets(values.HEDString1);
assertTrue(isempty(errors));

fprintf(['\nIt should return errors when there are unequal opening' ...
    ' and closing brackets in a HED string']);
errors = checkgroupbrackets(values.HEDString2);
assertFalse(isempty(errors));