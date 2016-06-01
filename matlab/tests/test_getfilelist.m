function test_suite = test_getfilelist %#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidTree(values) %#ok<DEFNU>
% Unit test for getFileList
fprintf('\nUnit tests for getfilelist\n');

fprintf('It should get all the files when no extension is given\n');
bciDir = [values.testroot filesep values.BCI2000dir];
fList1 = getfilelist(bciDir);
assertEqual(length(fList1), 42);

fprintf('It should get all the files when an empty extension is given\n');
fList2 = getfilelist(bciDir);
assertEqual(length(fList2), 42);

fprintf('It should get all the files when a .set extension is given\n');
fList3 = getfilelist(bciDir, '.set');
assertEqual(length(fList3), 42);
fprintf('It should get no files files when a .txt extension is given\n');
fList3 = getfilelist(bciDir, '.txt');
assertEqual(length(fList3), 0);
fprintf(['It should not traverse subdirectories when third argument' ...
    ' false\n']);
fList4 = getfilelist(bciDir, '.set', false);
assertEqual(length(fList4), 0);
fList5 = getfilelist(values.testroot, '.set', false);
assertEqual(length(fList5), 0);
fprintf('It should traverse subdirectories when third argument true\n');
fList6= getfilelist(bciDir, '.set', true);
assertEqual(length(fList6), 42);
fList7 = getfilelist(values.testroot, '.set', true);
assertEqual(length(fList7), 71);