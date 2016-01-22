function assertAltExceptionThrown(f, expectedId, custom_message)
%assertAltExceptionThrown Assert that one of a specified list of exceptions is thrown
%   assertExceptionThrown(F, expectedId) calls the function handle F with no
%   input arguments.  If the result is a thrown exception whose identifier is
%   contained in the cell array expectedId, then assertExceptionThrown 
%   returns silently.  If no exception is thrown, then assertExceptionThrown 
%   throws an exception with identifier equal to 
%   'assertExceptionThrown:noException'.  If a different exception is thrown,
%   then assertExceptionThrown throws an exception identifier equal to
%   'assertExceptionThrown:wrongException'.
%
%   assertExceptionThrown(F, expectedId, msg) prepends the string msg to the
%   assertion message.
%
%   Example
%   -------
%   % This call returns silently.
%   f = @() error('a:b:c', 'error message');
%   assertExceptionThrown(f, 'a:b:c');
%
%   % This call returns silently.
%   assertExceptionThrown(@() sin, 'MATLAB:minrhs');
%
%   % This call throws an error because calling sin(pi) does not error.
%   assertExceptionThrown(@() sin(pi), 'MATLAB:foo');
%   Notes:
%     - This version is similar to assertExceptionThrown because
%       some exception names changed (e.g.,  MATLAB:inputArgUndefined 
%       -> MATLAB:minrhs)between R2010b and R2011b.

%   Kay A. Robbins
%   Copyright 2010-2011 University of Texas at San Antonio

noException = false;
if ~iscell(expectedId)
    sMsg = expectedId;
    Ids = {expectedId};
else
    sMsg = expectedId{1};
    for k = 2:length(expectedId)
        sMsg = [sMsg ', ' expectedId{k}];
    end
    sMsg = ['{' sMsg '}'];
    Ids = expectedId;
end

try
    f();
    noException = true;
    
catch exception
    for k = 1:length(Ids)
        if  strcmp(exception.identifier, Ids{k})
            return;
        end
    end
    message = sprintf('Expected one of exceptions %s but got exception %s.', ...
        sMsg, exception.identifier);
    if nargin >= 3
        message = sprintf('%s\n%s', custom_message, message);
    end
    throwAsCaller(MException('assertExceptionThrown:wrongException', ...
        '%s', message));
end

if noException
    message = sprintf('Expected exception "%s", but none thrown.', sMsg);
    if nargin >= 3
        message = sprintf('%s\n%s', custom_message, message);
    end
    throwAsCaller(MException('assertExceptionThrown:noException', '%s', message));
end
