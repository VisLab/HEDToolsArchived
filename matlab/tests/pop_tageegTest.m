function tests = pop_tageegTest
tests = functiontests(localfunctions);
end % pop_tageegTest

function setupOnce(testCase)
setup_tests;
latestHed = 'HED.xml';
testCase.TestData.data.etc.tags.xml = fileread(latestHed);
load([testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep 'EEGEpoch.mat']);
testCase.TestData.EEGEpoch = EEGEpoch;
end

function test_valid(testCase)
% Unit test for pop_tageeg
fprintf('Testing pop_tageeg....REQUIRES USER INPUT\n');
fprintf(['\nIt should not return anything when the cancel button' ...
    ' is pressed\n']);
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE CANCEL BUTTON\n');
[EEG1, com] = pop_tageeg(testCase.TestData.EEGEpoch);
testCase.verifyTrue(~isfield(EEG1.etc, 'tags'));
testCase.verifyTrue(~isfield(EEG1.event(1), 'usertags'));
testCase.verifyTrue(isempty(com));

fprintf('\nIt should return a command when tagged\n');
fprintf('SET TO USE GUI\n');
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE OKAY BUTTON\n');
fprintf('REMOVE ALL FIELDS FROM TAGGING\n');
fprintf('PRESS THE OKAY BUTTON\n');
[EEG1, com] = pop_tageeg(testCase.TestData.EEGEpoch);
testCase.verifyTrue(isfield(EEG1.etc, 'tags'));
testCase.verifyTrue(isfield(EEG1.event(1), 'usertags'));
testCase.verifyTrue(~isempty(com));
end