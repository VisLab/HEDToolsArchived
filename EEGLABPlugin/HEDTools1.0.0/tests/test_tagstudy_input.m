function test_suite = test_tagstudy_input%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for tagstudy_input 
fprintf('Testing tagstudy_input\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE CANCEL BUTTON\n');
[cancelled, baseMap, editXml, precision, preservePrefix, ...
    saveDatasets, saveMapFile, saveMode, selectOption, studyFile, ...
    useGUI] = tagstudy_input();
assertTrue(isempty(studyFile));
assertTrue(isempty(baseMap));
assertTrue(strcmpi(precision, 'preserve'));
assertTrue(strcmpi(saveMode, 'two'));
assertTrue(saveDatasets);
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);

fprintf('....REQUIRES USER INPUT\n');
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE OKAY BUTTON\n');
[cancelled, baseMap, editXml, precision, preservePrefix, ...
    saveDatasets, saveMapFile, saveMode, selectOption, studyFile, ...
    useGUI] = tagstudy_input();
assertTrue(isempty(studyFile));
assertTrue(isempty(baseMap));
assertTrue(strcmpi(precision, 'preserve'));
assertTrue(strcmpi(saveMode, 'two'));
assertTrue(saveDatasets);
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertFalse(cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);

fprintf('....REQUIRES USER INPUT\n');
fprintf(['PRESS THE OKAY BUTTON AFTER SETTING STUDY FILE, BASE TAGS,' ...
    ' AND SAVE TAGS\n']);
[cancelled, baseMap, editXml, precision, preservePrefix, ...
    saveDatasets, saveMapFile, saveMode, selectOption, studyFile, ...
    useGUI] = tagstudy_input();
assertTrue(~isempty(studyFile));
assertTrue(~isempty(baseMap));
assertTrue(strcmpi(precision, 'preserve'));
assertTrue(strcmpi(saveMode, 'two'));
assertTrue(saveDatasets);
assertTrue(~isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertFalse(cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);