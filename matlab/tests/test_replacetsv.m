function test_suite = test_replacetsv%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
setup_tests;
values.replaceFile = [values.testroot filesep values.Otherdir filesep ...
    'Remap1.txt']; %#ok<NODEF>
values.tagFile1 = [values.testroot filesep values.Otherdir filesep ...
    'Tags1.txt'];
values.tagColumns1 = 2;
values.outputFile1 = [values.testroot filesep values.Otherdir filesep ...
    'Tags1_output.txt'];
values.tagFile2 = [values.testroot filesep values.Otherdir filesep ...
    'Tags2.txt'];
values.tagColumns2 = 2;
values.outputFile2 = [values.testroot filesep values.Otherdir filesep ...
    'Tags2_output.txt'];

function teardown(values) %#ok<DEFNU>
% Function executed after each test
delete(values.outputFile1);
delete(values.outputFile2);

function testOptions(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for replacetsv\n');

fprintf(['\nIt should should create a new file when there is no header' ...
    ' in the tag file\n']);
replacetsv(values.replaceFile, values.tagFile1, values.tagColumns1, ...
    'OutputFile', values.outputFile1, 'HasHeader', false);

fprintf(['\nIt should should create a new file but should not replace' ...
    ' any of the tags because they are not valid.\n']);
replacetsv(values.replaceFile, values.tagFile2, values.tagColumns2, ...
    'OutputFile', values.outputFile2);