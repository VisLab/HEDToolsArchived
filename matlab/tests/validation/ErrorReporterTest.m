classdef ErrorReporterTest < matlab.unittest.TestCase
    
    methods (Test)
        
        function testGetErrorTypeMap(testCase)
            % Unit test for getErrorTypeMap function
            errorReporter = ErrorReporter();
            errorTypeMap = errorReporter.getErrorTypeMap();
            testCase.assertInstanceOf(errorTypeMap, 'containers.Map');
        end % testGetErrorTypeMap
        
        function testPopulateErrorTypeMap(testCase)
            % Unit test for populateErrorTypeMap function
            errorTypeMap = ErrorReporter.populateErrorTypeMap();
            testCase.assertInstanceOf(errorTypeMap, 'containers.Map');
        end % testPopulateErrorTypeMap
        
        function testCountPlaceHoldersInError(testCase)
            % Unit test for countPlaceHoldersInError function
            errorReporter = ErrorReporter();
            errors = ErrorConstants.ErrorMessages;
            numberOfErrors = length(errors);
            for a = 1:numberOfErrors
                placeHolderCount = ...
                    errorReporter.countPlaceHoldersInError(errors{a});
                testCase.assertInstanceOf(placeHolderCount, 'double');
            end
        end % testCountPlaceHoldersInError
        
    end % test functions
    
end % ErrorReporterTest

