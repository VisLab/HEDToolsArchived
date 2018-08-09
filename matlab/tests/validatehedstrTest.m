function tests = validatehedstrTest
tests = functiontests(localfunctions);
end % validatehedstrTest

function setupOnce(testCase) 
testCase.TestData.EmptyString = '';
testCase.TestData.HEDString1 = ['Event/Label/Test1,' ...
    'Event/Category/Participant response,' ...
    'Event/Description/This is a test,' ...
    '(Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car)'];
testCase.TestData.HEDString2 = ['Event/Label/Test1,' ...
    'Event/Category/Participant response,' ...
    'Event/Description/This is a test (Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car)'];
testCase.TestData.HEDString3 = ['(Participant ~ ' ...
    'Action/Control vehicle/Drive/Collide ~ ' ...
    'Item/Object/Vehicle/Car),' ...
    'Event/Label/Test1,' ...
    'Event/Category/Participant response,'];
end

function testValidateHedStr(testCase)
% Unit test for editmaps
fprintf('\nUnit tests for checkgroupbrackets\n');

fprintf('\nIt should return errors when there is a empty HED string');
errors = validatehedstr(testCase.TestData.EmptyString);
testCase.verifyFalse(isempty(errors));

fprintf('\nIt should return no errors when the HED string is valid');
errors = validatehedstr(testCase.TestData.HEDString1);
testCase.verifyTrue(isempty(errors));

fprintf(['\nIt should return errors when there is a missing comma' ...
    ' before a group']);
errors = validatehedstr(testCase.TestData.HEDString2);
testCase.verifyFalse(isempty(errors));

fprintf(['\nIt should return errors when there is a required tag' ...
    ' missing']);
errors = validatehedstr(testCase.TestData.HEDString3);
testCase.verifyFalse(isempty(errors));
end