function [errors, errorTags] = checkrequired(Maps, canonical)
% Checks if all required tags are present in the tag list
errors = '';
errorTags = {};
requiredTags = Maps.required.values();
eventLevelTags = canonical(cellfun(@isstr, canonical));
checkRequiredTags();

    function checkRequiredTags()
        % Checks the tags that are required
        for a = 1:length(requiredTags)
            requiredIndexes = regexpi(eventLevelTags, requiredTags{a});
            if ~any(cell2mat(requiredIndexes))
                generateErrors(a);
            end
        end
    end % checkTags

    function generateErrors(requiredIndex)
        % Generates a required tag errors if the required tag isn't present
        % in the tag list
        errors = [errors, generateerror('required', '', ...
            requiredTags{requiredIndex}, '')];
        errorTags{end+1} = requiredTags{requiredIndex};
    end % generateErrors

end % checkRequired