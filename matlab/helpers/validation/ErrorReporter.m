classdef ErrorReporter
    %ERRORREPORTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ErrorTypeMap = containers('KeyType', 'char', 'ValueType', 'char');
        
    end % properties
    
    methods
        
        function obj = ErrorReporter()
            % ErrorReporter constructor. 
            %
            % Returns
            % obj - A ErrorReporter object.
            %
            obj = populateErrorTypeMap(obj);
        end % ErrorReporter
        
        function error = reportError(obj, errorType)
            % Reports the error associated with the error type. If the
            % error type doesn't exist then an empty string is returned.
            %
            % Parameters
            % errorType - The type of error.
            %
            % Returns
            % error - The error associated with the error type.
            %
            if ~isKey(obj.ErrorTypeMap, errorType)
                error = '';
                return;
            end
            errorMessage = obj.ErrorTypeMap(errorType);
        end % reportError
        
        function placeHolderCount = countPlaceHoldersInError(error)
            % Counts the number of place holders in the error message.
            %
            % Parameters
            % error - The error message.
            %
            % Returns
            % placeHolderCount - The number of place holders in the error
            % message.
            %
            placeHolderCount = length(strfind(error, ...
                ErrorConstants.PlaceHolderString));
        end % countPlaceHoldersInError
        
        function obj = populateErrorTypeMap(obj)
            % Populates the ErrorTypeMap property.
            %
            % Parameters
            % obj - A ErrorReporter object.
            %
            % Returns
            % obj - A ErrorReporter object.
            %
            obj.ErrorTypeMap = containers.Map(...
                ErrorConstants.ErrorTypes, ErrorConstants.ErrorMessages);
        end % populateErrorTypeMap
        
    end % methods
    
end

