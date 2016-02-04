function test_suite = test_findtags%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
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

function testValidValues(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for findtags\n');
fprintf('It should tag a data set that has a map but no events\n');
dTags = findtags(values.data);
assertTrue(isa(dTags, 'fieldMap'));
fields = dTags.getFields();
assertEqual(length(fields), 1);
for k = 1:length(fields)
    assertTrue(isa(dTags.getMap(fields{k}), 'tagMap'));
end

fprintf(['It should return a tag map for an EEG structure that ' ...
    ' hasn''t been tagged\n']);
assertTrue(~isfield(values.EEGEpoch.etc, 'tags'));
dTags = findtags(values.EEGEpoch);
events = dTags.getMaps();
assertEqual(length(events), 2);
assertTrue(~isempty(dTags.getXml()));
fields = dTags.getFields();
assertEqual(length(fields), 2);
assertTrue(strcmpi(fields{1}, 'position'));
assertTrue(strcmpi(fields{2}, 'type'));

fprintf('It should work if EEG doesn''t have .etc field\n');
EEG1 = values.EEGEpoch;
EEG1 = rmfield(EEG1, 'etc');
dTags1 = findtags(EEG1);
events1 = dTags1.getMaps();
assertEqual(length(events1), 2);
assertTrue(~isempty(dTags1.getXml()));
fprintf('It should work if EEG has an empty .etc field\n');
EEG2 = values.EEGEpoch;
EEG2.etc = '';
dTags2 = findtags(EEG2);
events2 = dTags2.getMaps();
assertEqual(length(events2), 2);
assertTrue(~isempty(dTags2.getXml()));
fprintf('It should work if EEG has a non-structure .etc field\n');
EEG3 = values.EEGEpoch;
EEG3.etc = 'This is a test';
dTags3 = findtags(EEG3);
events3 = dTags3.getMaps();
assertEqual(length(events3), 2);
assertTrue(~isempty(dTags3.getXml()));
fprintf('It should work if the EEG has already been tagged\n');
dTags4 = findtags(values.data);
events4 = dTags4.getMaps();
assertEqual(length(events4), 1);
assertTrue(~isempty(dTags4.getXml()));
fields4 = dTags4.getFields();
assertEqual(length(fields4), 1);
assertTrue(strcmpi(fields4{1}, 'type'));

function testMultipleFields(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for findtags with multiple field combinations\n');
fprintf('It should tag when the epoch field is not excluded\n');
assertTrue(~isfield(values.EEGEpoch.etc, 'tags'));
dTags = findtags(values.EEGEpoch, 'ExcludeFields', {'latency', 'urevent'});
values1 = dTags.getMaps();
assertEqual(length(values1), 3);
e1 = values1{1}.getStruct();
assertTrue(strcmpi(e1.field, 'epoch'));
assertEqual(length(e1.values), 80);
e2 = values1{2}.getStruct();
assertTrue(strcmpi(e2.field, 'position'));
assertEqual(length(e2.values), 79);
e3 = values1{3}.getStruct();
assertTrue(strcmpi(e3.field, 'type'));
assertEqual(length(e3.values), 80);

function testEmpty(values)  %#ok<INUSD,DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for findtags for empty argument\n');
fprintf('It should return empty map when input is empty\n');
dTags = findtags('');
assertTrue(isa(dTags, 'fieldMap'));
dFields = dTags.getFields();
assertTrue(isempty(dFields));

function testFindTags(values) %#ok<DEFNU>
% Unit test for fieldMap getTags method
fprintf('\nUnit tests for fieldMap getTags method\n');

fprintf('It should get the right tags for fields that exist \n');
fMap = findtags(values.data);
tags1 = fMap.getTags('type', 'square');
assertEqual(length(tags1{1}), 2);