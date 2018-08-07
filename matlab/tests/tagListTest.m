function tests = tagListTest
tests = functiontests(localfunctions);
end % tagListTest

function setupOnce(testCase)
    testCase.TestData.simple1 = {'/alpha/beta', '/a/b/'};
    testCase.TestData.simple2 = {'/a/b/ ', '/alpha/beta/'};
    testCase.TestData.groupSimple1 = {'/alpha/beta', '~', '/a/b/'};
    testCase.TestData.groupSimple2 = {'~', '/alpha/beta', '~', '/a/b/'};
    testCase.TestData.groupSimple3 = {'/c/d/', '~', '/alpha/beta', '~', '/a/b/'};
    testCase.TestData.groupBad1 = {'~', '/alpha/beta', '~', '/a/b/', '~'};
    testCase.TestData.groupComplex1 = {'/c/d/', '/a/b/', 'd', ' ', '~', ...
        '/Alpha/beta', 'alpha/beta/d ', '~', '/a/b/'};
    testCase.TestData.groupComplex2 = {'/c/d/', 'd', '/a/b/', '~', ...
        'alpha/beta/d ', '/Alpha/beta' '~', '/a/b/'};
    testCase.TestData.dups = {'c', '/c', '/c/d/', 'c/d/e', '/d/e'};
    testCase.TestData.dupGroups = {'c', '/c', '/c/d/', 'c/d/e', '/d/e' '~', ...
        'c', '/c', '/c/d/', 'c/d/e', '/d/e'};
    testCase.TestData.tags1 =  '/alpha/beta, /a/b/';
    testCase.TestData.tags2 =  'c, /c, /c/d/, c/d/e, /d/e';
    testCase.TestData.groups1 = 'a, (/b/c, d), (f), g';
    testCase.TestData.groups2 =  ' ( /b/c, d)';
end

function testValidate(testCase)  %#ok<DEFNU>
% Unit test for tagList static validate method
    fprintf('\nUnit tests for validate static method of tagList\n');
    fprintf(['It should return an error msg if group is empty or not' ...
        ' cellstr\n']);
    msg1 = tagList.validate('');
    testCase.verifyTrue(~isempty(msg1));
    fprintf('It should return no error for simple tag list\n');
    msg2 = tagList.validate(testCase.TestData.simple1);
    testCase.verifyTrue(isempty(msg2));
    fprintf(['It should return no error when group has right number of' ...
        ' tildes\n']);
    msg3 = tagList.validate(testCase.TestData.groupSimple1);
    testCase.verifyTrue(isempty(msg3));
    msg4 = tagList.validate(testCase.TestData.groupSimple2);
    testCase.verifyTrue(isempty(msg4));
    msg5 = tagList.validate(testCase.TestData.groupSimple3);
    testCase.verifyTrue(isempty(msg5));
    fprintf('It should return an error when group has too many titldes\n');
    msg6 = tagList.validate(testCase.TestData.groupBad1);
    testCase.verifyTrue(~isempty(msg6));
end

