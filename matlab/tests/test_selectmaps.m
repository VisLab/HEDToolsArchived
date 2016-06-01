function test_suite = test_selectmaps%#ok<STOUT>
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
values.map2 = fieldMap('XML', values.xml);
values.map2.addValues('type', s1);
values.map2.addValues('position', s2);
values.map3 = values.map2.clone();

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function test_valid(values)  %#ok<DEFNU>
% Unit test for selectmaps with no user interaction
fprintf(['\nUnit tests for selectmaps when no user interaction is' ...
    ' required\n']);
fprintf('It should return an empty map when input map is empty\n');
[fMap4, excluded1] = selectmaps(values.map1);
assertTrue(isempty(excluded1));
assertTrue(isempty(fMap4.getFields()));

fprintf('It should return all fields when no Fields or selection\n');
[fMap2, excluded2] = selectmaps(values.map2, 'SelectFields', false);
assertEqual(length(values.map2.getFields()), length(fMap2.getFields()));
assertTrue(isempty(excluded2));

fprintf('It should correctly exclude fields when not all Fields exist\n');
[fMap3, excluded4] = selectmaps(values.map3, 'SelectFields', false);
assertEqual(length(fMap3.getFields()), 2);
assertEqual(length(excluded4), 0);

fprintf('It should return an empty map when input map is empty\n');
[fMap4, excluded1] = selectmaps(values.map1.clone(), 'SelectFields', true);
assertTrue(isempty(excluded1));
assertTrue(isempty(fMap4.getFields()));


function test_tag_button(values)  %#ok<DEFNU>
% Unit test for selectmaps interactive use with Tag button
fprintf('\n\nUnit tests for selectmaps interactive use with Tag button\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG ALL FIELDS (should show position and type)\n');
fprintf('PRESS OKAY BUTTON\n');
fprintf('It should return all fields when no fields or selection\n');
[fMap2, excluded2] = selectmaps(values.map2, 'SelectFields', true);
assertEqual(length(values.map2.getFields()), length(fMap2.getFields()));
assertTrue(isempty(excluded2));

function test_exclude_button(values)  %#ok<DEFNU>
% Unit test for selectmaps interactive usage with Exclude button
fprintf(['\n\nUnit tests for selectmaps interactive use with' ...
    ' Exclude button\n']);
fprintf('It should exclude the type field from the map\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG POSITION FIELD\n');
fprintf('EXCLUDE TYPE FIELD\n');
fprintf('PRESS OKAY BUTTON\n');
[fMap2, excluded2] = selectmaps(values.map2, 'SelectFields', true);
fields2 = fMap2.getFields();
assertEqual(length(fields2), 1);
assertTrue(sum(strcmpi(fields2, 'type'))==0);
assertTrue(sum(strcmpi(excluded2, 'type')) == 1);
assertEqual(length(excluded2), 1);

function test_exclude_all(values)  %#ok<DEFNU>
% Unit test for selectmaps interactive usage with Exclude button
fprintf('\n\nUnit tests for selectmaps interactive excluding all\n');
fprintf('\nIt should work when all fields are excluded\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('EXCLUDE ALL FIELDS (should show position and type)\n');
fprintf('PRESS OKAY BUTTON\n');
[fMap3, excluded3] = selectmaps(values.map2, 'SelectFields', true);
fields3 = fMap3.getFields();
assertTrue(isempty(fields3));
assertEqual(length(excluded3), 2);

function test_successive_use(values)  %#ok<DEFNU>
% Unit test for selectmaps interactive usage when same map is reused
fprintf('\n\nUnit tests for selectmaps when map is reused\n');
fprintf('It should exclude the type field from the map\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG POSITION FIELD\n');
fprintf('EXCLUDE TYPE FIELD\n');
fprintf('PRESS OKAY BUTTON\n');
[fMap2, excluded2] = selectmaps(values.map2, 'SelectFields', true);
fields2 = fMap2.getFields();
assertEqual(length(fields2), 1);
assertTrue(sum(strcmpi(fields2, 'type'))==0);
assertTrue(sum(strcmpi(excluded2, 'type')) == 1);
assertEqual(length(excluded2), 1);

fprintf('\n\nIt should only have group and type fields when reselected\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG ALL FIELDS (should show position)\n');
fprintf('PRESS OKAY BUTTON\n');
[fMap3, excluded3] = selectmaps(fMap2, 'SelectFields', true);
fields3 = fMap3.getFields();
assertEqual(length(fields3), 1);
assertTrue(sum(strcmpi(fields3, 'type'))==0);
assertEqual(length(excluded3), 0);