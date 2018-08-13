function tests = findhedeventsTest
tests = functiontests(localfunctions);
end % findhedeventsTest

function testvalidsearches(testCase) 
% Unit test for fieldMap adding structure events
fprintf('\n''a/b'' should match ''a/b/c''\n');
hedString = 'a/b/c';
queryString = 'a/b'; 
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''a/b'' should not match ''a/b, Attribute/Intended effect''\n');
hedString = 'a/b, Attribute/Intended effect';
queryString = 'a/b';
found = findhedevents(hedString, queryString);
testCase.verifyFalse(found);

fprintf('\n''a/b, Attribute/Intended effect'' should match ''a/b, Attribute/Intended effect''\n');
hedString = 'a/b, Attribute/Intended effect';
queryString = 'a/b, Attribute/Intended effect';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''c/d'' should match ''(a/b, Attribute/Intended effect), c/d''\n');
hedString = '(a/b, Attribute/Intended effect), c/d';
queryString = 'c/d';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''a/b, c/d'' should match ''(a/b, e/f), c/d''\n');
hedString = '(a/b, e/f), c/d';
queryString = 'a/b, c/d';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''e/f, c/d'' should match ''(a/b, e/f), c/d''\n');
hedString = '(a/b, e/f), c/d';
queryString = 'e/f, c/d';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''c/d, Attribute/Intended effect'' should not match ''(a/b, Attribute/Intended effect), c/d''\n');
hedString = '(a/b, Attribute/Intended effect), c/d';
queryString = 'c/d, Attribute/Intended effect';
found = findhedevents(hedString, queryString);
testCase.verifyFalse(found);

fprintf('\n''c/d, Attribute/Intended effect'' should match ''a/b, Attribute/Intended effect, c/d''\n');
hedString = 'a/b, Attribute/Intended effect, c/d';
queryString = 'c/d, Attribute/Intended effect';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''a/b, Attribute/X'' should match ''(a/b, Attribute/X), c/d''\n');
hedString = '(a/b, Attribute/X), c/d';
queryString = 'a/b, Attribute/X';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''c/d, Attribute/X'' should not match ''(a/b, Attribute/X), c/d''\n');
hedString = '(a/b, Attribute/X), c/d';
queryString = 'c/d, Attribute/X';
found = findhedevents(hedString, queryString);
testCase.verifyFalse(found);

fprintf('\n''Attribute/X'' should not match ''(a/b, Attribute/X), c/d''\n');
hedString = '(a/b, Attribute/X), c/d';
queryString = 'Attribute/X';
found = findhedevents(hedString, queryString);
testCase.verifyFalse(found);

fprintf('\n''Attribute/X'' should not match ''(a/b, Attribute/X), c/d''\n');
hedString = '(a/b, Attribute/X), c/d';
queryString = 'Attribute/X';
found = findhedevents(hedString, queryString);
testCase.verifyFalse(found);

fprintf('\n''Attribute/Offset'' should match ''a/b, Attribute/Offset, c/d''\n');
hedString = 'a/b, Attribute/Offset, c/d';
queryString = 'Attribute/Offset';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''Attribute/X, Attribute/Y'' should not match ''(a/b, Attribute/X, Attribute/Y), c/d''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), c/d';
queryString = 'Attribute/X, Attribute/Y';
found = findhedevents(hedString, queryString);
testCase.verifyFalse(found);

fprintf('\n''Attribute/Y'' should match ''(a/b, Attribute/X, Attribute/Y), (c/d, Attribute/Y)''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), (c/d, Attribute/Y)';
queryString = 'Attribute/Y';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''Attribute/Intended effect'' should match ''(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect)''\n');
hedString = '(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect)';
queryString = 'Attribute/Intended effect';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''Attribute/Intended effect, Attribute/Offset'' should match ''(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect, Attribute/Offset)''\n');
hedString = '(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect, Attribute/Offset)';
queryString = 'Attribute/Intended effect, Attribute/Offset';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''a/b, Attribute/Intended effect, Attribute/Offset'' should match ''(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect)''\n');
hedString = '(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect)';
queryString = 'a/b, Attribute/Intended effect, Attribute/Offset';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''a/b, Attribute/X, Attribute/Y'' should match ''(a/b, Attribute/X, Attribute/Y), (c/d,  Attribute/X)''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), (c/d,  Attribute/X)';
queryString = 'a/b, Attribute/X, Attribute/Y';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''a/b, Attribute/X, Attribute/Y'' should match ''(a/b, Attribute/X, Attribute/Y), (c/d,  Attribute/X)''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), (c/d,  Attribute/X)';
queryString = 'a/b, Attribute/X, Attribute/Y';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''a/b, Attribute/X'' should match ''(a/b, Attribute/X, Attribute/Y), (a/b/q, c/d,  Attribute/X)''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), (a/b/q, c/d,  Attribute/X)';
queryString = 'a/b, Attribute/X';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''a/b, Attribute/X'' should not match (a/b, Attribute/X, Attribute/Y), (a/b/q, c/d,  Attribute/X, Attribute/Intended effect)''\n');
hedString = ' (a/b, Attribute/X, Attribute/Y), (a/b/q, c/d,  Attribute/X, Attribute/Intended effect)';
queryString = 'a/b, Attribute/X';
found = findhedevents(hedString, queryString);
testCase.verifyFalse(found);

fprintf('\n''a/b, Attribute/Intended effect, Attribute/Offset'' should match ''(a/b, Attribute/Intended effect, Attribute/Offset), (a/b,  Attribute/Intended effect)''\n');
hedString = '(a/b, Attribute/Intended effect, Attribute/Offset), (a/b,  Attribute/Intended effect)';
queryString = 'a/b, Attribute/Intended effect, Attribute/Offset';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''b'' should match ''(a, b, c), (e, Attribute/p)''\n');
hedString = '(a, b, c), (e, Attribute/p)';
queryString = 'b';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''c'' should match ''a, (b~c,d), (e~f,g), Attribute/Onset''\n');
hedString = 'a, (b~c,d), (e~f,g), Attribute/Onset';
queryString = 'c';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''a/b'' should not match ''(a/b, b/c), c/d'' when ''b/c is an exclusive tag\n');
hedString = '(a/b, b/c), c/d';
queryString = 'a/b';
found = findhedevents(hedString, queryString, {'b/c'});
testCase.verifyFalse(found);

fprintf('\n''action/button press'' should match ''(Participant ~ /Action/Button press/Keyboard ~ /Participant/Effect/Body part/Arm/Hand/Finger, Attribute/Object side/Right), Attribute/Action judgment/Correct'' when ''action/button press'' does not begin with a slash\n');
hedString = '(Participant ~ /Action/Button press/Keyboard ~ /Participant/Effect/Body part/Arm/Hand/Finger, Attribute/Object side/Right), Attribute/Action judgment/Correct';
queryString = 'action/button press';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);

fprintf('\n''/action/button press'' should match ''(Participant ~ /Action/Button press/Keyboard ~ /Participant/Effect/Body part/Arm/Hand/Finger, Attribute/Object side/Right), Attribute/Action judgment/Correct'' when ''/action/button press'' begins with a slash\n');
hedString = '(Participant ~ /Action/Button press/Keyboard ~ /Participant/Effect/Body part/Arm/Hand/Finger, Attribute/Object side/Right), Attribute/Action judgment/Correct';
queryString = '/action/button press';
found = findhedevents(hedString, queryString);
testCase.verifyTrue(found);
end