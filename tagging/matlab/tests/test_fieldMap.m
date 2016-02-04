function test_suite = test_fieldMap %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
latestHed = 'HED 2.026.xml';
values.xml = fileread(latestHed);
s1(1) = tagList('square');
s1(1).add({'/Attribute/Visual/Color/Green', ...
    '/Item/2D shape/Rectangle/Square'});
s1(2) = tagList('rt');
s1(2).add('/Event/Category/Participant response');
s2(1) = tagList('1');
s2(1).add('/Attribute/Object orientation/Rotated/Degrees/3 degrees');
s2(2) = tagList('2');
s2(2).add('/Attribute/Object orientation/Rotated/Degrees/1.5 degrees');
values.map1 = fieldMap('XML', values.xml);
values.map1.addValues('type', s1);
values.map2 = fieldMap('XML', values.xml);
values.map2.addValues('position', s2);
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;
values.noTagsFile = 'EEGEpoch.mat';
values.oneTagsFile = 'fMapOne.mat';
values.otherTagsFile = 'fMapTwo.mat';
values.xmlSchema = fileread('HED Schema 2.026.xsd');
values.data.etc.tags.xml = fileread(latestHed);
values.data.etc.tags = values.map1.getStruct();

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testAddValue(values) %#ok<DEFNU>
% Unit test for fieldMap adding structure events
fprintf('\nUnit tests for fieldMap adding structure events\n');
fprintf('It should allow adding of a single type\n');
obj1 = fieldMap();
assertTrue(isvalid(obj1));
s1(1) = tagList('square');
s1(1).add({'/Attribute/Visual/Color/Green', ...
    '/Item/2D shape/Rectangle/Square'});
obj1.addValues('type', s1);
tags1 = obj1.getTags('type', 'square');
assertEqual(length(tags1{1}), 2);

function testMerge(values) %#ok<DEFNU>
% Unit test for fieldMap merge method
fprintf('\nUnit tests for fieldMap merge\n');
fprintf('It merge a valid fieldMap object\n');
dTags = fieldMap();
dTags1 = findtags(values.EEGEpoch);
assertEqual(length(dTags1.getMaps()), 2);
assertEqual(length(dTags.getMaps()), 0);
dTags.merge(dTags1, 'Merge', {}, {});
assertEqual(length(dTags.getMaps()), 2);
fprintf('It should exclude the appropriate fields\n');
dTags2 = fieldMap();
dTags2.merge(dTags1, 'Merge', {'position'}, {});
assertEqual(length(dTags2.getMaps()), 1);

function testLoadFieldMap(values) %#ok<DEFNU>
fprintf('\nUnit tests for loadFieldMap static method of fieldMap\n');
fprintf(['It should return an empty value when file contains no' ...
    ' fieldMap\n']);
bT1 = fieldMap.loadFieldMap(values.noTagsFile);
assertTrue(isempty(bT1));
fprintf(['It should return an fieldMap object when only one variable' ...
    ' in file\n']);
bT2 = fieldMap.loadFieldMap(values.oneTagsFile);
assertTrue(isa(bT2, 'fieldMap'));
fprintf(['It should return an fieldMap object when it is not first' ...
    ' variable in file\n']);
bT3 = fieldMap.loadFieldMap(values.otherTagsFile);
assertTrue(isa(bT3, 'fieldMap'));

function testClone(values) %#ok<DEFNU>
%____________TODO
fprintf('\nUnit tests for clone method of fieldMap\n');
fprintf('It should correctly clone a fieldMap object\n');
field1 = 'type';
events1(1) = tagList('square');
events1(1).add({'/Attribute/Visual/Color/Green', ...
    '/Item/2D shape/Rectangle/Square'});
events1(2) = tagList('rt');
events1(2).add('/Event/Category/Participant response');
obj1 = tagMap();
for k = 1:length(events1)
    obj1.addValue(events1(k));
end
assertTrue(strcmpi (field1, obj1.getField()));

obj2 = obj1.clone();
assertTrue(isa(obj2, 'tagMap'));
fprintf('The fields of the two objects should agree\n');
assertTrue(strcmpi(obj1.getField(), obj2.getField()));
keys1 = obj1.getCodes();
keys2 = obj2.getCodes();
fprintf('The two objects should have the same number of labels\n');
assertEqual(length(keys1), length(keys2));

function testSaveFieldMap(values) %#ok<INUSD,DEFNU>
fprintf('\nUnit tests for saveFieldMap static method of fieldMap\n');
fprintf('It should save a fieldMap object correctly\n');
fMap = fieldMap();
fName = tempname;
fieldMap.saveFieldMap(fName, fMap);
bT2 = fieldMap.loadFieldMap(fName);
assertTrue(isa(bT2, 'fieldMap'));

function testGetTags(values) %#ok<DEFNU>
% Unit test for fieldMap getTags method
fprintf('\nUnit tests for fieldMap getTags method\n');

fprintf('It should get the right tags for fields that exist \n');
fMap = findtags(values.data);
tags1 = fMap.getTags('type', 'square');
assertEqual(length(tags1{1}), 2);

function testMergeXml(values) %#ok<INUSD,DEFNU>
% Unit test for fieldMap mergeXml static method
fprintf('\nUnit tests for mergeXml static method of fieldMap\n');

fprintf('It should merge XML when both tag sets are empty\n');
obj1 = fieldMap();
obj1.mergeXml('');
xml1 = obj1.getXml;
assertTrue(~isempty(xml1));
obj1.mergeXml(xml1);
%assertTrue(strcmpi(strtrim(obj1.getXml()), strtrim(xml1)));

function testValidateXml(values)  %#ok<DEFNU>
% Unit test for fieldMap validateXml static method
fprintf('\nUnit tests for valideXml static method of fieldMap\n');

fprintf('It should validate empty XML\n');
obj1 = fieldMap();
obj1.validateXml('', values.xmlSchema);

fprintf('It should validate non-empty XML\n');
obj1 = fieldMap();
obj1.validateXml(values.xml, values.xmlSchema);

fprintf('It should validate invalid XML and throw an exception\n');
obj1 = fieldMap();
assertExceptionThrown(@() error(obj1.validateXml(...
    '<mismatchingtag1> invalid xml <mismatchingtag2>', ...
    values.xmlSchema)), 'MATLAB:maxlhs');