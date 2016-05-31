function test_suite = test_replacetags%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
dirPath = which('pop_validate.m');
dirPath = strrep(dirPath, 'pop_validate.m', '');
dataPath = [dirPath 'tests' filesep, 'data'];
values.remapFile = [dataPath filesep 'HED_Remap.txt'];
values.tagFile1 = [dataPath filesep 'Tags1.txt'];
values.tagColumns1 = 2;
values.outputFile1 = [dataPath filesep 'Tags1_output.txt'];
values.tagFile2 = [dataPath filesep 'Tags2.txt'];
values.tagColumns2 = 2;
values.outputFile2 = [dataPath filesep 'Tags2_output.txt'];

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testRequireChildTags(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for replacetags\n');

fprintf(['\nIt should should create a new file when there is no header' ...
    ' in the tag file\n']);
replacetags(values.remapFile, values.tagFile1, values.tagColumns1, ...
    'OutputFile', values.outputFile1);

fprintf(['\nIt should should create a new file but should not replace' ...
    ' any of the tags because they are not valid.\n']);
replacetags(values.remapFile, values.tagFile2, values.tagColumns2, ...
    'OutputFile', values.outputFile2);