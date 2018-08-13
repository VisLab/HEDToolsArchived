function tests = editmapsTest
tests = functiontests(localfunctions);
end % editmapsTest

function setupOnce(testCase)
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
end

function testSubmit(testCase)
% Unit test for editmaps
fprintf('\nUnit tests for editmaps normal execution\n');
fprintf('\nIt should not modify the number of tags\n')
fprintf('....REQUIRES USER INPUT\n');
fprintf('DO NOT ADD ANY NEW TAGS\n');
fprintf('PRESS DONE BUTTON\n');
fMap = testCase.TestData.map1;
editmaps(fMap.clone());

fprintf('\nIt should modify the number of tags\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('ADD 2 NEW TAGS TO THE FIRST EVENT\n');
fprintf('PRESS DONE BUTTON\n');
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
events2 = fMap2.getValues('type');
testCase.verifyEqual(length(events2), 2);

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
testCase.verifyEqual(count2, count1 + 2);
fprintf('\nIt should modify the number of tags\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('ADD 3 NEW TAGS TO THE SECOND EVENT\n');
fprintf('PRESS DONE BUTTON\n');
fMap3 = editmaps(fMap2);
events3 = fMap3.getValues('type');
fprintf('\nIt should increase the number of tags by 3\n');
count3 = 0;
for k = 1:length(events3)
    etags = events3{k}.getTags();
    if ischar(etags) && ~isempty(etags)
        count3 = count3 + 1;
    else
        count3 = count3 + length(etags);
    end
end
testCase.verifyEqual(count3, count2 + 3);
end

function testMultipleFields(testCase)  
% Unit test for editmaps
fprintf('\nUnit tests for editmaps multiple fields\n');
fprintf('\nIt should work when the DONE button is pressed\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('DO NOT ADD ANY NEW TAGS\n');
fprintf('PRESS DONE BUTTON\n');
fMap1 = editmaps(testCase.TestData.map2);
testCase.verifyEqual(fMap1, testCase.TestData.map2);
end

function testCancel(testCase)  
% Unit test for editmaps
fprintf('\nUnit tests for editmaps exit\n');
fprintf('\nIt should work when the exit menu option is selected\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('DO NOT ADD ANY NEW TAGS\n');
fprintf('SELECT EXIT OPTION UNDER FILE MENU\n');
fMap1 = editmaps(testCase.TestData.map2);
testCase.verifyEqual(fMap1, testCase.TestData.map2);
end