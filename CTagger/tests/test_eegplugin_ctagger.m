function test_suite = test_eegplugin_ctagger %#ok<STOUT>
% Unit tests for eegplugin_ctagger
initTestSuite;

function test_eegplugin_ctagger_eeglab %#ok<DEFNU>
% Unit test for normal eegplugin_ctagger bring up eeglab
fprintf('\nUnit tests for eegplugin_ctagger bringing up eeglab\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('CLOSE EEGLAB AFTER TRYING OUT THE MENUS (FILE, EDIT, STUDY) \n');
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; %#ok<NASGU,ASGLU>
eeglabfig = gcf;


