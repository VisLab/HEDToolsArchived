function [errors, warnings, extensions] = parsetags(Maps, tags, ...
    columns, varargin)
p = parseArguments();
errors = '';
warnings = '';
extensions = '';
fileId = fopen(p.Tags);
[tLine, rowNum] = checkHeader(fileId);
while ischar(tLine)
    [original, canonical] = readTags(tLine, p.Columns);
    if ~isempty(original)
        generateErrors(original, canonical, rowNum);
        generateWarnings(original, canonical ,rowNum);
    end
    tLine = fgetl(fileId);
    rowNum = rowNum + 1;
end
fclose(fileId);

    function [tLine, rowNum] = checkHeader(fileId)
        % Checks to see if the file has a header line
        rowNum = 1;
        tLine = fgetl(fileId);
        if p.Header
            tLine = fgetl(fileId);
            rowNum = 2;
        end
    end % checkHeader

    function [original, canonical] = readTags(tLine, tagColumns)
        % Reads the tag columns from a tab separated row
        splitLine = strsplit(tLine, '\t');
        numCols = length(tagColumns);
        splitTags = splitLine{tagColumns(1)};
        for a = 2:numCols
            splitTags  = [splitTags, ',', ...
                splitLine{tagColumns(a)}]; %#ok<AGROW>
        end
        [original, canonical] = str2cell(splitTags);
    end % readTags

    function [original, canonical] = str2cell(tags)
        % Converts the tags from a str to a cellstr
        original = formatTags(tags, false);
        canonical = formatTags(tags, true);
    end % formatTags

    function generateErrors(original, canonical, rowNum)
        % Errors will be generated for the line if found
        [lineError, lineWarning, lineExtension] = ...
            checktagerrors(Maps, original, canonical, p.ExtensionAllowed);
        if ~isempty(lineError)
            lineError = [generateerror('line', rowNum, '', '', ''), ...
                lineError];
            errors = sprintf([errors, lineError, '\n']);
        end
        if ~isempty(lineWarning)
            lineWarning = [generatewarning('line', rowNum, '', ''), ...
                lineWarning];
            warnings = sprintf([extensions, lineWarning, '\n']);
        end
        if ~isempty(lineExtension)
            lineExtension = [generateextension('line', rowNum, '', ''), ...
                lineExtension];
            extensions = sprintf([extensions, lineExtension, '\n']);
        end
    end % generateErrors

    function generateWarnings(original, canonical, rowNum)
        % Warnings will be generated for the line if found
        lineWarning = checktagwarnings(Maps, original, canonical);
        if ~isempty(lineWarning)
            lineWarning = [generatewarning('line', rowNum, '', ''), ...
                lineWarning];
            warnings = sprintf([warnings, lineWarning, '\n']);
        end
    end % generateWarnings

    function p = parseArguments()
        parser = inputParser;
        parser.addRequired('Tags', @(x) (~isempty(x) && ischar(x)));
        parser.addRequired('Columns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        parser.addParamValue('Header', true, @islogical); %#ok<NVREPL>
        parser.addParamValue('Output', fileparts(tags), ...
            @(x) ischar(x) && 7 == exist(x, 'dir')); %#ok<NVREPL>
        parser.addParamValue('ExtensionAllowed', true, ...
            @(x) validateattributes(x, {'logical'}, {})); %#ok<NVREPL>
        parser.parse(tags, columns, varargin{:});
        p = parser.Results;
    end % parseArguments

end % parsetags