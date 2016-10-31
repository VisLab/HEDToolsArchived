function test_suite = test_tagdir_input%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for tagdir_input 
fprintf('Testing tagdir_input....REQUIRES USER INPUT\n');
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE CANCEL BUTTON\n');
[cancelled, inDir, baseMap, doSubDirs, editXml, precision, ...
    preservePrefix, saveDatasets, saveMapFile, saveMode, selectFields, ...
    useGUI] = tagdir_input();
assertTrue(isempty(inDir));
assertTrue(isempty(baseMap));
assertTrue(doSubDirs);
assertTrue(strcmpi(precision, 'preserve'));
assertTrue(strcmpi(saveMode, 'two'));
assertTrue(isempty(saveMapFile));
assertTrue(selectFields);
assertTrue(useGUI);
assertTrue(cancelled);
assertFalse(editXml);
assertFalse(preservePrefix);
assertTrue(saveDatasets);

fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE OKAY BUTTON\n');
[cancelled, inDir, baseMap, doSubDirs, editXml, precision, ...
    preservePrefix, saveDatasets, saveMapFile, saveMode, selectFields, ...
    useGUI] = tagdir_input();
assertTrue(isempty(inDir));
assertTrue(isempty(baseMap));
assertTrue(doSubDirs);
assertTrue(strcmpi(precision, 'preserve'));
assertTrue(strcmpi(saveMode, 'two'));
assertTrue(isempty(saveMapFile));
assertTrue(selectFields);
assertTrue(useGUI);
assertFalse(cancelled);
assertFalse(editXml);
assertFalse(preservePrefix);
assertTrue(saveDatasets);