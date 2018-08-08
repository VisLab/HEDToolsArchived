function tests = getutypesTest
tests = functiontests(localfunctions);
end % getutypesTest

function setupOnce(testCase)
setup_tests;
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('hedXML', '', 'events', 'def');
tags = {'/Sensory presentation/Taste', ...
    '/Item/Object/Person/Pedestrian', ...
    '/Item/Object/Person/Mother-child'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.events = sE;
eJSON1 = savejson('', eStruct);
testCase.TestData.eStruct1 = eStruct;
testCase.TestData.eJSON1 = eJSON1;
load([testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep 'EEGEpoch.mat']);
testCase.TestData.EEGEpoch = EEGEpoch;
load([testCase.TestData.testroot filesep testCase.TestData.Otherdir filesep 'EEGShoot.mat']);
testCase.TestData.EEGShoot = EEGShoot;
end

function testValidValues(testCase)
% Unit test for getutypes
fprintf('\nUnit tests for findtags\n');
fprintf('It should find values for an EEG structure\n');
tValues = getutypes(testCase.TestData.EEGEpoch.event, 'type');
testCase.verifyEqual(length(tValues), 2);
tValues = getutypes(testCase.TestData.EEGEpoch.urevent, 'type');
testCase.verifyEqual(length(tValues), 2);
testCase.verifyTrue(sum(strcmpi('RT', tValues)) > 0);
tValues = getutypes(testCase.TestData.EEGEpoch.event, 'position');
testCase.verifyEqual(length(tValues), 2);
fprintf('It should return empty when the fields have no values\n');
x = struct('type', {'', '', ''});
testCase.verifyEqual(length(x), 3);
tValues = getutypes(x, 'type');
testCase.verifyEqual(length(tValues), 0);
testCase.verifyTrue(isempty(tValues));
fprintf('It should return appropriate values for arbitrary fields\n');
xfields = fieldnames(testCase.TestData.EEGShoot.event);
for k = 1:length(xfields)
    tValues = getutypes(testCase.TestData.EEGShoot.event, xfields{k});
    fprintf('%s: %g[ ', xfields{k}, length(tValues));
    for j = 1:length(tValues)
        fprintf('%s ', tValues{j});
    end
    fprintf(']\n');
end
tValues = getutypes(testCase.TestData.EEGShoot.event, 'Ambiguous');
end
