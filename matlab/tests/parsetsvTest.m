function tests = parsetsvTest
tests = functiontests(localfunctions);
end % parsetsvTest

function setupOnce(testCase) 
setup_tests;
Maps = load('HEDMaps.mat');
testCase.TestData.hedMaps = Maps.hedMaps;
testCase.TestData.hasHeader = true;
testCase.TestData.generateWarnings = false;
testCase.TestData.tagColumns = 2;
testCase.TestData.tsv1 = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'sample_tsv1.txt']; 
testCase.TestData.tsv2 = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'sample_tsv4.txt'];
end

function testParseTSV(testCase) 
% Unit test for editmaps
fprintf('\nUnit tests for validateeeg\n');

fprintf('\nIt should return errors when there is a category tag missing');
errors = parsetsv(testCase.TestData.hedMaps, testCase.TestData.tsv1, testCase.TestData.tagColumns, ...
    testCase.TestData.hasHeader, testCase.TestData.generateWarnings);
testCase.verifyFalse(isempty(errors));

fprintf('\nIt should return no errors when the HED string is valid');
errors = parsetsv(testCase.TestData.hedMaps, testCase.TestData.tsv2, testCase.TestData.tagColumns, ...
    testCase.TestData.hasHeader, testCase.TestData.generateWarnings);
testCase.verifyFalse(isempty(errors));
end