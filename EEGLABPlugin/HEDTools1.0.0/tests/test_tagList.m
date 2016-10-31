function test_suite = test_tagList %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
    values.simple1 = {'/alpha/beta', '/a/b/'};
    values.simple2 = {'/a/b/ ', '/alpha/beta/'};
    values.groupSimple1 = {'/alpha/beta', '~', '/a/b/'};
    values.groupSimple2 = {'~', '/alpha/beta', '~', '/a/b/'};
    values.groupSimple3 = {'/c/d/', '~', '/alpha/beta', '~', '/a/b/'};
    values.groupBad1 = {'~', '/alpha/beta', '~', '/a/b/', '~'};
    values.groupComplex1 = {'/c/d/', '/a/b/', 'd', ' ', '~', ...
        '/Alpha/beta', 'alpha/beta/d ', '~', '/a/b/'};
    values.groupComplex2 = {'/c/d/', 'd', '/a/b/', '~', ...
        'alpha/beta/d ', '/Alpha/beta' '~', '/a/b/'};
    values.dups = {'c', '/c', '/c/d/', 'c/d/e', '/d/e'};
    values.dupGroups = {'c', '/c', '/c/d/', 'c/d/e', '/d/e' '~', ...
        'c', '/c', '/c/d/', 'c/d/e', '/d/e'};
    values.tags1 =  '/alpha/beta, /a/b/';
    values.tags2 =  'c, /c, /c/d/, c/d/e, /d/e';
    values.groups1 = 'a, (/b/c, d), (f), g';
    values.groups2 =  ' ( /b/c, d)';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidate(values)  %#ok<DEFNU>
% Unit test for tagList static validate method
    fprintf('\nUnit tests for validate static method of tagList\n');
    fprintf(['It should return an error msg if group is empty or not' ...
        ' cellstr\n']);
    msg1 = tagList.validate('');
    assertTrue(~isempty(msg1));
    fprintf('It should return no error for simple tag list\n');
    msg2 = tagList.validate(values.simple1);
    assertTrue(isempty(msg2));
    fprintf(['It should return no error when group has right number of' ...
        ' tildes\n']);
    msg3 = tagList.validate(values.groupSimple1);
    assertTrue(isempty(msg3));
    msg4 = tagList.validate(values.groupSimple2);
    assertTrue(isempty(msg4));
    msg5 = tagList.validate(values.groupSimple3);
    assertTrue(isempty(msg5));
    fprintf('It should return an error when group has too many titldes\n');
    msg6 = tagList.validate(values.groupBad1);
    assertTrue(~isempty(msg6));

