function test_suite = test_tagMap %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Read in the HED schema
values.emptyValue = '';
values.noTagsFile = 'EEGEpoch.mat';
values.oneTagsFile = 'etags.mat';
values.otherTagsFile = 'eTagsOther.mat';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testEmptyOrInvalid(values) %#ok<INUSD,DEFNU>
% Unit test for tagMap constructor empty or invalid
fprintf('\nUnit tests for tagMap empty or invalid JSON\n');

fprintf('It should create a tagMap when no parameters are used\n');
obj1 = tagMap();
assertTrue(isvalid(obj1));
fprintf('---the resulting structure should have the right fields\n');
eStruct1 = obj1.getStruct();
assertTrue(isstruct(eStruct1));
assertEqual(length(fieldnames(eStruct1)), 2);
assertElementsAlmostEqual(sum(isfield(eStruct1, { 'field', 'values'})), 2);
assertTrue(isempty(eStruct1.values));

function testMerge(values) %#ok<DEFNU> need to write tests

function testValues2Json(values) %#ok<INUSD,DEFNU>
fprintf('\nUnit tests for values2Json static method of tagMap\n');
fprintf('It should work if the values cell array is empty\n');
eText = tagMap.values2Json('');
theStruct = tagMap.json2Values(eText);
assertTrue(isempty(theStruct));

function testClone(values) %#ok<DEFNU>
fprintf('\nUnit tests for clone method of tagMap\n');
fprintf('It should correctly clone a tagMap object\n');

function testGetJsonEvents(values) %#ok<DEFNU>
fprintf('\nUnit tests for getJson method of tagMap\n');
fprintf('It should correctly retrieve the values as a  tagMap object\n');

