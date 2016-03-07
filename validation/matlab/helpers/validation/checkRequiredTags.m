function [errors, errorTags] = checkRequiredTags(Maps, canonical)
% Checks if all required tags are present in the tag list
errors = '';
errorTags = {};
requiredTags = Maps.required.values();
eventLevelTags = canonical(cellfun(@isstr, canonical));
checkRequiredTags();

    function checkRequiredTags()
        % Checks the tags that are required
        numTags = length(requiredTags);
        for a = 1:numTags
            requiredIndexes = strncmpi(eventLevelTags, requiredTags{a}, ...
                length(requiredTags{a}));
            if sum(requiredIndexes) == 0
                generateErrorMessages(a);
            end
        end
    end % checkTags

    function generateErrorMessages(requiredIndex)
        % Generates a required tag errors if the required tag isn't present
        % in the tag list
        errors = [errors, generateErrorMessage('required', '', ...
            requiredTags{requiredIndex}, '')];
        errorTags{end+1} = requiredTags{requiredIndex};
    end % generateErrorMessages

end % checkRequiredTags