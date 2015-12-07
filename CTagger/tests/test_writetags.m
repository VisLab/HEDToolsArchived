function test_suite = test_writetags%#ok<STOUT>
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
values.map1.addValues('position', s2);
values.data.etc.tags = values.map1.getStruct();
values.data.event = struct('type', {'square', 'rt'}, ...
    'position', {'1', '2'});
values.data1.etc.tags = values.map1.getStruct();
values.data2 = values.data;
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidValuesSummary(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for writetags\n');
fprintf('It should tag a data set with no events if rewrite is Summary\n');
x1 = values.data1;
dTags1 = findtags(x1);
assertTrue(isa(dTags1, 'fieldMap'));
y1 = writetags(x1, dTags1, 'RewriteOption', 'Summary');
assertTrue(isfield(y1.etc, 'tags'));
assertTrue(isfield(y1.etc.tags, 'xml'));
assertEqual(length(fieldnames(y1.etc.tags)), 2);
assertTrue(isfield(y1.etc.tags, 'map'));
assertTrue(~isempty(y1.etc.tags.map));
assertTrue(~isfield(y1, 'event'));
assertTrue(~isfield(x1, 'event'));

fprintf(['It should not tag events even if data has an .event field if' ...
    ' Summary\n']);
x2 = values.data2;
dTags2 = findtags(x2);
y2 = writetags(x2, dTags2, 'RewriteOption', 'Summary');
assertTrue(isfield(y2.etc, 'tags'));
assertTrue(isfield(y2.etc.tags, 'xml'));
assertEqual(length(fieldnames(y2.etc.tags)), 2);
assertTrue(isfield(y2.etc.tags, 'map'));
assertEqual(length(fieldnames(y2.etc.tags.map)), 2);
assertTrue(isfield(y2, 'event'));
assertTrue(isfield(x2, 'event'))
assertTrue(~isfield(y2.event, 'usertags'));
assertTrue(~isfield(x2.event, 'usertags'));

function testValidValuesBoth(values)  %#ok<DEFNU>
fprintf(['It should tag events  if data has an .event field and option' ...
    ' is Both\n']);
x2 = values.data2;
dTags2 = findtags(x2);
y2 = writetags(x2, dTags2, 'RewriteOption', 'Both');
assertTrue(isfield(y2.etc, 'tags'));
assertTrue(isfield(y2.etc.tags, 'xml'));
assertEqual(length(fieldnames(y2.etc.tags)), 2);
assertTrue(isfield(y2.etc.tags, 'map'));
assertEqual(length(fieldnames(y2.etc.tags.map)), 2);
assertTrue(isfield(y2.event, 'usertags'));
assertTrue(~isempty(y2.event(1).usertags));
s = regexpi(y2.event(1).usertags, ',', 'split');
assertEqual(length(s), 3);
assertTrue(~isempty(y2.event(2).usertags));
assertTrue(~isfield(x2.event, 'usertags'));


