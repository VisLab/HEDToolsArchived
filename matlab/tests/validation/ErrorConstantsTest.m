classdef ErrorConstantsTest < matlab.unittest.TestCase
    
    methods (Test)
        
        function testErrorTypeProperty(testCase)
            % Unit test for ErrorTypes property
            errorTypes = ErrorConstants.ErrorTypes;
            numErrorTypes = length(errorTypes);
            for a = 1:numErrorTypes
                testCase.assertInstanceOf(errorTypes{a}, 'char');
            end
        end % testErrorTypeProperty
        
        function testErrorMessageProperty(testCase)
            % Unit test for ErrorMessages property
            errorMessages = ErrorConstants.ErrorMessages;
            numErrorTypes = length(errorMessages);
            for a = 1:numErrorTypes
                testCase.assertInstanceOf(errorMessages{a}, 'char');
            end
        end % testErrorMessageProperty
        
    end % test functions 
    
end % ErrorConstantsTest

