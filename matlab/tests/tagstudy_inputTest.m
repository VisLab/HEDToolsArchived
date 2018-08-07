function tests = tagstudy_inputTest
tests = functiontests(localfunctions);
end % tagstudy_inputTest

function test_valid(testCase)
% Unit test for pop_tagstudy_input
fprintf('Testing pop_tagstudy_input\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE CANCEL BUTTON\n');
[canceled, baseMap, hedExtensionsAllowed, ...
    hedExtensionsAnywhere, hedXml, preserveTagPrefixes, ...
    selectEventFields, studyFile, useCTagger] = ...
    pop_tagstudy_input();
testCase.verifyTrue(canceled);
testCase.verifyTrue(isempty(baseMap));
testCase.verifyTrue(hedExtensionsAllowed);
testCase.verifyFalse(hedExtensionsAnywhere);
testCase.verifyTrue(~isempty(hedXml));
testCase.verifyFalse(preserveTagPrefixes);
testCase.verifyTrue(selectEventFields);
testCase.verifyTrue(isempty(studyFile));
testCase.verifyTrue(useCTagger);

fprintf('....REQUIRES USER INPUT\n');
fprintf('SET THE STUDY FILE\n');
fprintf('PRESS THE OKAY BUTTON\n');
[canceled, baseMap, hedExtensionsAllowed, ...
    hedExtensionsAnywhere, hedXml, preserveTagPrefixes, ...
    selectEventFields, studyFile, useCTagger] = ...
    pop_tagstudy_input();
testCase.verifyFalse(canceled);
testCase.verifyTrue(isempty(baseMap));
testCase.verifyTrue(hedExtensionsAllowed);
testCase.verifyFalse(hedExtensionsAnywhere);
testCase.verifyTrue(~isempty(hedXml));
testCase.verifyFalse(preserveTagPrefixes);
testCase.verifyTrue(selectEventFields);
testCase.verifyTrue(~isempty(studyFile));
testCase.verifyTrue(useCTagger);

fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS THE OKAY BUTTON AFTER SETTING STUDY FILE AND BASE TAGS');
[canceled, baseMap, hedExtensionsAllowed, ...
    hedExtensionsAnywhere, hedXml, preserveTagPrefixes, ...
    selectEventFields, studyFile, useCTagger] = ...
    pop_tagstudy_input();
testCase.verifyFalse(canceled);
testCase.verifyTrue(~isempty(baseMap));
testCase.verifyTrue(hedExtensionsAllowed);
testCase.verifyFalse(hedExtensionsAnywhere);
testCase.verifyTrue(~isempty(hedXml));
testCase.verifyFalse(preserveTagPrefixes);
testCase.verifyTrue(selectEventFields);
testCase.verifyTrue(~isempty(studyFile));
testCase.verifyTrue(useCTagger);
end