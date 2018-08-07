function tests = writetagsTest
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
testCase.TestData.map1.addValues('position', s2);
testCase.TestData.data.etc.tags = testCase.TestData.map1.getStruct();
testCase.TestData.data.event = struct('type', {'square', 'rt'}, ...
    'position', {'1', '2'});
testCase.TestData.data1.etc.tags = testCase.TestData.map1.getStruct();
testCase.TestData.data2 = testCase.TestData.data;
load([testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep 'EEGEpoch.mat']);
testCase.TestData.EEGEpoch = EEGEpoch;
end

function testValidValuesSummary(testCase) 
% Unit test for findtags
fprintf('\nUnit tests for writetags\n');
fprintf('It should tag a data set with no events if rewrite is Summary\n');
x1 = testCase.TestData.data1;
dTags1 = findtags(x1);
testCase.verifyTrue(isa(dTags1, 'fieldMap'));
y1 = writetags(x1, dTags1);
testCase.verifyTrue(isfield(y1.etc, 'tags'));
testCase.verifyTrue(isfield(y1.etc.tags, 'xml'));
testCase.verifyEqual(length(fieldnames(y1.etc.tags)), 3);
testCase.verifyTrue(isfield(y1.etc.tags, 'map'));
testCase.verifyTrue(~isempty(y1.etc.tags.map));
testCase.verifyTrue(~isfield(y1, 'event'));
testCase.verifyTrue(~isfield(x1, 'event'));

fprintf(['It should not tag events even if data has an .event field if' ...
    ' Summary\n']);
x2 = testCase.TestData.data2;
dTags2 = findtags(x2);
y2 = writetags(x2, dTags2);
testCase.verifyTrue(isfield(y2.etc, 'tags'));
testCase.verifyTrue(isfield(y2.etc.tags, 'xml'));
testCase.verifyEqual(length(fieldnames(y2.etc.tags)), 3);
testCase.verifyTrue(isfield(y2.etc.tags, 'map'));
testCase.verifyEqual(length(fieldnames(y2.etc.tags.map)), 2);
testCase.verifyTrue(isfield(y2, 'event'));
testCase.verifyTrue(isfield(x2, 'event'))
testCase.verifyTrue(isfield(y2.event, 'usertags'));
testCase.verifyTrue(~isfield(x2.event, 'usertags'));
end

function testValidValuesBoth(testCase) 
fprintf(['It should tag events  if data has an .event field and option' ...
    ' is Both\n']);
x2 = testCase.TestData.data2;
dTags2 = findtags(x2);
y2 = writetags(x2, dTags2);
testCase.verifyTrue(isfield(y2.etc, 'tags'));
testCase.verifyTrue(isfield(y2.etc.tags, 'xml'));
testCase.verifyEqual(length(fieldnames(y2.etc.tags)), 3);
testCase.verifyTrue(isfield(y2.etc.tags, 'map'));
testCase.verifyEqual(length(fieldnames(y2.etc.tags.map)), 2);
testCase.verifyTrue(isfield(y2.event, 'usertags'));
testCase.verifyTrue(~isempty(y2.event(1).usertags));
s = regexpi(y2.event(1).usertags, ',', 'split');
testCase.verifyEqual(length(s), 3);
testCase.verifyTrue(~isempty(y2.event(2).usertags));
testCase.verifyTrue(~isfield(x2.event, 'usertags'));
end