function testAdd(testCase)  %#ok<DEFNU>
    % Unit test for tagList add method
    fprintf('\nUnit tests for add method of tagList\n');
    fprintf('It should return an error msg if empty or not cellstr\n');
    obj1 = tagList('1111');
    msg1 = obj1.add('');
    testCase.verifyTrue(~isempty(msg1));
    
    fprintf('It should return no error for simple tag\n');
    msg2 = obj1.add('/a/b');
    testCase.verifyTrue(isempty(msg2));
    testCase.verifyEqual(obj1.getCount(), 1);
    fprintf('It should not add the same tag again\n');
    msg3 = obj1.add(' /a/b');
    testCase.verifyTrue(isempty(msg3));
    testCase.verifyEqual(obj1.getCount(), 1);
    msg4 = obj1.add(' /a/b   ');
    testCase.verifyTrue(isempty(msg4));
    testCase.verifyEqual(obj1.getCount(), 1);
    fprintf('It should return no error for simple tag group\n');
    msg5 = obj1.add(testCase.TestData.simple1);
    testCase.verifyTrue(isempty(msg5));
    testCase.verifyEqual(obj1.getCount(), 2);
    fprintf('It should not add the same group tag again\n');
    msg6 = obj1.add(testCase.TestData.simple1);
    testCase.verifyTrue(isempty(msg6));
    testCase.verifyEqual(obj1.getCount(), 2);
    fprintf('It should add tag groups with tildes\n');
    msg7 = obj1.add(testCase.TestData.groupSimple1);
    testCase.verifyTrue(isempty(msg7));
    testCase.verifyEqual(obj1.getCount(), 3);
    msg8 = obj1.add(testCase.TestData.groupSimple2);
    testCase.verifyTrue(isempty(msg8));
    testCase.verifyEqual(obj1.getCount(), 4);
    msg9 = obj1.add(testCase.TestData.groupSimple3);
    testCase.verifyTrue(isempty(msg9));
    testCase.verifyEqual(obj1.getCount(), 5);
    fprintf('It should not add a tag group twice\n');
    msg10 = obj1.add(testCase.TestData.groupSimple3);
    testCase.verifyTrue(isempty(msg10));
    testCase.verifyEqual(obj1.getCount(), 5);
    fprintf('It should not add a bad tag group\n');
    msg11 = obj1.add(testCase.TestData.groupBad1);
    testCase.verifyTrue(~isempty(msg11));
    testCase.verifyEqual(obj1.getCount(), 5);
