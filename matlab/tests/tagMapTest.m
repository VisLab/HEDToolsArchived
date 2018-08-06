function tests = tagMapTest
tests = functiontests(localfunctions);
end % findEEGHedEventsTest


function setupOnce(testCase)
% Read in the HED schema
testCase.TestData.emptyValue = '';
testCase.TestData.noTagsFile = 'EEGEpoch.mat';
testCase.TestData.oneTagsFile = 'etags.mat';
testCase.TestData.otherTagsFile = 'eTagsOther.mat';
end


function testEmptyOrInvalid(testCase)
% Unit test for tagMap constructor empty or invalid
fprintf('\nUnit tests for tagMap empty or invalid JSON\n');
fprintf('It should create a tagMap when no parameters are used\n');
obj1 = tagMap();
testCase.verifyTrue(isvalid(obj1));
fprintf('---the resulting structure should have the right fields\n');
eStruct1 = obj1.getStruct();
testCase.verifyTrue(isstruct(eStruct1));
testCase.verifyEqual(length(fieldnames(eStruct1)), 2);
testCase.verifyEqual(sum(isfield(eStruct1, { 'field', 'values'})), 2);
testCase.verifyTrue(isempty(eStruct1.values));
end

function testValues2Json(testCase)
fprintf('\nUnit tests for values2Json static method of tagMap\n');
fprintf('It should work if the values cell array is empty\n');
eText = tagMap.values2Json('');
theStruct = tagMap.json2Values(eText);
testCase.verifyTrue(isempty(theStruct));
end

function testClone(testCase) 
fprintf('\nUnit tests for clone method of tagMap\n');
fprintf('It should correctly clone a tagMap object\n');
end

function testGetJsonEvents(testCase)
fprintf('\nUnit tests for getJson method of tagMap\n');
fprintf('It should correctly retrieve the values as a  tagMap object\n');
end