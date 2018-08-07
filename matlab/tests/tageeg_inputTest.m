function tests = tageeg_inputTest
tests = functiontests(localfunctions);
end % tageeg_inputTest

function test_valid(testCase) 
% Unit test for cTagger tageeg_input
fprintf('Testing tageeg_input\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS the CANCEL BUTTON\n');
[canceled, baseMap, hedExtensionsAllowed, ...
    hedExtensionsAnywhere, hedXml, preserveTagPrefixes, ...
    selectEventFields, useCTagger] = ...
    pop_tageeg_input();
testCase.verifyTrue(canceled);
testCase.verifyTrue(isempty(baseMap));
testCase.verifyTrue(hedExtensionsAllowed);
testCase.verifyFalse(hedExtensionsAnywhere);
testCase.verifyTrue(~isempty(hedXml));
testCase.verifyFalse(preserveTagPrefixes);
testCase.verifyTrue(selectEventFields);
testCase.verifyTrue(useCTagger);


fprintf('DO NOT CLICK OR SET ANYTHING\n');
fprintf('PRESS the OKAY BUTTON\n');
[canceled, baseMap, hedExtensionsAllowed, ...
    hedExtensionsAnywhere, hedXml, preserveTagPrefixes, ...
    selectEventFields, useCTagger] = ...
    pop_tageeg_input();
testCase.verifyFalse(canceled);
testCase.verifyTrue(isempty(baseMap));
testCase.verifyTrue(hedExtensionsAllowed);
testCase.verifyFalse(hedExtensionsAnywhere);
testCase.verifyTrue(~isempty(hedXml));
testCase.verifyFalse(preserveTagPrefixes);
testCase.verifyTrue(selectEventFields);
testCase.verifyTrue(useCTagger);
end