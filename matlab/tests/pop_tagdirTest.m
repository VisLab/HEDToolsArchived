function tests = pop_tagdirTest
tests = functiontests(localfunctions);
end % pop_tagdirTest

function test_valid(testCase)
% Unit test for cTagger tageeg_input 
fprintf('Testing pop_tagdir....REQUIRES USER INPUT\n');
fprintf(['\nIt should not return anything when the cancel button' ...
    ' is pressed\n']);
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE CANCEL BUTTON\n');
[dTags, fPaths, com] = pop_tagdir();
testCase.verifyTrue(isempty(dTags));
testCase.verifyTrue(isempty(fPaths));
testCase.verifyTrue(isempty(com));

fprintf(['\nIt should return directory and paths when okay button' ...
    ' is pressed\n']);
fprintf(['SET DIRECTORY PATH TO DIRECTORY CONTAINING .SET FILES TO' ...
    ' BE TAGGED\n']);
fprintf('PRESS THE OKAY BUTTON\n');
fprintf('REMOVE ALL FIELDS FROM TAGGING\n');
fprintf('PRESS THE OKAY BUTTON\n');
[dTags, fPaths, com] = pop_tagdir();
testCase.verifyTrue(~isempty(dTags));
testCase.verifyTrue(~isempty(fPaths));
testCase.verifyTrue(~isempty(com));
end