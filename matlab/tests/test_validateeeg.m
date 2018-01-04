function test_suite = test_validateeeg%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.EEG1.event(1).usertags = '';
values.EEG2.event(1).usertags = ['Event/Label/Test1,' ...
    'Event/Category/Participant response,' ...
    'Event/Description/This is a test,' ...
    '(Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car)'];
values.EEG3.event(1).usertags = ['Event/Label/Test1,' ...
    'Event/Category/Participant response,' ...
    'Event/Description/This is a test (Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car)'];
values.EEG4.event(1).usertags = ['(Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car),' ...
    'Event/Label/Test1,' ...
    'Event/Category/Participant response,'];

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testCheckGroupBrackets(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for checkgroupbrackets\n');

fprintf('\nIt should return no errors when there is a empty HED string');
errors = validateeeg(values.EEG1);
assertTrue(isempty(errors));

fprintf('\nIt should return no errors when the HED string is valid');
errors = validateeeg(values.EEG2);
assertTrue(isempty(errors));

fprintf(['\nIt should return errors when there is a missing comma' ...
    ' before a group']);
errors = validateeeg(values.EEG3);
assertFalse(isempty(errors));

fprintf(['\nIt should return errors when there is a required tag' ...
    ' missing']);
errors = validateeeg(values.EEG4);
assertFalse(isempty(errors));