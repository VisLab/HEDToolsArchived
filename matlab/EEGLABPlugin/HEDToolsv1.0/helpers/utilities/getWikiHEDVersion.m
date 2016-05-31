function version = getWikiHEDVersion(hedWiki)
p = parseArguments();
version = '';
try
    fileId = fopen(p.hedWiki);
    wikiLine = fgetl(fileId);
    while ischar(wikiLine)
        if strfind(wikiLine, 'HED version:')
             numericIndexes = ismember(wikiLine, '0123456789.');
             version = wikiLine(numericIndexes);
            break;
        end
        wikiLine = fgetl(fileId);
        lineNumber = lineNumber + 1;
    end
    fclose(fileId);
catch ME
    fclose(fileId);
    throw(MException('findWikiHEDVersion:cannotParse', ...
        'Unable to parse HED wiki file on line %d', lineNumber));
end

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('hedWiki', @(x) ~isempty(x) && ischar(x) && ...
            2 == exist(x, 'file'));
        p.parse(hedWiki);
        p = p.Results;
    end % parseArguments

end % getWikiHEDVersion

