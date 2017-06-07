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
