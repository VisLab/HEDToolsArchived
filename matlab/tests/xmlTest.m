function tests = xmlTest
tests = functiontests(localfunctions);
end % xmlTest


function setupOnce(testCase)
latestHed = 'HED.xml';
testCase.TestData.HedXml = fileread(latestHed);
hPath = fileparts(which(latestHed));
testCase.TestData.SchemaFile = [hPath filesep 'HED.xsd'];
testCase.TestData.Schema = fileread(testCase.TestData.SchemaFile);
end

function testValidWithSchema(testCase)
% Unit test for eventTags constructor valid JSON
fprintf('\nUnit tests for XML validation using Java libraries\n');
fprintf(['It should correctly validate the default HED hierarchy when' ...
    ' a schema is given\n']);
try
    fieldMap.validateXml(values.HedXml, values.Schema);
    isValid = true;
catch ex %#ok<NASGU>
    isValid = false;
end
testCase.verifyFalse(isValid);
end