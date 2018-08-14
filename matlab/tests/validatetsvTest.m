function tests = validatetsvTest
tests = functiontests(localfunctions);
end % validatetsvTest

function setupOnce(testCase)
setup_tests;
testCase.TestData.tagColumns = 2;
testCase.TestData.tsv1 = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'sample_tsv1.txt']; 
testCase.TestData.tsv2 = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'sample_tsv4.txt'];
end

function testValidateTSV(testCase)
% Unit test for editmaps
fprintf('\nUnit tests for validateeeg\n');

fprintf('\nIt should return errors when there is a category tag missing');
errors = validatetsv(testCase.TestData.tsv1, testCase.TestData.tagColumns);
testCase.verifyFalse(isempty(errors));

fprintf('\nIt should return no errors when the HED string is valid');
errors = validatetsv(testCase.TestData.tsv2, testCase.TestData.tagColumns);
testCase.verifyFalse(isempty(errors));
end