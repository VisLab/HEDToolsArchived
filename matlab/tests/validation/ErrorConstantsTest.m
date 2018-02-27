classdef ErrorConstantsTest < matlab.unittest.TestCase
    
    methods (Test)
        function testErrorTypeProperty(testCase)
            errorTypes = ErrorConstants.ErrorTypes;
            numErrorTypes = length(errorTypes);
            for a = 1:numErrorTypes
                testCase.assertInstanceOf(errorTypes{a}, 'char');
            end
        end
        function testErrorMessageProperty(testCase)
            errorMessages = ErrorConstants.ErrorMessages;
            numErrorTypes = length(errorMessages);
            for a = 1:numErrorTypes
                testCase.assertInstanceOf(errorMessages{a}, 'char');
            end
        end
    end
    
end

