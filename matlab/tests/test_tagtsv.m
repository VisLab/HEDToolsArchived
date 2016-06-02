function test_suite = test_tagtsv %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
setup_tests;
values.tsvFile1 = [values.testroot filesep values.Otherdir filesep ...
    'sample_tsv1.txt']; %#ok<NODEF>
values.tsvFile2 = [values.testroot filesep values.Otherdir filesep ...
    'sample_tsv2.txt'];
values.tsvFile3 = [values.testroot filesep values.Otherdir filesep ...
    'sample_tsv3.txt'];
values.tsvFile4 = [values.testroot filesep values.Otherdir filesep ...
    'sample_tsv4.txt'];
values.tsvFile5 = [values.testroot filesep values.Otherdir filesep ...
    'sample_tsv5.txt'];
values.tsvFile6 = [values.testroot filesep values.Otherdir filesep ...
    'sample_tsv6.txt'];
values.tsvFile7 = [values.testroot filesep values.Otherdir filesep ...
    'sample_tsv7.txt'];

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testEventLevelTags(values) %#ok<DEFNU>
% Unit test for tagtsv function with event level tags
fprintf('\nUnit tests for tagtsv storing event level tags \n');
fprintf(['It should create a tagMap that contains event level tags', ...
    ' stored in a single column \n']);
tsvTagMap = tagtsv(values.tsvFile1, 'event', 1, 2);
tsvTagMapStruct = getStruct(tsvTagMap);
assertTrue(isfield(tsvTagMapStruct, 'field'));
assertTrue(isfield(tsvTagMapStruct, 'values'));
assertTrue(strcmpi(tsvTagMapStruct.field, 'event'));
assertEqual(length(tsvTagMapStruct.values), 1);
assertTrue(strcmpi(tsvTagMapStruct.values(1).code, '1111'));
assertEqual(length(tsvTagMapStruct.values(1).tags), 3);

fprintf(['It should create a tagMap that contains event level tags', ...
    ' stored in multiple columns \n']);
tsvTagMap = tagtsv(values.tsvFile2, 'event', 1, [2,3,4]);
tsvTagMapStruct = getStruct(tsvTagMap);
assertTrue(isfield(tsvTagMapStruct, 'field'));
assertTrue(isfield(tsvTagMapStruct, 'values'));
assertTrue(strcmpi(tsvTagMapStruct.field, 'event'));
assertEqual(length(tsvTagMapStruct.values), 1);
assertTrue(strcmpi(tsvTagMapStruct.values(1).code, '1111'));
assertEqual(length(tsvTagMapStruct.values(1).tags), 3);

function testMultipleRows(values) %#ok<DEFNU>
fprintf('\nUnit tests for tsv storing multiple events \n');
fprintf('It should create a tagMap that contains multiple events');
tsvTagMap = tagtsv(values.tsvFile3, 'event', 1, [2,3,4]);
tsvTagMapStruct = getStruct(tsvTagMap);
assertTrue(isfield(tsvTagMapStruct, 'field'));
assertTrue(isfield(tsvTagMapStruct, 'values'));
assertTrue(strcmpi(tsvTagMapStruct.field, 'event'));
assertEqual(length(tsvTagMapStruct.values), 2);
assertTrue(strcmpi(tsvTagMapStruct.values(1).code, '1111'));
assertEqual(length(tsvTagMapStruct.values(1).tags), 3);
assertTrue(strcmpi(tsvTagMapStruct.values(2).code, '1112'));
assertEqual(length(tsvTagMapStruct.values(2).tags), 3);

function testEventTagGroups(values) %#ok<DEFNU>
% Unit test for tagtsv function with event level tags
fprintf('\nUnit tests for tagtsv storing event tag groups \n');
fprintf(['It should create a tagMap that contains a event tag group', ...
    ' stored in a single column \n']);
tsvTagMap = tagtsv(values.tsvFile4, 'event', 1, 2);
tsvTagMapStruct = getStruct(tsvTagMap);
assertTrue(isfield(tsvTagMapStruct, 'field'));
assertTrue(isfield(tsvTagMapStruct, 'values'));
assertTrue(strcmpi(tsvTagMapStruct.field, 'event'));
assertEqual(length(tsvTagMapStruct.values), 1);
assertTrue(strcmpi(tsvTagMapStruct.values(1).code, '1111'));
assertTrue(iscellstr(tsvTagMapStruct.values(1).tags{1}));
assertEqual(length(tsvTagMapStruct.values(1).tags{1}), 3);

fprintf(['It should create a tagMap that contains event tag groups', ...
    ' stored in multiple columns \n']);
tsvTagMap = tagtsv(values.tsvFile5, 'event', 1, [2,3]);
tsvTagMapStruct = getStruct(tsvTagMap);
assertTrue(isfield(tsvTagMapStruct, 'field'));
assertTrue(isfield(tsvTagMapStruct, 'values'));
assertTrue(strcmpi(tsvTagMapStruct.field, 'event'));
assertEqual(length(tsvTagMapStruct.values), 1);
assertTrue(strcmpi(tsvTagMapStruct.values(1).code, '1111'));
assertTrue(iscellstr(tsvTagMapStruct.values(1).tags{1}));
assertEqual(length(tsvTagMapStruct.values(1).tags{1}), 3);
assertTrue(iscellstr(tsvTagMapStruct.values(1).tags{2}));
assertEqual(length(tsvTagMapStruct.values(1).tags{2}), 2);

fprintf(['It should create a tagMap that contains a event tag group', ...
    ' stored in a single column with tildes \n']);
tsvTagMap = tagtsv(values.tsvFile6, 'event', 1, 2);
tsvTagMapStruct = getStruct(tsvTagMap);
assertTrue(isfield(tsvTagMapStruct, 'field'));
assertTrue(isfield(tsvTagMapStruct, 'values'));
assertTrue(strcmpi(tsvTagMapStruct.field, 'event'));
assertEqual(length(tsvTagMapStruct.values), 1);
assertTrue(strcmpi(tsvTagMapStruct.values(1).code, '1111'));
assertTrue(iscellstr(tsvTagMapStruct.values(1).tags{1}));
assertEqual(length(tsvTagMapStruct.values(1).tags{1}), 5);

fprintf(['It should create a tagMap that contains a event tag group', ...
    ' stored in a single column with tildes and commas \n']);
tsvTagMap = tagtsv(values.tsvFile7, 'event', 1, 2);
tsvTagMapStruct = getStruct(tsvTagMap);
assertTrue(isfield(tsvTagMapStruct, 'field'));
assertTrue(isfield(tsvTagMapStruct, 'values'));
assertTrue(strcmpi(tsvTagMapStruct.field, 'event'));
assertEqual(length(tsvTagMapStruct.values), 1);
assertTrue(strcmpi(tsvTagMapStruct.values(1).code, '1111'));
assertTrue(iscellstr(tsvTagMapStruct.values(1).tags{1}));
assertEqual(length(tsvTagMapStruct.values(1).tags{1}), 4);