function testAdd(values)  %#ok<DEFNU>
    % Unit test for tagList add method
    fprintf('\nUnit tests for add method of tagList\n');
    fprintf('It should return an error msg if empty or not cellstr\n');
    obj1 = tagList('1111');
    msg1 = obj1.add('');
    assertTrue(~isempty(msg1));
    
    fprintf('It should return no error for simple tag\n');
    msg2 = obj1.add('/a/b');
    assertTrue(isempty(msg2));
    assertEqual(obj1.getCount(), 1);
    fprintf('It should not add the same tag again\n');
    msg3 = obj1.add(' /a/b');
    assertTrue(isempty(msg3));
    assertEqual(obj1.getCount(), 1);
    msg4 = obj1.add(' /a/b   ');
    assertTrue(isempty(msg4));
    assertEqual(obj1.getCount(), 1);
    fprintf('It should return no error for simple tag group\n');
    msg5 = obj1.add(values.simple1);
    assertTrue(isempty(msg5));
    assertEqual(obj1.getCount(), 2);
    fprintf('It should not add the same group tag again\n');
    msg6 = obj1.add(values.simple1);
    assertTrue(isempty(msg6));
    assertEqual(obj1.getCount(), 2);
    fprintf('It should add tag groups with tildes\n');
    msg7 = obj1.add(values.groupSimple1);
    assertTrue(isempty(msg7));
    assertEqual(obj1.getCount(), 3);
    msg8 = obj1.add(values.groupSimple2);
    assertTrue(isempty(msg8));
    assertEqual(obj1.getCount(), 4);
    msg9 = obj1.add(values.groupSimple3);
    assertTrue(isempty(msg9));
    assertEqual(obj1.getCount(), 5);
    fprintf('It should not add a tag group twice\n');
    msg10 = obj1.add(values.groupSimple3);
    assertTrue(isempty(msg10));
    assertEqual(obj1.getCount(), 5);
    fprintf('It should not add a bad tag group\n');
    msg11 = obj1.add(values.groupBad1);
    assertTrue(~isempty(msg11));
    assertEqual(obj1.getCount(), 5);
    
    function testUnion(values)  %#ok<DEFNU>
    % Unit test for tagList union method
    fprintf('\nUnit tests for union method of tagList\n');
    fprintf('It should do nothing for empty\n');
    obj1 = tagList('1111');
    obj2 = tagList('1111');
    added1 = obj1.union(obj2);
    assertEqual(obj1.getCount(), 0);
    assertTrue(isempty(added1));

    fprintf('It should not add duplicates\n');
    obj1.addList(values.simple1);
    obj2.addList(values.simple2);
    assertEqual(obj1.getCount(), 2);
    assertEqual(obj2.getCount(), 2);
    added2 = obj1.union(obj2);
    assertEqual(obj1.getCount(), 2);
    assertTrue(isempty(added2));
    
    fprintf('It should add group values\n');
    obj1.add(values.groupSimple1);
    obj1.add(values.groupSimple2);
    obj1.add(values.groupSimple3);
    assertEqual(obj1.getCount(), 5);
    assertEqual(obj2.getCount(), 2);
    obj2.add(values.groupSimple3);
    assertEqual(obj2.getCount(), 3);
    added3 = obj1.union(obj2);
    assertEqual(length(added3), 0);
    assertEqual(obj1.getCount(), 5);

    obj2.add(values.groupComplex2);
    assertEqual(obj2.getCount(), 4)
    added4 = obj1.union(obj2);
    assertEqual(obj1.getCount(), 6);
    assertEqual(length(added4), 1);


    %% Tests of static methods
    function testDeStringify(values)   %#ok<DEFNU>
    % Unit test for tagList DeStringify static method
    fprintf('\nUnit tests for deStringify static method of tagList\n');
    fprintf('It should return an error msg if empty or not a string\n');
    [tlist1, msg1] = tagList.deStringify({});
    assertTrue(~isempty(msg1));
    assertTrue(isempty(tlist1));
    [tlist2, msg2] = tagList.deStringify({1, 2, 3});
    assertTrue(~isempty(msg2));
    assertTrue(isempty(tlist2));

    fprintf('It should return no error for a valid string of tags\n');
    [tlist3, msg3] = tagList.deStringify(values.tags1);
    assertTrue(isempty(msg3));
    assertEqual(length(tlist3), 2);
    fprintf('It should return not remove duplicate tags\n');
    [tlist4, msg4] = tagList.deStringify(values.tags2);
    assertTrue(isempty(msg4));
    assertEqual(length(tlist4), 5);

    fprintf('It should destringify a stringified group\n');
    [tlist5, msg5] = tagList.deStringify(values.groups1);
    assertTrue(isempty(msg5));

    assertEqual(length(tlist5), 4);
    assertTrue(iscell(tlist5{2}));
    assertTrue(iscell(tlist5{3}));
    [tlist6, msg6] = tagList.deStringify(values.groups2);
    assertTrue(isempty(msg6));

    assertEqual(length(tlist6), 1);
    assertTrue(iscell(tlist6{1}));


    function testGetCanonical(values)  %#ok<DEFNU>
    % Unit test for tagList static getCanonical method
    fprintf('\nUnit tests for getCanonical static method of tagList\n');
    fprintf('It should return an empty list if empty or not cellstr\n');

    tsorted1 = tagList.getCanonical({});
    assertTrue(isempty(tsorted1));
    tsorted2 = tagList.getCanonical([1, 2, 3]);
    assertTrue(isempty(tsorted2));

    fprintf(['It should return same list for simple lists in ' ...
        ' different order\n']);
    tsorted3 = tagList.getCanonical(values.simple1);
    assertEqual(length(tsorted3), 2);
    tsorted4 = tagList.getCanonical(values.simple2);
    assertEqual(length(tsorted4), 2);
    a = tagList.stringify(tsorted3);
    b = tagList.stringify(tsorted4);
    assertTrue(strcmpi(a, b));

    fprintf('It should work when there are tildes in the list\n');
    tsorted5 = tagList.getCanonical(values.groupSimple1);
    assertEqual(length(tsorted5), 3);
    tsorted6 = tagList.getCanonical(values.groupSimple2);
    assertEqual(length(tsorted6), 4);
    tsorted7 = tagList.getCanonical(values.groupSimple3);
    assertEqual(length(tsorted7), 5);

    fprintf('It should work for complex lists with tildes\n');
    tsorted8 = tagList.getCanonical(values.groupComplex1);
    assertEqual(length(tsorted8), 8);
    tsorted9 = tagList.getCanonical(values.groupComplex2);
    assertEqual(length(tsorted9), 8);
    string8 = tagList.stringify(tsorted8);
    string9 = tagList.stringify(tsorted9);
    assertTrue(~isempty(string8));
    assertTrue(strcmp(string8, string9));

    function testRemove(values)  %#ok<DEFNU>
    % Unit test for tagList remove method
    fprintf('\nUnit tests for remove method of tagList\n');
    fprintf('It should do nothing for empty\n');
    obj1 = tagList('1111');
    obj1.remove('');
    assertEqual(obj1.getCount(), 0);

    fprintf('It should return remove simple values added\n');
    obj1.addList(values.simple1);
    obj1.addList(values.simple2);
    assertEqual(obj1.getCount(), 2);
    obj1.remove('/alpha/beta');
    obj1.remove('/a/b');
    assertEqual(obj1.getCount(), 0);

    fprintf('It should return remove group values added\n');
    obj1.add(values.groupSimple1);
    obj1.add(values.groupSimple2);
    obj1.add(values.groupSimple3);
    assertEqual(obj1.getCount(), 3);
    obj1.remove(values.groupSimple1)
    obj1.remove(values.groupSimple2)
    assertEqual(obj1.getCount(), 1);
    obj1.add(values.groupComplex1);
    obj1.remove(values.groupComplex2);

    function testStringify(values)   %#ok<DEFNU>
    % Unit test for tagList stringifyGroup and deStringifyGroup 
    % static methods
    fprintf(['\nUnit tests for sstringifyGroup and deStringifyGroup' ...
        ' static methods of tagList\n']);
    fprintf('It should return an error msg if empty or not cellstr\n');
    [gstring1, msg1] = tagList.stringify({});
    assertTrue(~isempty(msg1));
    assertTrue(isempty(gstring1));
    [gstring2, msg2] = tagList.stringify({1, 2, 3});
    assertTrue(~isempty(msg2));
    assertTrue(isempty(gstring2));

    fprintf('It should return no error for a valid cellstr of tags\n');
    [gstring3, msg3] = tagList.stringify(values.simple1);
    assertTrue(isempty(msg3));
    assertTrue(~isempty(gstring3));
    fprintf('It should destringify a stringified group\n');
    [cgroup4, msg4] = tagList.deStringify(gstring3);
    assertTrue(isempty(msg4));
    [gstring4a, msg4a] = tagList.stringify(cgroup4);
    assertTrue(strcmpi(gstring3, gstring4a));
    assertTrue(isempty(msg4a));


 
    function testSeparateDuplicates(values)  %#ok<DEFNU>
    % Unit test for tagList separateDuplicates static method
    fprintf(['\nUnit tests for separateDuplicates  static method of' ...
        ' tagList\n']);
    fprintf('It should do nothing for empty\n');
    [keep1, duplicates1] = tagList.separateDuplicates({}, false);
    assertTrue(isempty(keep1));
    assertTrue(isempty(duplicates1));
    [keep2, duplicates2] = tagList.separateDuplicates({}, true);
    assertTrue(isempty(keep2));
    assertTrue(isempty(duplicates2));

    fprintf('It should separate duplicates when prefix is false\n');
    [keep3, duplicates3] = tagList.separateDuplicates(values.dups, false);
    assertEqual(length(keep3), 5);
    assertEqual(length(duplicates3), 0);

    fprintf('It should remove duplicates when prefix is true\n');
    [keep4, duplicates4] = tagList.separateDuplicates(values.dups, true);
    assertEqual(length(keep4), 3);
    assertEqual(length(duplicates4), 2);

function testRemoveGroupDuplicates(values)  %#ok<DEFNU>
    % Unit test for tagList removeGroupDuplicates static method
    fprintf(['\nUnit tests for removeGroupDuplicates  static method' ...
        ' of tagList\n']);
    fprintf('It should do nothing for empty\n');
    removed1 = tagList.removeGroupDuplicates({}, false);
    assertTrue(isempty(removed1));
    removed2 = tagList.removeGroupDuplicates({}, true);
    assertTrue(isempty(removed2));

    fprintf('It should remove duplicates when prefix is false\n');
    removed2 = tagList.removeGroupDuplicates(values.dups, false);
    assertEqual(length(removed2), 5);
    removed3 = tagList.removeGroupDuplicates(values.dupGroups, false);
    assertEqual(length(removed3), 11);

    fprintf('It should remove duplicates when prefix is true\n');
    removed4 = tagList.removeGroupDuplicates(values.dups, true);
    assertEqual(length(removed4), 3);
    removed5 = tagList.removeGroupDuplicates(values.dupGroups, true);
    assertEqual(length(removed5), 7);

function testValid(values) %#ok<INUSD,DEFNU>
    % Unit test for tagList constructor valid
    fprintf('\nUnit tests for tagList valid constructor\n');