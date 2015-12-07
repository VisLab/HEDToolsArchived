function test_suite = test_getutypes%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
  values = '';
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('hedXML', '', 'events', 'def');
tags = {'/Sensory presentation/Taste', ...
    '/Item/Object/Person/Pedestrian', ...
    '/Item/Object/Person/Mother-child'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.events = sE;
eJSON1 = savejson('', eStruct);
values.eStruct1 = eStruct;
values.eJSON1 = eJSON1;
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;
load EEGShoot.mat;
values.EEGShoot = EEGShoot;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidValues(values)  %#ok<DEFNU>
% Unit test for getutypes
fprintf('\nUnit tests for findtags\n');
fprintf('It should find values for an EEG structure\n');
tValues = getutypes(values.EEGEpoch.event, 'type');
assertEqual(length(tValues), 2);
tValues = getutypes(values.EEGEpoch.urevent, 'type');
assertEqual(length(tValues), 2);
assertTrue(sum(strcmpi('RT', tValues)) > 0);
tValues = getutypes(values.EEGEpoch.event, 'position');
assertEqual(length(tValues), 2);
fprintf('It should return empty when the fields have no values\n');
x = struct('type', {'', '', ''});
assertEqual(length(x), 3);
tValues = getutypes(x, 'type');
assertEqual(length(tValues), 0);
assertTrue(isempty(tValues));
fprintf('It should return appropriate values for arbitrary fields\n');
xfields = fieldnames(values.EEGShoot.event);
for k = 1:length(xfields)
    tValues = getutypes(values.EEGShoot.event, xfields{k});
    fprintf('%s: %g[ ', xfields{k}, length(tValues));
    for j = 1:length(tValues)
        fprintf('%s ', tValues{j});
    end
    fprintf(']\n');
end
tValues = getutypes(values.EEGShoot.event, 'Ambiguous');
