function tests = findtagsTest
tests = functiontests(localfunctions);
end % findEEGHedEventsTest

function setupOnce(testCase)
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
testCase.TestData.noTagsFile = 'EEGEpoch.mat';
testCase.TestData.oneTagsFile = 'fMapOne.mat';
testCase.TestData.otherTagsFile = 'fMapTwo.mat';
% testCase.TestData.xmlSchema = fileread('HED Schema 2.026.xsd');
testCase.TestData.data.etc.tags.xml = fileread(latestHed);
testCase.TestData.data.etc.tags = testCase.TestData.map1.getStruct();
end

function testValidValues(testCase)  
% Unit test for findtags
fprintf('\nUnit tests for findtags\n');
fprintf('It should tag a data set that has a map but no events\n');
dTags = findtags(testCase.TestData.data);
testCase.verifyTrue(isa(dTags, 'fieldMap'));
fields = dTags.getFields();
testCase.verifyEqual(length(fields), 1);
for k = 1:length(fields)
    testCase.verifyTrue(isa(dTags.getMap(fields{k}), 'tagMap'));
end

fprintf(['It should return a tag map for an EEG structure that ' ...
    ' hasn''t been tagged\n']);
testCase.verifyTrue(~isfield(testCase.TestData.EEGEpoch.etc, 'tags'));
dTags = findtags(testCase.TestData.EEGEpoch);
events = dTags.getMaps();
testCase.verifyEqual(length(events), 2);
testCase.verifyTrue(~isempty(dTags.getXml()));
fields = dTags.getFields();
testCase.verifyEqual(length(fields), 2);
testCase.verifyTrue(strcmpi(fields{1}, 'position'));
testCase.verifyTrue(strcmpi(fields{2}, 'type'));

fprintf('It should work if EEG doesn''t have .etc field\n');
EEG1 = testCase.TestData.EEGEpoch;
EEG1 = rmfield(EEG1, 'etc');
dTags1 = findtags(EEG1);
events1 = dTags1.getMaps();
testCase.verifyEqual(length(events1), 2);
testCase.verifyTrue(~isempty(dTags1.getXml()));
fprintf('It should work if EEG has an empty .etc field\n');
EEG2 = testCase.TestData.EEGEpoch;
EEG2.etc = '';
dTags2 = findtags(EEG2);
events2 = dTags2.getMaps();
testCase.verifyEqual(length(events2), 2);
testCase.verifyTrue(~isempty(dTags2.getXml()));
fprintf('It should work if EEG has a non-structure .etc field\n');
EEG3 = testCase.TestData.EEGEpoch;
EEG3.etc = 'This is a test';
dTags3 = findtags(EEG3);
events3 = dTags3.getMaps();
testCase.verifyEqual(length(events3), 2);
testCase.verifyTrue(~isempty(dTags3.getXml()));
fprintf('It should work if the EEG has already been tagged\n');
dTags4 = findtags(testCase.TestData.data);
events4 = dTags4.getMaps();
testCase.verifyEqual(length(events4), 1);
testCase.verifyTrue(~isempty(dTags4.getXml()));
fields4 = dTags4.getFields();
testCase.verifyEqual(length(fields4), 1);
testCase.verifyTrue(strcmpi(fields4{1}, 'type'));
end

function testMultipleFields(testCase)  
% Unit test for findtags
fprintf('\nUnit tests for findtags with multiple field combinations\n');
fprintf('It should tag when the epoch field is not excluded\n');
testCase.verifyTrue(~isfield(testCase.TestData.EEGEpoch.etc, 'tags'));
dTags = findtags(testCase.TestData.EEGEpoch, 'EventFieldsToIgnore', {'latency', 'urevent'});
values1 = dTags.getMaps();
testCase.verifyEqual(length(values1), 3);
e1 = values1{1}.getStruct();
testCase.verifyTrue(strcmpi(e1.field, 'epoch'));
testCase.verifyEqual(length(e1.values), 80);
e2 = values1{2}.getStruct();
testCase.verifyTrue(strcmpi(e2.field, 'position'));
testCase.verifyEqual(length(e2.values), 2);
e3 = values1{3}.getStruct();
testCase.verifyTrue(strcmpi(e3.field, 'type'));
testCase.verifyEqual(length(e3.values), 2);
end

function testEmpty(testCase)  
% Unit test for findtags
fprintf('\nUnit tests for findtags for empty argument\n');
fprintf('It should return empty map when input is empty\n');
dTags = findtags('');
testCase.verifyTrue(isa(dTags, 'fieldMap'));
dFields = dTags.getFields();
testCase.verifyTrue(isempty(dFields));
end

function testFindTags(testCase)
% Unit test for fieldMap getTags method
fprintf('\nUnit tests for fieldMap getTags method\n');
fprintf('It should get the right tags for fields that exist \n');
fMap = findtags(testCase.TestData.data);
tags1 = fMap.getTags('type', 'square');
testCase.verifyEqual(length(tags1{1}), 2);
end
