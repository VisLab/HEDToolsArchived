function tests = getfilelistTest
tests = functiontests(localfunctions);
end % getfilelistTest

function setupOnce(testCase) 
setup_tests;
end

function testValidTree(testCase) 
% Unit test for getFileList
fprintf('\nUnit tests for getfilelist\n');

fprintf('It should get all the files when no extension is given\n');
bciDir = [testCase.TestData.testroot filesep testCase.TestData.BCI2000dir];
fList1 = getfilelist(bciDir);
testCase.verifyEqual(length(fList1), 42);

fprintf('It should get all the files when an empty extension is given\n');
fList2 = getfilelist(bciDir);
testCase.verifyEqual(length(fList2), 42);

fprintf('It should get all the files when a .set extension is given\n');
fList3 = getfilelist(bciDir, '.set');
testCase.verifyEqual(length(fList3), 42);
fprintf('It should get no files files when a .txt extension is given\n');
fList3 = getfilelist(bciDir, '.txt');
testCase.verifyEqual(length(fList3), 0);
fprintf(['It should not traverse subdirectories when third argument' ...
    ' false\n']);
fList4 = getfilelist(bciDir, '.set', false);
testCase.verifyEqual(length(fList4), 0);
fList5 = getfilelist(testCase.TestData.testroot, '.set', false);
testCase.verifyEqual(length(fList5), 0);
fprintf('It should traverse subdirectories when third argument true\n');
fList6= getfilelist(bciDir, '.set', true);
testCase.verifyEqual(length(fList6), 42);
fList7 = getfilelist(testCase.TestData.testroot, '.set', true);
testCase.verifyEqual(length(fList7), 71);
end