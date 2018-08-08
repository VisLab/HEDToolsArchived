function tests = replacetsvTest
tests = functiontests(localfunctions);
end % replacetsvTest

function setupOnce(testCase)
% Read in the HED schema
setup_tests;
testCase.TestData.replaceFile = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'Remap1.txt'];
testCase.TestData.tagFile1 = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'Tags1.txt'];
testCase.TestData.tagColumns1 = 2;
testCase.TestData.outputFile1 = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'Tags1_output.txt'];
testCase.TestData.tagFile2 = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'Tags2.txt'];
testCase.TestData.tagColumns2 = 2;
testCase.TestData.outputFile2 = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'Tags2_output.txt'];
end

function teardown(testCase)
% Function executed after each test
delete(testCase.TestData.outputFile1);
delete(testCase.TestData.outputFile2);
end

function testOptions(testCase)  
% Unit test for editmaps
fprintf('\nUnit tests for replacetsv\n');

fprintf(['\nIt should should create a new file when there is no header' ...
    ' in the tag file\n']);
replacetsv(testCase.TestData.replaceFile, testCase.TestData.tagFile1, testCase.TestData.tagColumns1, ...
    'OutputFile', testCase.TestData.outputFile1, 'HasHeader', false);

fprintf(['\nIt should should create a new file but should not replace' ...
    ' any of the tags because they are not valid.\n']);
replacetsv(testCase.TestData.replaceFile, testCase.TestData.tagFile2, testCase.TestData.tagColumns2, ...
    'OutputFile', testCase.TestData.outputFile2);
end