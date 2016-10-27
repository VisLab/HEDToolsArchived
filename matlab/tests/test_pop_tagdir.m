function test_suite = test_pop_tagdir%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for cTagger tageeg_input 
fprintf('Testing pop_tagdir....REQUIRES USER INPUT\n');
fprintf(['\nIt should not return anything when the cancel button' ...
    ' is pressed\n']);
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE CANCEL BUTTON\n');
[dTags, fPaths, com] = pop_tagdir();
assertTrue(isempty(dTags));
assertTrue(isempty(fPaths));
assertTrue(isempty(com));

fprintf(['\nIt should return directory and paths when okay button' ...
    ' is pressed\n']);
fprintf(['SET DIRECTORY PATH TO DIRECTORY CONTAINING .SET FILES TO' ...
    ' BE TAGGED\n']);
fprintf('UNCLICK SAVE TO DIRECTORY DATASET FILES\n');
fprintf('PRESS THE OKAY BUTTON\n');
fprintf('EXCLUDE ALL FIELDS\n');
fprintf('PRESS THE OKAY BUTTON\n');
[dTags, fPaths, com] = pop_tagdir();
assertTrue(~isempty(dTags));
assertTrue(~isempty(fPaths));
assertTrue(~isempty(com));