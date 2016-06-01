function test_suite = test_tageeg_input%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for cTagger tageeg_input 
fprintf('Testing tageeg_input\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS the CANCEL BUTTON\n');
[baseMap, cancelled, editXml, precision, preservePrefix, ...
    saveDataset, saveMapFile, saveMode, selectFields, useGUI] = ...
    tageeg_input();
assertTrue(isempty(baseMap));
assertTrue(strcmpi(precision, 'preserve'));
assertTrue(strcmpi(saveMode, 'two'));
assertTrue(isempty(saveMapFile));
assertTrue(selectFields);
assertTrue(useGUI);
assertTrue(cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);
assertFalse(saveDataset);

fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS the OKAY BUTTON\n');
[baseMap, cancelled, editXml, precision, preservePrefix, ...
    saveDataset, saveMapFile, saveMode, selectFields, useGUI] = ...
    tageeg_input();
assertTrue(isempty(baseMap));
assertTrue(strcmpi(precision, 'preserve'));
assertTrue(strcmpi(saveMode, 'two'));
assertTrue(isempty(saveMapFile));
assertTrue(selectFields);
assertTrue(useGUI);
assertFalse(cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);
assertFalse(saveDataset);