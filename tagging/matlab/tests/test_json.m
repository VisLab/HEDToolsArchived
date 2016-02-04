function test_suite = test_json %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values = '';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testJsonEvents(values) %#ok<INUSD,DEFNU>
% Unit test for eventTags constructor valid JSON
fprintf('\nUnit tests for JsonConversion\n');
fprintf('It should convert a structure with empty events\n');
eStruct1.events = '';
Json1 = savejson('', eStruct1);
s1 = loadjson(Json1);
assertTrue(isstruct(s1));
fprintf('It should not work properly for an empty string\n');
Json2 = savejson('', '');
try  
   loadjson(Json2);
   fail('Can''t retranslate');
catch e
    assertTrue(strcmpi('input file does not exist', e.message));
end