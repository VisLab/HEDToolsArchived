function test_suite = test_tagstudy%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
% Function executed after each test
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function test_tagstudyEmpty(values)  %#ok<INUSD,DEFNU>
% Unit test for tagstudy function with empty directory
fprintf('\nUnit tests for tagstudy for empty directory\n');

fprintf('It should throw  are no arguments\n');
f = @() tagstudy('', 'UseGui', false); 
assertAltExceptionThrown(f, ...
    {'MATLAB:InputParser:ArgumentFailedValidation'});


fprintf('It should throw an exception if study file is invalid\n');
f = @() tagstudy('--34', 'UseGui', false); 
assertAltExceptionThrown(f, ...
    {'MATLAB:InputParser:ArgumentFailedValidation'});


function test_tagValidStudy(values)  %#ok<DEFNU>
% Unit test for tagstudy with a valid study directory
fprintf('\nUnit tests for tagstudy valid\n');

fprintf(['It should work for the EEGLAB study with both options and' ...
    ' GUI off\n']);
thisStudy = [values.testroot filesep values.studydir filesep ...
    values.studyname];
[fMap1, fPaths1, excluded1] = tagstudy(thisStudy, 'UseGui', false, ...
    'SelectOption', false);
fields1 = fMap1.getFields();
assertEqual(length(fields1), 5);
type1 = fMap1.getValues('type');
assertEqual(length(type1), 247);
assertEqual(length(fPaths1), 10);
assertEqual(length(excluded1), 5);