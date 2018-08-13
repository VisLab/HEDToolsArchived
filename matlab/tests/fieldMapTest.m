function tests = fieldMapTest
tests = functiontests(localfunctions);
end % fieldMapTest

function setupOnce(testCase)
% Read in the HED schema
setup_tests;
latestHed = 'HED.xml';
testCase.TestData.xml = fileread(latestHed);
s1(1) = tagList('square');
s1(1).add({'/Attribute/Visual/Color/Green', ...
    '/Item/2D shape/Rectangle/Square'});
s1(2) = tagList('rt');
s1(2).add('/Event/Category/Participant response');
s2(1) = tagList('1');
s2(1).add('/Attribute/Object orientation/Rotated/Degrees/3 degrees');
s2(2) = tagList('2');
s2(2).add('/Attribute/Object orientation/Rotated/Degrees/1.5 degrees');
testCase.TestData.map1 = fieldMap('XML', testCase.TestData.xml);
testCase.TestData.map1.addValues('type', s1);
testCase.TestData.map2 = fieldMap('XML', testCase.TestData.xml);
testCase.TestData.map2.addValues('position', s2);
load([testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep 'EEGEpoch.mat']);
testCase.TestData.EEGEpoch = EEGEpoch;
testCase.TestData.noTagsFile = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'EEGEpoch.mat'];
testCase.TestData.oneTagsFile = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'fMapOne.mat'];
testCase.TestData.otherTagsFile = [testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep ...
    'fMapTwo.mat'];
testCase.TestData.xmlSchema = fileread('HED.xsd');
testCase.TestData.data.etc.tags.xml = fileread(latestHed);
testCase.TestData.data.etc.tags = testCase.TestData.map1.getStruct();
end

function testAddValue(testCase)
% Unit test for fieldMap adding structure events
fprintf('\nUnit tests for fieldMap adding structure events\n');
fprintf('It should allow adding of a single type\n');
obj1 = fieldMap();
testCase.verifyTrue(isvalid(obj1));
s1(1) = tagList('square');
s1(1).add({'/Attribute/Visual/Color/Green', ...
    '/Item/2D shape/Rectangle/Square'});
obj1.addValues('type', s1);
tags1 = obj1.getTags('type', 'square');
testCase.verifyEqual(length(tags1{1}), 2);
end

function testMerge(testCase)
% Unit test for fieldMap merge method
fprintf('\nUnit tests for fieldMap merge\n');
fprintf('It merge a valid fieldMap object\n');
dTags = fieldMap();
dTags1 = findtags(testCase.TestData.EEGEpoch);
testCase.verifyEqual(length(dTags1.getMaps()), 2);
testCase.verifyEqual(length(dTags.getMaps()), 0);
dTags.merge(dTags1, 'Merge', {}, {});
testCase.verifyEqual(length(dTags.getMaps()), 2);
fprintf('It should exclude the appropriate fields\n');
dTags2 = fieldMap();
dTags2.merge(dTags1, 'Merge', {'position'}, {});
testCase.verifyEqual(length(dTags2.getMaps()), 1);
end

function testLoadFieldMap(testCase)
fprintf('\nUnit tests for loadFieldMap static method of fieldMap\n');
fprintf(['It should return an empty value when file contains no' ...
    ' fieldMap\n']);
bT1 = fieldMap.loadFieldMap(testCase.TestData.noTagsFile);
testCase.verifyTrue(isempty(bT1));
fprintf(['It should return an fieldMap object when only one variable' ...
    ' in file\n']);
bT2 = fieldMap.loadFieldMap(testCase.TestData.oneTagsFile);
testCase.verifyTrue(isa(bT2, 'fieldMap'));
fprintf(['It should return an fieldMap object when it is not first' ...
    ' variable in file\n']);
bT3 = fieldMap.loadFieldMap(testCase.TestData.otherTagsFile);
testCase.verifyTrue(isa(bT3, 'fieldMap'));
end

function testClone(testCase)
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
testCase.verifyTrue(strcmpi (field1, obj1.getField()));

obj2 = obj1.clone();
testCase.verifyTrue(isa(obj2, 'tagMap'));
fprintf('The fields of the two objects should agree\n');
testCase.verifyTrue(strcmpi(obj1.getField(), obj2.getField()));
keys1 = obj1.getCodes();
keys2 = obj2.getCodes();
fprintf('The two objects should have the same number of labels\n');
testCase.verifyEqual(length(keys1), length(keys2));
end

function testSaveFieldMap(testCase)
fprintf('\nUnit tests for saveFieldMap static method of fieldMap\n');
fprintf('It should save a fieldMap object correctly\n');
fMap = fieldMap();
fName = tempname;
fieldMap.saveFieldMap(fName, fMap);
bT2 = fieldMap.loadFieldMap(fName);
testCase.verifyTrue(isa(bT2, 'fieldMap'));
end

function testGetTags(testCase)
% Unit test for fieldMap getTags method
fprintf('\nUnit tests for fieldMap getTags method\n');

fprintf('It should get the right tags for fields that exist \n');
fMap = findtags(testCase.TestData.data);
tags1 = fMap.getTags('type', 'square');
testCase.verifyEqual(length(tags1{1}), 2);
end