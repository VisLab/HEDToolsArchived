function test_suite = test_xml %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
latestHed = 'HED 2.026.xml';
values.HedXml = fileread(latestHed);
hPath = fileparts(which(latestHed));
values.SchemaFile = [hPath filesep 'HED Schema 2.026.xsd'];
values.Schema = fileread(values.SchemaFile);
function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidWithSchema(values) %#ok<DEFNU>
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
 assertTrue(isValid);