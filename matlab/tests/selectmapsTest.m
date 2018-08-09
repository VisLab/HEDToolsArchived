function tests = selectmapsTest
tests = functiontests(localfunctions);
end % selectmapsTest

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
testCase.TestData.map2 = fieldMap('XML', testCase.TestData.xml);
testCase.TestData.map2.addValues('type', s1);
testCase.TestData.map2.addValues('position', s2);
testCase.TestData.map3 = testCase.TestData.map2.clone();
end


function test_valid(testCase)  
% Unit test for selectmaps with no user interaction
fprintf(['\nUnit tests for selectmaps when no user interaction is' ...
    ' required\n']);
fprintf('It should return an empty map when input map is empty\n');
[fMap4, excluded1] = selectmaps(testCase.TestData.map1);
testCase.verifyTrue(isempty(excluded1));
testCase.verifyTrue(isempty(fMap4.getFields()));

fprintf('It should return all fields when no Fields or selection\n');
[fMap2, excluded2] = selectmaps(testCase.TestData.map2, 'SelectFields', false);
testCase.verifyEqual(length(testCase.TestData.map2.getFields()), length(fMap2.getFields()));
testCase.verifyTrue(isempty(excluded2));

fprintf('It should correctly exclude fields when not all Fields exist\n');
[fMap3, excluded4] = selectmaps(testCase.TestData.map3, 'SelectFields', false);
testCase.verifyEqual(length(fMap3.getFields()), 2);
testCase.verifyEqual(length(excluded4), 0);

fprintf('It should return an empty map when input map is empty\n');
[fMap4, excluded1] = selectmaps(testCase.TestData.map1.clone(), 'SelectFields', true);
testCase.verifyTrue(isempty(excluded1));
testCase.verifyTrue(isempty(fMap4.getFields()));
end

function test_tag_button(testCase)  
% Unit test for selectmaps interactive use with Tag button
fprintf('\n\nUnit tests for selectmaps interactive use with Tag button\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG ALL FIELDS (should show position and type)\n');
fprintf('PRESS OKAY BUTTON\n');
fprintf('It should return all fields when no fields or selection\n');
[fMap2, excluded2] = selectmaps(testCase.TestData.map2, 'SelectFields', true);
testCase.verifyEqual(length(testCase.TestData.map2.getFields()), length(fMap2.getFields()));
testCase.verifyTrue(isempty(excluded2));
end

function test_exclude_button(testCase) 
% Unit test for selectmaps interactive usage with Exclude button
fprintf(['\n\nUnit tests for selectmaps interactive use with' ...
    ' Exclude button\n']);
fprintf('It should exclude the type field from the map\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG POSITION FIELD\n');
fprintf('EXCLUDE TYPE FIELD\n');
fprintf('PRESS OKAY BUTTON\n');
[fMap2, excluded2] = selectmaps(testCase.TestData.map2, 'SelectFields', true);
fields2 = fMap2.getFields();
testCase.verifyEqual(length(fields2), 1);
testCase.verifyTrue(sum(strcmpi(fields2, 'type'))==0);
testCase.verifyTrue(sum(strcmpi(excluded2, 'type')) == 1);
testCase.verifyEqual(length(excluded2), 1);
end

function test_exclude_all(testCase)  
% Unit test for selectmaps interactive usage with Exclude button
fprintf('\n\nUnit tests for selectmaps interactive excluding all\n');
fprintf('\nIt should work when all fields are excluded\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('EXCLUDE ALL FIELDS (should show position and type)\n');
fprintf('PRESS OKAY BUTTON\n');
[fMap3, excluded3] = selectmaps(testCase.TestData.map2, 'SelectFields', true);
fields3 = fMap3.getFields();
testCase.verifyTrue(isempty(fields3));
testCase.verifyEqual(length(excluded3), 2);
end

function test_successive_use(testCase)  
% Unit test for selectmaps interactive usage when same map is reused
fprintf('\n\nUnit tests for selectmaps when map is reused\n');
fprintf('It should exclude the type field from the map\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG POSITION FIELD\n');
fprintf('EXCLUDE TYPE FIELD\n');
fprintf('PRESS OKAY BUTTON\n');
[fMap2, excluded2] = selectmaps(testCase.TestData.map2, 'SelectFields', true);
fields2 = fMap2.getFields();
testCase.verifyEqual(length(fields2), 1);
testCase.verifyTrue(sum(strcmpi(fields2, 'type'))==0);
testCase.verifyTrue(sum(strcmpi(excluded2, 'type')) == 1);
testCase.verifyEqual(length(excluded2), 1);

fprintf('\n\nIt should only have group and type fields when reselected\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('TAG ALL FIELDS (should show position)\n');
fprintf('PRESS OKAY BUTTON\n');
[fMap3, excluded3] = selectmaps(fMap2, 'SelectFields', true);
fields3 = fMap3.getFields();
testCase.verifyEqual(length(fields3), 1);
testCase.verifyTrue(sum(strcmpi(fields3, 'type'))==0);
testCase.verifyEqual(length(excluded3), 0);
end