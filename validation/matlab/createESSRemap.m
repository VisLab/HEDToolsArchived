function uniqueTags = createESSRemap(essFile, varargin)
p = parseArguments();
xDoc = xmlread(p.essFile);
uniqueTags = getUniqueTags(xDoc);
if p.writeOutput
    writeToReMapFile();
end

    function uniqueTags = getUniqueTags(xDoc)
        uniqueTags = {};
        allEventCodes = xDoc.getElementsByTagName('eventCode');
        for k = 0:allEventCodes.getLength-1
            eventCode = allEventCodes.item(k);
            thisList = eventCode.getElementsByTagName('tag');
            thisElement = thisList.item(0);
            tags = strtrim(char(thisElement.getFirstChild.getData));
            if ~isempty(tags)
                cellTags = vTagList.deStringify(tags);
                uniqueTags = union(uniqueTags, cellTags);
            end
        end
    end

    function studyTitle = getStudyTitle(xDoc)
        thisList = xDoc.getElementsByTagName('title');
        thisElement = thisList.item(0);
        studyTitle = strtrim(char(thisElement.getFirstChild.getData));
    end

    function p = parseArguments()
        % Parses the input arguments and returns the results
        p = inputParser();
        p.addRequired('essFile', @ischar);
        p.addParamValue('outputDirectory', pwd, ...
            @(x) ischar(x) && 7 == exist(x, 'dir')); %#ok<NVREPL>
        p.addParamValue('writeOutput', false, @islogical); %#ok<NVREPL>
        p.parse(essFile, varargin{:});
        p  = p.Results;
    end  % parseArguments

    function writeToReMapFile()
        % Writes to a new map file
        dir = p.outputDirectory;
        studyTitle = getStudyTitle(xDoc);
        file = [studyTitle '_remap'];
        ext = '.txt';
        numRemapTags = size(uniqueTags, 1);
        remapFile = fullfile(dir, [file ext]);
        fileId = fopen(remapFile,'w');
        if numRemapTags > 0
            fprintf(fileId, '%s', uniqueTags{1});
            for a = 2:numRemapTags
                fprintf(fileId, '\n%s', uniqueTags{a});
            end
        end
        fclose(fileId);
    end % writeToNewMapFile
end