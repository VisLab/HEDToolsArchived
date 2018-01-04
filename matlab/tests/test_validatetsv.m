function test_suite = test_validatetsv%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
setup_tests;
values.tagColumns = 2;
values.tsv1 = [values.testroot filesep values.Otherdir filesep ...
    'sample_tsv1.txt']; 
values.tsv2 = [values.testroot filesep values.Otherdir filesep ...
    'sample_tsv4.txt'];

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidateEEG(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for validateeeg\n');

fprintf('\nIt should return errors when there is a category tag missing');
errors = validatetsv(values.tsv1, values.tagColumns);
assertFalse(isempty(errors));

fprintf('\nIt should return no errors when the HED string is valid');
errors = validatetsv(values.tsv2, values.tagColumns);
assertFalse(isempty(errors));