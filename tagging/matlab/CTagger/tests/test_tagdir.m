function test_suite = test_tagdir%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function test_tagdirEmpty(values)  %#ok<INUSD,DEFNU>
% Unit test for tagdir function with empty directory
fprintf('\nBe sure to edit setup_tests.m before running this test\n');
fprintf('\nUnit tests for tagdir for empty directory\n');


fprintf('It should work when there is an invalid directory---WARNING\n');
[eTags2, fPaths2] = tagdir('--34', 'UseGui', false);
assertTrue(isempty(fPaths2));
assertTrue(isempty(eTags2));

function test_tagdirEEGLAB(values)  %#ok<DEFNU>
%Unit test for tagdir for EEGLAB sample data
fprintf('\nUnit tests for tagdir with EEGLAB data\n');

fprintf('It should work for the EEGLAB data without any GUIs\n');
thisDir = [values.testroot filesep values.EEGLAB];
[fMap1, fPaths1] = tagdir(thisDir, 'UseGui', false, 'SelectOption', false);
fields1 = fMap1.getFields();
assertEqual(length(fields1), 2);
types1 = fMap1.getValues('type');
assertEqual(length(types1), 2)
position1 = fMap1.getValues('position');
assertEqual(length(position1), 2)
assertEqual(length(fPaths1), 3);


fprintf(['\n\nIt should work for the EEGLAB data with the only the' ...
    ' options\n']);
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS THE TAG BUTTON FOR POSITION AND EXCLUDE BUTTON FOR TYPE\n');
[fMap2, fPaths2] = tagdir(thisDir, 'UseGui', false, ...
    'Synchronize', false, 'SelectOption', true);
fields2 = fMap2.getFields();
assertEqual(length(fields2), 1);
assertTrue(strcmpi('position', fields2{1}));
types2 = fMap2.getValues('type');
assertTrue(isempty(types2));
position2 = fMap2.getValues('position');
assertEqual(length(position2), 2)
assertEqual(length(fPaths2), 3);

fprintf('\n\nIt should work for the EEGLAB data with just the GUI\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the OKAY BUTTON BOTH TIMES\n');
[fMap3, fPaths3] = tagdir(thisDir, 'UseGui', true, ...
    'SelectOption', false, 'Synchronize', true);
fields3 = fMap3.getFields();
assertEqual(length(fields3), 2);
types3 = fMap3.getValues('type');
assertEqual(length(types3), 2);
position3 = fMap3.getValues('position');
assertEqual(length(position3), 2)
assertEqual(length(fPaths3), 3);

fprintf(['\n\nIt should work for the EEGLAB data with both options' ...
    ' and GUI\n']);
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS THE TAG BUTTON BOTH TIMES\n');
[fMap4, fPaths4] = tagdir(thisDir, 'UseGui', true, ...
    'SelectOption', true, 'Synchronize', false);
fields4 = fMap4.getFields();
assertEqual(length(fields4), 2);
types4 = fMap4.getValues('type');
assertEqual(length(types4), 2);
position4 = fMap4.getValues('position');
assertEqual(length(position4), 2)
assertEqual(length(fPaths4), 3);


function test_tagdirBCI2000(values)  %#ok<DEFNU>
% Unit test for tagdir for BCI2000 data
fprintf('\n\nUnit tests for tagdir for BCI2000\n');

fprintf('It should work for the BCI2000 data with both options and GUI\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS THE TAG BUTTON TWICE\n');
thisDir = [values.testroot filesep values.BCI2000dir];
[fMap1, fPaths1] = tagdir(thisDir, 'UseGui', true, ...
    'SelectOption', true, 'Synchronize', false);
fields1 = fMap1.getFields();
assertEqual(length(fields1), 1);
type1 = fMap1.getValues('type');
assertEqual(length(type1), 17);
assertEqual(length(fPaths1), 42);


function test_tagdirShooter(values)  %#ok<DEFNU>
% Unit test for tagdir with shooter data 
fprintf('\n\nUnit tests for tagdir with shooter data\n');

fprintf('It should work for the shooter data with both options and GUI\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS THE TAG BUTTON FOR ALL FIELDS EXCEPT EXCLUDE TRIAL\n');
[fMap1, fPaths1] = tagdir([values.testroot filesep values.shooterdir], ...
    'UseGui', true, ...
    'SelectOption', true, 'Synchronize', false);
fields1 = fMap1.getFields();
assertEqual(length(fields1), 15);
type1 = fMap1.getValues('type');
assertEqual(length(type1), 46);
assertEqual(length(fPaths1), 16);