end
    
    function testUnion(testCase)  %#ok<DEFNU>
    % Unit test for tagList union method
    fprintf('\nUnit tests for union method of tagList\n');
    fprintf('It should do nothing for empty\n');
    obj1 = tagList('1111');
    obj2 = tagList('1111');
    added1 = obj1.union(obj2);
    testCase.verifyEqual(obj1.getCount(), 0);
    testCase.verifyTrue(isempty(added1));

    fprintf('It should not add duplicates\n');
    obj1.addList(testCase.TestData.simple1);
    obj2.addList(testCase.TestData.simple2);
    testCase.verifyEqual(obj1.getCount(), 2);
    testCase.verifyEqual(obj2.getCount(), 2);
    added2 = obj1.union(obj2);
    testCase.verifyEqual(obj1.getCount(), 2);
    testCase.verifyTrue(isempty(added2));
    
    fprintf('It should add group values\n');
    obj1.add(testCase.TestData.groupSimple1);
    obj1.add(testCase.TestData.groupSimple2);
    obj1.add(testCase.TestData.groupSimple3);
    testCase.verifyEqual(obj1.getCount(), 5);
    testCase.verifyEqual(obj2.getCount(), 2);
    obj2.add(testCase.TestData.groupSimple3);
    testCase.verifyEqual(obj2.getCount(), 3);
    added3 = obj1.union(obj2);
    testCase.verifyEqual(length(added3), 0);
    testCase.verifyEqual(obj1.getCount(), 5);

    obj2.add(testCase.TestData.groupComplex2);
    testCase.verifyEqual(obj2.getCount(), 4)
    added4 = obj1.union(obj2);
    testCase.verifyEqual(obj1.getCount(), 6);
    testCase.verifyEqual(length(added4), 1);
    end


    %% Tests of static methods
    function testDeStringify(testCase)  
    % Unit test for tagList DeStringify static method
    fprintf('\nUnit tests for deStringify static method of tagList\n');
    fprintf('It should return an error msg if empty or not a string\n');
    [tlist1, msg1] = tagList.deStringify({});
    testCase.verifyTrue(~isempty(msg1));
    testCase.verifyTrue(isempty(tlist1));
    [tlist2, msg2] = tagList.deStringify({1, 2, 3});
    testCase.verifyTrue(~isempty(msg2));
    testCase.verifyTrue(isempty(tlist2));

    fprintf('It should return no error for a valid string of tags\n');
    [tlist3, msg3] = tagList.deStringify(testCase.TestData.tags1);
    testCase.verifyTrue(isempty(msg3));
    testCase.verifyEqual(length(tlist3), 2);
    fprintf('It should return not remove duplicate tags\n');
    [tlist4, msg4] = tagList.deStringify(testCase.TestData.tags2);
    testCase.verifyTrue(isempty(msg4));
    testCase.verifyEqual(length(tlist4), 5);

    fprintf('It should destringify a stringified group\n');
    [tlist5, msg5] = tagList.deStringify(testCase.TestData.groups1);
    testCase.verifyTrue(isempty(msg5));

    testCase.verifyEqual(length(tlist5), 4);
    testCase.verifyTrue(iscell(tlist5{2}));
    testCase.verifyTrue(iscell(tlist5{3}));
    [tlist6, msg6] = tagList.deStringify(testCase.TestData.groups2);
    testCase.verifyTrue(isempty(msg6));

    testCase.verifyEqual(length(tlist6), 1);
    testCase.verifyTrue(iscell(tlist6{1}));
    end


    function testGetCanonical(testCase)  %#ok<DEFNU>
    % Unit test for tagList static getCanonical method
    fprintf('\nUnit tests for getCanonical static method of tagList\n');
    fprintf('It should return an empty list if empty or not cellstr\n');

    tsorted1 = tagList.getCanonical({});
    testCase.verifyTrue(isempty(tsorted1));
    tsorted2 = tagList.getCanonical([1, 2, 3]);
    testCase.verifyTrue(isempty(tsorted2));

    fprintf(['It should return same list for simple lists in ' ...
        ' different order\n']);
    tsorted3 = tagList.getCanonical(testCase.TestData.simple1);
    testCase.verifyEqual(length(tsorted3), 2);
    tsorted4 = tagList.getCanonical(testCase.TestData.simple2);
    testCase.verifyEqual(length(tsorted4), 2);
    a = tagList.stringify(tsorted3);
    b = tagList.stringify(tsorted4);
    testCase.verifyTrue(strcmpi(a, b));

    fprintf('It should work when there are tildes in the list\n');
    tsorted5 = tagList.getCanonical(testCase.TestData.groupSimple1);
    testCase.verifyEqual(length(tsorted5), 3);
    tsorted6 = tagList.getCanonical(testCase.TestData.groupSimple2);
    testCase.verifyEqual(length(tsorted6), 4);
    tsorted7 = tagList.getCanonical(testCase.TestData.groupSimple3);
    testCase.verifyEqual(length(tsorted7), 5);

    fprintf('It should work for complex lists with tildes\n');
    tsorted8 = tagList.getCanonical(testCase.TestData.groupComplex1);
    testCase.verifyEqual(length(tsorted8), 8);
    tsorted9 = tagList.getCanonical(testCase.TestData.groupComplex2);
    testCase.verifyEqual(length(tsorted9), 8);
    string8 = tagList.stringify(tsorted8);
    string9 = tagList.stringify(tsorted9);
    testCase.verifyTrue(~isempty(string8));
    testCase.verifyTrue(strcmp(string8, string9));
    end

    function testRemove(testCase)  %#ok<DEFNU>
    % Unit test for tagList remove method
    fprintf('\nUnit tests for remove method of tagList\n');
    fprintf('It should do nothing for empty\n');
    obj1 = tagList('1111');
    obj1.remove('');
    testCase.verifyEqual(obj1.getCount(), 0);

    fprintf('It should return remove simple values added\n');
    obj1.addList(testCase.TestData.simple1);
    obj1.addList(testCase.TestData.simple2);
    testCase.verifyEqual(obj1.getCount(), 2);
    obj1.remove('/alpha/beta');
    obj1.remove('/a/b');
    testCase.verifyEqual(obj1.getCount(), 0);

    fprintf('It should return remove group values added\n');
    obj1.add(testCase.TestData.groupSimple1);
    obj1.add(testCase.TestData.groupSimple2);
    obj1.add(testCase.TestData.groupSimple3);
    testCase.verifyEqual(obj1.getCount(), 3);
    obj1.remove(testCase.TestData.groupSimple1)
    obj1.remove(testCase.TestData.groupSimple2)
    testCase.verifyEqual(obj1.getCount(), 1);
    obj1.add(testCase.TestData.groupComplex1);
    obj1.remove(testCase.TestData.groupComplex2);
    end

    function testStringify(testCase)  
    % Unit test for tagList stringifyGroup and deStringifyGroup 
    % static methods
    fprintf(['\nUnit tests for sstringifyGroup and deStringifyGroup' ...
        ' static methods of tagList\n']);
    fprintf('It should return an error msg if empty or not cellstr\n');
    [gstring1, msg1] = tagList.stringify({});
    testCase.verifyTrue(~isempty(msg1));
    testCase.verifyTrue(isempty(gstring1));
    [gstring2, msg2] = tagList.stringify({1, 2, 3});
    testCase.verifyTrue(~isempty(msg2));
    testCase.verifyTrue(isempty(gstring2));

    fprintf('It should return no error for a valid cellstr of tags\n');
    [gstring3, msg3] = tagList.stringify(testCase.TestData.simple1);
    testCase.verifyTrue(isempty(msg3));
    testCase.verifyTrue(~isempty(gstring3));
    fprintf('It should destringify a stringified group\n');
    [cgroup4, msg4] = tagList.deStringify(gstring3);
    testCase.verifyTrue(isempty(msg4));
    [gstring4a, msg4a] = tagList.stringify(cgroup4);
    testCase.verifyTrue(strcmpi(gstring3, gstring4a));
    testCase.verifyTrue(isempty(msg4a));
    end


 
    function testSeparateDuplicates(testCase)
    % Unit test for tagList separateDuplicates static method
    fprintf(['\nUnit tests for separateDuplicates  static method of' ...
        ' tagList\n']);
    fprintf('It should do nothing for empty\n');
    [keep1, duplicates1] = tagList.separateDuplicates({}, false);
    testCase.verifyTrue(isempty(keep1));
    testCase.verifyTrue(isempty(duplicates1));
    [keep2, duplicates2] = tagList.separateDuplicates({}, true);
    testCase.verifyTrue(isempty(keep2));
    testCase.verifyTrue(isempty(duplicates2));

    fprintf('It should separate duplicates when prefix is false\n');
    [keep3, duplicates3] = tagList.separateDuplicates(testCase.TestData.dups, false);
    testCase.verifyEqual(length(keep3), 4);
    testCase.verifyEqual(length(duplicates3), 1);

    fprintf('It should remove duplicates when prefix is true\n');
    [keep4, duplicates4] = tagList.separateDuplicates(testCase.TestData.dups, true);
    testCase.verifyEqual(length(keep4), 2);
    testCase.verifyEqual(length(duplicates4), 3);
    end

function testRemoveGroupDuplicates(testCase)
    % Unit test for tagList removeGroupDuplicates static method
    fprintf(['\nUnit tests for removeGroupDuplicates  static method' ...
        ' of tagList\n']);
    fprintf('It should do nothing for empty\n');
    removed1 = tagList.removeGroupDuplicates({}, false);
    testCase.verifyTrue(isempty(removed1));
    removed2 = tagList.removeGroupDuplicates({}, true);
    testCase.verifyTrue(isempty(removed2));

    fprintf('It should remove duplicates when prefix is false\n');
    removed2 = tagList.removeGroupDuplicates(testCase.TestData.dups, false);
    testCase.verifyEqual(length(removed2), 4);
    removed3 = tagList.removeGroupDuplicates(testCase.TestData.dupGroups, false);
    testCase.verifyEqual(length(removed3), 9);

    fprintf('It should remove duplicates when prefix is true\n');
    removed4 = tagList.removeGroupDuplicates(testCase.TestData.dups, true);
    testCase.verifyEqual(length(removed4), 2);
    removed5 = tagList.removeGroupDuplicates(testCase.TestData.dupGroups, true);
    testCase.verifyEqual(length(removed5), 5);
end