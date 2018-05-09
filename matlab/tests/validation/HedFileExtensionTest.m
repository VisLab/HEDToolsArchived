function tests = HedFileExtensionTest
tests = functiontests(localfunctions);
end % errorReporterTest

function setupOnce(testCase)
testCase.TestData.excelFile = 'file.xls';
testCase.TestData.tsvFile = 'file.tsv';

end

%% Test Functions
function basicConstructorTest(testCase)
hedFileExtension = HedFileExtension('');
testCase.verifyClass(hedFileExtension, 'HedFileExtension');
end % basicConstructorTest

function fileExtensionTest(testCase)
hedFileExtension = HedFileExtension(testCase.TestData.excelFile);
hasExtension = hedFileExtension.hasExcelExtension();
testCase.verifyTrue(hasExtension);
hedFileExtension = HedFileExtension(testCase.TestData.tsvFile);
hasExtension = hedFileExtension.hasTsvExtension();
testCase.verifyTrue(hasExtension);
end % fileExtensionTest
