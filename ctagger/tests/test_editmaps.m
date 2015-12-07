function test_suite = test_editmaps%#ok<STOUT>
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

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testSubmit(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for editmaps normal execution\n');
fprintf('\nIt should work when there is a single field\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS OKAY AFTER NO CHANGES\n');
fMap = values.map1;
fMap1 = editmaps(fMap.clone());
assertFalse(isequal(fMap1, values.map1));

fprintf('\nIt should modify the number of tags\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS OKAY AFTER ADDING 2 TAGS TO A EVENT\n');
fMap2 = editmaps(fMap.clone());
events1 = fMap.getValues('type');
count1 = 0;
for k = 1:length(events1)
    etags = events1{k}.getTags();
    if ischar(etags) && ~isempty(etags)
        count1 = count1 + 1;
    else
        count1 = count1 + length(etags);
    end
end
fprintf('\nIt should not modify the number of type values\n');
events2 = fMap2.getValues('type');
assertEqual(length(events2), 2);

fprintf('\nIt should increase the number of tags by 2\n');
count2 = 0;
for k = 1:length(events2)
    etags = events2{k}.getTags();
    if ischar(etags) && ~isempty(etags)
        count2 = count2 + 1;
    else
        count2 = count2 + length(etags);
    end
end
assertEqual(count2, count1 + 2);
fprintf(['\nIt should not increase the number of type values when' ...
    ' edited again\n']);
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS OKAY AFTER ADDING 3 TAGS TO A EVENT\n');
fMap3 = editmaps(fMap2);
events3 = fMap3.getValues('type');
count3 = 0;
for k = 1:length(events3)
    etags = events3{k}.getTags();
    if ischar(etags) && ~isempty(etags)
        count3 = count3 + 1;
    else
        count3 = count3 + length(etags);
    end
end
assertEqual(count3, count2 + 3);

function testMultipleFields(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for editmaps multiple fields\n');
fprintf('\nIt should work when the okay button is pressed\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS OKAY BUTTON WITH NO CHANGES\n');
fMap1 = editmaps(values.map2);
assertEqual(fMap1, values.map2);

function testCancel(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for editmaps cancel\n');
fprintf('\nIt should work when the exit button is pressed\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS EXIT BUTTON\n');
fMap1 = editmaps(values.map2);
assertEqual(fMap1, values.map2);