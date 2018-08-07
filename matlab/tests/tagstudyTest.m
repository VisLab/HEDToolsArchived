function tests = tagstudyTest
tests = functiontests(localfunctions);
end % tagstudyTest

function setupOnce(testCase)
setup_tests;
end

function test_tagstudyEmpty(testCase)
% Unit test for tagstudy function with empty directory
fprintf('\nUnit tests for tagstudy for empty directory\n');

fprintf('It should throw exception when there are no arguments\n');
f = @() tagstudy('');
testCase.verifyError(f, 'MATLAB:InputParser:ArgumentFailedValidation');


fprintf('It should throw an exception if study file is invalid\n');
f = @() tagstudy('--34');
testCase.verifyError(f, 'MATLAB:InputParser:ArgumentFailedValidation');
end

function test_tagValidStudy(testCase)  
% Unit test for tagstudy with a valid study directory
fprintf('\nUnit tests for tagstudy valid\n');

fprintf(['It should work for the EEGLAB study with both options and' ...
    ' GUI off\n']);
thisStudy = [testCase.TestData.testroot filesep testCase.TestData.studydir filesep ...
    testCase.TestData.studyname];
[fMap1, fPaths1] = tagstudy(thisStudy);
fields1 = fMap1.getFields();
testCase.verifyEqual(length(fields1), 5);
type1 = fMap1.getValues('type');
testCase.verifyEqual(length(type1), 11);
testCase.verifyEqual(length(fPaths1), 10);
end