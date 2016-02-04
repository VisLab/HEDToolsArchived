function test_suite = test_pop_tageeg%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
latestHed = 'HED 2.026.xml';
values.data.etc.tags.xml = fileread(latestHed);
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;

function test_valid(values)  %#ok<DEFNU>
% Unit test for pop_tageeg
fprintf('Testing pop_tageeg....REQUIRES USER INPUT\n');
fprintf(['\nIt should not return anything when the cancel button' ...
    ' is pressed\n']);
fprintf('PRESS the CANCEL BUTTON\n');
[EEG1, com] = pop_tageeg(values.EEGEpoch);
assertTrue(~isfield(EEG1.etc, 'tags'));
assertTrue(~isfield(EEG1.event(1), 'usertags'));
assertTrue(isempty(com));

fprintf('\nIt should return a command when tagged\n');
fprintf('SET TO USE GUI\n');
fprintf('SET NOT TO PRESERVE PREFIX\n');
fprintf('PRESS THE OKAY BUTTON\n');
fprintf('EXCLUDE POSITION FIELD\n');
fprintf('TAG TYPE FIELD\n');
fprintf('PRESS the OKAY BUTTON\n');
[EEG1, com] = pop_tageeg(values.EEGEpoch);
assertTrue(isfield(EEG1.etc, 'tags'));
assertTrue(isfield(EEG1.event(1), 'usertags'));
assertTrue(~isempty(com));