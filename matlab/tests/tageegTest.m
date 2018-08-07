function tests = tageegTest
tests = functiontests(localfunctions);
end % tageegTest

function setupOnce(testCase)
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
testCase.TestData.data.etc.tags.xml = fileread(latestHed);
testCase.TestData.xml = fileread(latestHed);
testCase.TestData.map1 = fieldMap('XML', testCase.TestData.xml);
testCase.TestData.map1.addValues('type', a);
testCase.TestData.map1.addValues('position', b);
testCase.TestData.data.etc.tags = testCase.TestData.map1.getStruct();
load([testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep 'EEGEpoch.mat']);
testCase.TestData.EEGEpoch = EEGEpoch;
end

function testValidValues(testCase) 
% Unit test for findtags
fprintf('\nUnit tests for tageeg\n');
x = testCase.TestData.data;
[y, fMap] = tageeg(x);
testCase.verifyTrue(isa(fMap, 'fieldMap'));
testCase.verifyTrue(isfield(y.etc, 'tags'));
testCase.verifyTrue(isfield(y.etc.tags, 'xml'));
testCase.verifyEqual(length(fieldnames(y.etc.tags)), 3);
testCase.verifyTrue(isfield(y.etc.tags, 'map'));
testCase.verifyEqual(length(fieldnames(y.etc.tags.map)), 2);
end

function testReuse(testCase) 
fprintf('\n\nIt should correctly tag a dataset multiple times\n');
x = testCase.TestData.data;
[y1, fMap] = tageeg(x);
testCase.verifyTrue(isa(fMap, 'fieldMap'));
fields = fMap.getFields();
testCase.verifyEqual(sum(strcmpi(fields, 'type')), 1);
testCase.verifyEqual(sum(strcmpi(fields, 'position')), 1);
testCase.verifyTrue(isfield(y1.etc, 'tags'));
testCase.verifyTrue(isfield(y1.etc.tags, 'xml'));
testCase.verifyEqual(length(fieldnames(y1.etc.tags)), 3);
fprintf('Now retagging... there should be 2 values for position\n');
fprintf('PRESS PROCEED BUTTON FOR POSITON\n');
fprintf('PRESS PROCEED BUTTON FOR TYPE\n');
[y2, fMap] = tageeg(y1); %#ok<ASGLU>
testCase.verifyEqual(sum(strcmpi(fields, 'type')), 1);
testCase.verifyEqual(sum(strcmpi(fields, 'position')), 1);
testCase.verifyTrue(isfield(y2.etc, 'tags'));
testCase.verifyTrue(isfield(y2.etc.tags, 'xml'));
testCase.verifyEqual(length(fieldnames(y2.etc.tags)), 3);
end