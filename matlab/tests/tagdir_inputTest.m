function tests = tagdir_inputTest
tests = functiontests(localfunctions);
end % tageegTest

function test_valid(testCase)
% Unit test for pop_tagdir_input
fprintf('Testing pop_tagdir_input....REQUIRES USER INPUT\n');
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS THE CANCEL BUTTON\n');
[canceled, baseMap, doSubDirs, hedExtensionsAllowed, ...
    hedExtensionsAnywhere, hedXml, inDir, preserveTagPrefixes, ...
    selectEventFields, useCTagger] = pop_tagdir_input();
testCase.verifyTrue(canceled);
testCase.verifyTrue(isempty(baseMap));
testCase.verifyTrue(doSubDirs);
testCase.verifyTrue(hedExtensionsAllowed);
testCase.verifyFalse(hedExtensionsAnywhere);
testCase.verifyTrue(~isempty(hedXml));
testCase.verifyTrue(isempty(inDir));
testCase.verifyFalse(preserveTagPrefixes);
testCase.verifyTrue(selectEventFields);
testCase.verifyTrue(useCTagger);

fprintf('SET THE DIRECTORY\n');
fprintf('PRESS THE OKAY BUTTON\n');
[canceled, baseMap, doSubDirs, hedExtensionsAllowed, ...
    hedExtensionsAnywhere, hedXml, inDir, preserveTagPrefixes, ...
    selectEventFields, useCTagger] = pop_tagdir_input();
testCase.verifyFalse(canceled);
testCase.verifyTrue(isempty(baseMap));
testCase.verifyTrue(doSubDirs);
testCase.verifyTrue(hedExtensionsAllowed);
testCase.verifyFalse(hedExtensionsAnywhere);
testCase.verifyTrue(~isempty(hedXml));
testCase.verifyTrue(~isempty(inDir));
testCase.verifyFalse(preserveTagPrefixes);
testCase.verifyTrue(selectEventFields);
testCase.verifyTrue(useCTagger);
end