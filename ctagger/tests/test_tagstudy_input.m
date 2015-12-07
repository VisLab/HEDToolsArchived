function test_suite = test_tagstudy_input%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for tagstudy_input 
fprintf('Testing tagstudy_input\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS THE CANCEL BUTTON\n');
[studyFile, baseMapFile, editXml, preservePrefix, ...
    rewriteOption, saveAll, saveMapFile,  selectOption, useGUI, ...
    cancelled] = tagstudy_input();
assertTrue(isempty(studyFile));
assertTrue(isempty(baseMapFile));
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(saveAll);
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);

fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS THE OKAY BUTTON WITHOUT CHANGING ANYTHING\n');
[studyFile, baseMapFile, editXml, preservePrefix, ...
    rewriteOption, saveAll, saveMapFile,  selectOption, useGUI, ...
    cancelled] = tagstudy_input();
assertTrue(isempty(studyFile));
assertTrue(isempty(baseMapFile));
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(saveAll);
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(~cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);

fprintf('....REQUIRES USER INPUT\n');
fprintf(['PRESS THE OKAY BUTTON AFTER SETTING STUDY FILE, BASE TAGS,' ...
    ' AND SAVE TAGS\n']);
[studyFile, baseMapFile, editXml, preservePrefix, ...
    rewriteOption, saveAll, saveMapFile,  selectOption, useGUI, ...
    cancelled] = tagstudy_input();
assertTrue(~isempty(studyFile));
assertTrue(~isempty(baseMapFile));
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(saveAll);
assertTrue(~isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(~cancelled);
assertFalse(preservePrefix);
assertFalse(editXml);