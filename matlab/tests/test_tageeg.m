function test_suite = test_tageeg%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
setup_tests;
a(1) = tagList('square');
a(1).add({'/Attribute/Visual/Color/Green', ...
    '/Item/2D shape/Rectangle/Square'});
a(2) = tagList('rt');
a(2).add('/Event/Category/Participant response');
b(1) = tagList('1');
b(1).add('/Attribute/Object orientation/Rotated/Degrees/3 degrees');
b(2) = tagList('2');
b(2).add('/Attribute/Object orientation/Rotated/Degrees/1.5 degrees');
% Read in the HED schema
latestHed = 'HED.xml';
values.data.etc.tags.xml = fileread(latestHed);
values.xml = fileread(latestHed);
values.map1 = fieldMap('XML', values.xml);
values.map1.addValues('type', a);
values.map1.addValues('position', b);
values.data.etc.tags = values.map1.getStruct();
load([values.testroot filesep values.Otherdir filesep 'EEGEpoch.mat']);
values.EEGEpoch = EEGEpoch;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidValues(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for tageeg\n');
fprintf('It should tag a data set that has a map but no events\n');
fName = 'temp1.mat';
x = values.data;
[y, fMap, excluded] = tageeg(x, 'UseGui', false, 'SaveMapFile', fName, ...
    'SelectFields', false);
assertEqual(length(excluded), 5);
assertTrue(isa(fMap, 'fieldMap'));
assertTrue(isfield(y.etc, 'tags'));
assertTrue(isfield(y.etc.tags, 'xml'));
assertEqual(length(fieldnames(y.etc.tags)), 2);
assertTrue(isfield(y.etc.tags, 'map'));
assertEqual(length(fieldnames(y.etc.tags.map)), 2);
fNew = fieldMap.loadFieldMap(fName);
assertTrue(isa(fNew, 'fieldMap'));
delete(fName);

function testSelectTags(values)  %#ok<DEFNU>
% Unit tests for tag_eeg selecting which fields
fprintf('\n\nIt should allow user to select the types to tag\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('EXCLUDE POSITION\n');
fprintf('TAG TYPE\n');
fprintf('PRESS PROCEED WITHOUT ADDING ANY TAGS TO TYPE\n');
fName = 'temp2.mat';
x = values.data;
[y, fMap, excluded] = tageeg(x, 'UseGui', true, 'SaveMapFile', fName, ...
    'SelectFields', true);
assertTrue(isa(fMap, 'fieldMap'));
assertTrue(isfield(y.etc, 'tags'));
assertTrue(isfield(y.etc.tags, 'xml'));
assertEqual(length(fieldnames(y.etc.tags)), 2);
assertTrue(isfield(y.etc.tags, 'map'));
assertEqual(length(fieldnames(y.etc.tags.map)), 2);
fNew = fieldMap.loadFieldMap(fName);
assertTrue(isa(fNew, 'fieldMap'));
assertEqual(length(excluded), 6);
delete(fName);

function testUseGUI(values)  %#ok<DEFNU>
fprintf('\n\nIt should allow user to use the GUI to tag\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS PROCEED BUTTON FOR POSITON\n');
fprintf('PRESS PROCEED BUTTON FOR TYPE\n');
fName = 'temp2.mat';
x = values.data;
[y, fMap, excluded] = tageeg(x, 'UseGui', true, 'SaveMapFile', fName, ...
    'SelectFields', false);
assertTrue(isa(fMap, 'fieldMap'));
fields = fMap.getFields();
assertEqual(sum(strcmpi(fields, 'type')), 1);
assertEqual(sum(strcmpi(fields, 'position')), 1);
assertTrue(isfield(y.etc, 'tags'));
assertTrue(isfield(y.etc.tags, 'xml'));
assertEqual(length(fieldnames(y.etc.tags)), 2);
assertEqual(length(excluded), 5);
delete(fName);

function testReuse(values)  %#ok<DEFNU>
fprintf('\n\nIt should correctly tag a dataset multiple times\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS PROCEED BUTTON FOR POSITON\n');
fprintf('PRESS PROCEED BUTTON FOR TYPE\n');
fName = 'temp3.mat';
x = values.data;
[y1, fMap, excluded] = tageeg(x, 'UseGui', true, 'SaveMapFile', fName, ...
    'SelectFields', false);
assertTrue(isa(fMap, 'fieldMap'));
fields = fMap.getFields();
assertEqual(sum(strcmpi(fields, 'type')), 1);
assertEqual(sum(strcmpi(fields, 'position')), 1);
assertTrue(isfield(y1.etc, 'tags'));
assertTrue(isfield(y1.etc.tags, 'xml'));
assertEqual(length(fieldnames(y1.etc.tags)), 2);
assertEqual(length(excluded), 5);
fprintf('Now retagging... there should be 2 values for position\n');
fprintf('PRESS PROCEED BUTTON FOR POSITON\n');
fprintf('PRESS PROCEED BUTTON FOR TYPE\n');
fName = 'temp3.mat';
[y2, fMap, excluded] = tageeg(y1, 'UseGui', true, 'SaveMapFile', ...
    fName, 'SelectFields', false); %#ok<ASGLU>
assertEqual(sum(strcmpi(fields, 'type')), 1);
assertEqual(sum(strcmpi(fields, 'position')), 1);
assertTrue(isfield(y2.etc, 'tags'));
assertTrue(isfield(y2.etc.tags, 'xml'));
assertEqual(length(fieldnames(y2.etc.tags)), 2);
assertEqual(length(excluded), 5);
delete(fName);