function test_suite = test_tageeg_input%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for cTagger tageeg_input 
fprintf('Testing tageeg_input\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the CANCEL BUTTON\n');
[baseMap,  editXml, preservePrefix, rewriteOption, ...
    saveMapFile, selectOption, useGUI, cancelled] = tageeg_input();
assertTrue(isempty(baseMap));
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);

fprintf('PRESS the OKAY BUTTON\n');
[baseMap,  editXml, preservePrefix, rewriteOption, ...
    saveMapFile, selectOption, useGUI, cancelled] = tageeg_input();
assertTrue(isempty(baseMap));
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertFalse(cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);