classdef ErrorReporter
    % This class is used to report the validation errors.
    
    properties(Access = private)
        ErrorTypeMap = containers.Map('KeyType', 'char', ...
            'ValueType', 'char');
    end % properties
    
    methods
        
        function obj = ErrorReporter()
            % ErrorReporter constructor.
            %
            % Returns
            % obj - A ErrorReporter object.
            %
            obj.ErrorTypeMap = ErrorReporter.populateErrorTypeMap();
        end % ErrorReporter
        
        function errorTypeMap = getErrorTypeMap(obj)
            % Gets the ErrorTypeMap property.
            %
            % Returns
            % errorTypeMap - The ErrorTypeMap property.
            %
            errorTypeMap = obj.ErrorTypeMap;
        end % getErrorTypeMap
        
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
        
        function placeHolderCount = countPlaceHoldersInError(obj, error)
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
        
    end % public methods
    
    
    methods(Static)
        function errorTypeMap = populateErrorTypeMap()
            % Populates the ErrorTypeMap property.
            %
            % Parameters
            % obj - A ErrorReporter object.
            %
            % Returns
            % obj - A ErrorReporter object.
            %
            errorTypeMap = containers.Map(...
                ErrorConstants.ErrorTypes, ErrorConstants.ErrorMessages);
        end % populateErrorTypeMap
    end % static methods
    
end % ErrorReporter

