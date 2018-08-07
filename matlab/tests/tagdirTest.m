function tests = tagdirTest
tests = functiontests(localfunctions);
end % tagdir_inputTest

function setupOnce(testCase)
setup_tests;
end

function test_tagdirEmpty(testCase)  
% Unit test for tagdir function with empty directory
fprintf('\nBe sure to edit setup_tests.m before running this test\n');
fprintf('\nUnit tests for tagdir for empty directory\n');


fprintf('It should work when there is an invalid directory---WARNING\n');
[eTags2, fPaths2] = tagdir('--34');
testCase.verifyTrue(isempty(fPaths2));
testCase.verifyTrue(isempty(eTags2));
end

function test_tagdirEEGLAB(testCase) 
%Unit test for tagdir for EEGLAB sample data
fprintf('\nUnit tests for tagdir with EEGLAB data\n');

fprintf('It should work for the EEGLAB data without any GUIs\n');
thisDir = [testCase.TestData.testroot filesep testCase.TestData.EEGLAB];
[fMap1, fPaths1] = tagdir(thisDir);
fields1 = fMap1.getFields();
testCase.verifyEqual(length(fields1), 2);
types1 = fMap1.getValues('type');
testCase.verifyEqual(length(types1), 2)
position1 = fMap1.getValues('position');
testCase.verifyEqual(length(position1), 2)
testCase.verifyEqual(length(fPaths1), 3);


fprintf(['\n\nIt should work for the EEGLAB data with the only the' ...
    ' options\n']);
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG POSITION FIELD\n');
fprintf('EXCLUDE TYPE FIELD\n');
fprintf('PRESS the OKAY BUTTON\n');
fprintf('DO NOT ADD ANY NEW TAGS\n');
fprintf('PRESS the PROCEED BUTTON\n');
[fMap2, fPaths2] = tagdir(thisDir);
fields2 = fMap2.getFields();
testCase.verifyEqual(length(fields2), 2);
testCase.verifyTrue(strcmpi('position', fields2{1}));
types2 = fMap2.getValues('type');
testCase.verifyFalse(isempty(types2));
position2 = fMap2.getValues('position');
testCase.verifyEqual(length(position2), 2)
testCase.verifyEqual(length(fPaths2), 3);

fprintf('\n\nIt should work for the EEGLAB data with just the GUI\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG ALL FIELDS\n');
fprintf('PRESS the OKAY BUTTON\n');
fprintf('DO NOT ADD ANY NEW TAGS\n');
fprintf('PRESS the PROCEED BUTTON\n');
[fMap3, fPaths3] = tagdir(thisDir);
fields3 = fMap3.getFields();
testCase.verifyEqual(length(fields3), 2);
types3 = fMap3.getValues('type');
testCase.verifyEqual(length(types3), 2);
position3 = fMap3.getValues('position');
testCase.verifyEqual(length(position3), 2)
testCase.verifyEqual(length(fPaths3), 3);

fprintf(['\n\nIt should work for the EEGLAB data with both options' ...
    ' and GUI\n']);
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG ALL FIELDS\n');
fprintf('PRESS the OKAY BUTTON\n');
fprintf('DO NOT ADD ANY NEW TAGS\n');
fprintf('PRESS the PROCEED BUTTON\n');
[fMap4, fPaths4] = tagdir(thisDir);
fields4 = fMap4.getFields();
testCase.verifyEqual(length(fields4), 2);
types4 = fMap4.getValues('type');
testCase.verifyEqual(length(types4), 2);
position4 = fMap4.getValues('position');
testCase.verifyEqual(length(position4), 2)
testCase.verifyEqual(length(fPaths4), 3);
end

function test_tagdirBCI2000(testCase)  
% Unit test for tagdir for BCI2000 data
fprintf('\n\nUnit tests for tagdir for BCI2000\n');

fprintf('It should work for the BCI2000 data with both options and GUI\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG ALL FIELDS\n');
fprintf('PRESS the OKAY BUTTON\n');
fprintf('DO NOT ADD ANY NEW TAGS\n');
fprintf('PRESS the PROCEED BUTTON\n');
thisDir = [testCase.TestData.testroot filesep testCase.TestData.BCI2000dir];
[fMap1, fPaths1] = tagdir(thisDir);
fields1 = fMap1.getFields();
testCase.verifyEqual(length(fields1), 1);
type1 = fMap1.getValues('type');
testCase.verifyEqual(length(type1), 14);
testCase.verifyEqual(length(fPaths1), 42);
end

function test_tagdirShooter(testCase)  
% Unit test for tagdir with shooter data 
fprintf('\n\nUnit tests for tagdir with shooter data\n');

fprintf('It should work for the shooter data with both options and GUI\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('EXCLUDE TRIAL FIELD\n');
fprintf('TAG ALL OTHER FIELDS\n');
fprintf('PRESS the OKAY BUTTON\n');
fprintf('DO NOT ADD ANY NEW TAGS\n');
fprintf('PRESS the PROCEED BUTTON\n');
[fMap1, fPaths1] = ...
    tagdir([testCase.TestData.testroot filesep testCase.TestData.shooterdir]);
fields1 = fMap1.getFields();
testCase.verifyEqual(length(fields1), 16);
type1 = fMap1.getValues('type');
testCase.verifyEqual(length(type1), 16);
testCase.verifyEqual(length(fPaths1), 16);
end