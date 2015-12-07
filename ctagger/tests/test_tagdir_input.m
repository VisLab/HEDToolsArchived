function test_suite = test_tagdir_input%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for tagdir_input 
fprintf('Testing tagdir_input....REQUIRES USER INPUT\n');
fprintf('PRESS the CANCEL BUTTON\n');
[inDir, baseMap, doSubDirs, editXml, preservePrefix, ...
    rewriteOption, saveMapFile, selectOption, useGUI, cancelled] =  ...
    tagdir_input();
assertTrue(isempty(inDir));
assertTrue(isempty(baseMap));
assertTrue(doSubDirs);
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(cancelled);
assertFalse(editXml);
assertFalse(preservePrefix);

fprintf('PRESS the OKAY BUTTON\n');
[inDir, baseMap, doSubDirs, editXml, preservePrefix, ...
    rewriteOption, saveMapFile, selectOption, useGUI, cancelled] =  ...
    tagdir_input();
assertTrue(isempty(inDir));
assertTrue(isempty(baseMap));
assertTrue(doSubDirs);
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertFalse(editXml);
assertFalse(preservePrefix);
assertFalse(cancelled);