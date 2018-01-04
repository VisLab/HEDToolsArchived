function test_suite = test_checkcommas%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.EmptyString = '';
values.HEDString1 = ['Event/Label/Test1, (Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car)'];
values.HEDString2 = ['Event/Label/Test1 (Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car)'];
values.HEDString3 = ['(Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car) Event/Label/Test1'];

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testCheckCommas(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checkgroupbrackets\n');

fprintf('\nIt should return no errors when there is a empty HED string');
errors = checkcommas(values.EmptyString);
assertTrue(isempty(errors));

fprintf(['\nIt should return no errors when there are no missing' ...
    ' commas']);
errors = checkcommas(values.HEDString1);
assertTrue(isempty(errors));

fprintf(['\nIt should return errors when there is a missing comma' ...
    ' before a group']);
errors = checkcommas(values.HEDString2);
assertFalse(isempty(errors));

fprintf(['\nIt should return errors when there is a missing comma' ...
    ' after a group']);
errors = checkcommas(values.HEDString3);
assertFalse(isempty(errors));