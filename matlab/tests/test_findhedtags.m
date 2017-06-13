function test_suite = test_findhedtags %#ok<STOUT>
initTestSuite;

function testValidTagSearch() %#ok<DEFNU>
% Unit test for fieldMap adding structure events
fprintf('\n''a/b'' should match ''a/b/c''\n');
hedString = 'a/b/c';
query = 'a/b';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''a/b'' should match ''a/b, Attribute/Intended effect''\n');
hedString = 'a/b, Attribute/Intended effect';
query = 'a/b';
found = findhedtags(hedString, query);
assertFalse(found);

fprintf('\n''a/b, Attribute/Intended effect'' should match ''a/b, Attribute/Intended effect''\n');
hedString = 'a/b, Attribute/Intended effect';
query = 'a/b, Attribute/Intended effect';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''c/d'' should match ''(a/b, Attribute/Intended effect), c/d''\n');
hedString = '(a/b, Attribute/Intended effect), c/d';
query = 'c/d';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''a/b, c/d'' should match ''(a/b, e/f), c/d''\n');
hedString = '(a/b, e/f), c/d';
query = 'a/b, c/d';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''e/f, c/d'' should match ''(a/b, e/f), c/d''\n');
hedString = '(a/b, e/f), c/d';
query = 'e/f, c/d';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''c/d, Attribute/Intended effect'' should match ''(a/b, Attribute/Intended effect), c/d''\n');
hedString = '(a/b, Attribute/Intended effect), c/d';
query = 'c/d, Attribute/Intended effect';
found = findhedtags(hedString, query);
assertFalse(found);

fprintf('\n''c/d, Attribute/Intended effect'' should match ''a/b, Attribute/Intended effect, c/d''\n');
hedString = 'a/b, Attribute/Intended effect, c/d';
query = 'c/d, Attribute/Intended effect';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''a/b, Attribute/X'' should match ''(a/b, Attribute/X), c/d''\n');
hedString = '(a/b, Attribute/X), c/d';
query = 'a/b, Attribute/X';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''c/d, Attribute/X'' should match ''(a/b, Attribute/X), c/d''\n');
hedString = '(a/b, Attribute/X), c/d';
query = 'c/d, Attribute/X';
found = findhedtags(hedString, query);
assertFalse(found);

fprintf('\n''Attribute/X'' should match ''(a/b, Attribute/X), c/d''\n');
hedString = '(a/b, Attribute/X), c/d';
query = 'Attribute/X';
found = findhedtags(hedString, query);
assertFalse(found);

fprintf('\n''Attribute/X'' should match ''(a/b, Attribute/X), c/d''\n');
hedString = '(a/b, Attribute/X), c/d';
query = 'Attribute/X';
found = findhedtags(hedString, query);
assertFalse(found);

fprintf('\n''Attribute/Offset'' should match ''a/b, Attribute/Offset, c/d''\n');
hedString = 'a/b, Attribute/Offset, c/d';
query = 'Attribute/Offset';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''Attribute/X, Attribute/Y'' should match ''(a/b, Attribute/X, Attribute/Y), c/d''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), c/d';
query = 'Attribute/X, Attribute/Y';
found = findhedtags(hedString, query);
assertFalse(found);

fprintf('\n''Attribute/Y'' should match ''(a/b, Attribute/X, Attribute/Y), (c/d, Attribute/Y)''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), (c/d, Attribute/Y)';
query = 'Attribute/Y';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''Attribute/Intended effect'' should match ''(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect)''\n');
hedString = '(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect)';
query = 'Attribute/Intended effect';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''Attribute/Intended effect, Attribute/Offset'' should match ''(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect, Attribute/Offset)''\n');
hedString = '(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect, Attribute/Offset)';
query = 'Attribute/Intended effect, Attribute/Offset';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''a/b, Attribute/Intended effect, Attribute/Offset'' should match ''(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect)''\n');
hedString = '(a/b, Attribute/Intended effect, Attribute/Offset), (c/d,  Attribute/Intended effect)';
query = 'a/b, Attribute/Intended effect, Attribute/Offset';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''a/b, Attribute/X, Attribute/Y'' should match ''(a/b, Attribute/X, Attribute/Y), (c/d,  Attribute/X)''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), (c/d,  Attribute/X)';
query = 'a/b, Attribute/X, Attribute/Y';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''a/b, Attribute/X, Attribute/Y'' should match ''(a/b, Attribute/X, Attribute/Y), (c/d,  Attribute/X)''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), (c/d,  Attribute/X)';
query = 'a/b, Attribute/X, Attribute/Y';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''a/b, Attribute/X'' should match ''(a/b, Attribute/X, Attribute/Y), (a/b/q, c/d,  Attribute/X)''\n');
hedString = '(a/b, Attribute/X, Attribute/Y), (a/b/q, c/d,  Attribute/X)';
query = 'a/b, Attribute/X';
found = findhedtags(hedString, query);
assertTrue(found);

fprintf('\n''a/b, Attribute/X'' (a/b, Attribute/X, Attribute/Y), (a/b/q, c/d,  Attribute/X, Attribute/Intended effect)''\n');
hedString = ' (a/b, Attribute/X, Attribute/Y), (a/b/q, c/d,  Attribute/X, Attribute/Intended effect)';
query = 'a/b, Attribute/X';
found = findhedtags(hedString, query);
assertFalse(found);

fprintf('\n''a/b, Attribute/Intended effect, Attribute/Offset'' ''(a/b, Attribute/Intended effect, Attribute/Offset), (a/b,  Attribute/Intended effect)''\n');
hedString = '(a/b, Attribute/Intended effect, Attribute/Offset), (a/b,  Attribute/Intended effect)';
query = 'a/b, Attribute/Intended effect, Attribute/Offset';
found = findhedtags(hedString, query);
assertTrue(found);
