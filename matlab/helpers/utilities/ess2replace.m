% This function takes in a ESS file containing HED tags associated with a
% particular study and returns all of the unique tags.
%
% Usage:
%
%   >>  uniqueTags = ess2replace(essFile);
%
%   >>  uniqueTags = ess2replace(essFile, varargin);
%
% Input:
%
%   essFile
%                   The name or the path of a ESS file that contains tags.
%
%   Optional:
%
%   'outputDirectory'
%                   A directory where the output is written to if the
%                   'writeOuput' argument is true. There will be a remap
%                   file generated with _remap appended to the essFile
%                   filename.
%
% Output:
%
%   uniqueTags
%                   A cell array containing all of the unique tags in a
%                   ESS file.
%
% Examples:
%                   Get all of the unique tags from the Five-Box task
%                   ESS file.
%
%                   uniqueTags = ...
%                   createESSRemap('Five-Box task\study_description.xml');
%
% Copyright (C) 2012-2016 Thomas Rognon tcrognon@gmail.com,
% Jeremy Cockfield jeremy.cockfield@gmail.com, and
% Kay Robbins kay.robbins@utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function uniqueTags = ess2replace(essFile, varargin)
p = parseArguments(essFile, varargin{:});
xDoc = xmlread(p.essFile);
uniqueTags = getUniqueTags(xDoc);
writeToReplaceFile(p, xDoc, uniqueTags);


    function uniqueTags = getUniqueTags(xDoc)
        % Gets all of the unique tags from the XML file
        uniqueTags = {};
        allEventCodes = xDoc.getElementsByTagName('eventCode');
        for k = 0:allEventCodes.getLength-1
            eventCode = allEventCodes.item(k);
            thisList = eventCode.getElementsByTagName('tag');
            thisElement = thisList.item(0);
            if ~isempty(thisElement.getFirstChild)
                tags = strtrim(char(thisElement.getFirstChild.getData));
                cellTags = vTagList.deStringify(tags);
                uniqueTags = union(uniqueTags, cellTags);
            end
        end
    end % getUniqueTags

    function studyTitle = getStudyTitle(xDoc)
        % Gets the title tag from the XML file
        thisList = xDoc.getElementsByTagName('title');
        thisElement = thisList.item(0);
        studyTitle = strtrim(char(thisElement.getFirstChild.getData));
    end % getStudyTitle

    function p = parseArguments(essFile, varargin)
        % Parses the input arguments and returns the results
        p = inputParser();
        p.addRequired('essFile', @ischar);
        p.addParamValue('outputDirectory', pwd, ...
            @(x) ischar(x) && 7 == exist(x, 'dir')); %#ok<NVREPL>
        p.parse(essFile, varargin{:});
        p  = p.Results;
    end  % parseArguments

    function writeToReplaceFile(p, xDoc, uniqueTags)
        % Writes to a new replace file
        dir = p.outputDirectory;
        studyTitle = getStudyTitle(xDoc);
        file = [studyTitle '_replace'];
        ext = '.tsv';
        numRemapTags = length(uniqueTags);
        remapFile = fullfile(dir, [file ext]);
        fileId = fopen(remapFile,'w');
        if numRemapTags > 0
            fprintf(fileId, '%s', uniqueTags{1});
            for a = 2:numRemapTags
                fprintf(fileId, '\n%s', uniqueTags{a});
            end
        end
        fclose(fileId);
    end % writeToReplaceFile

end % ess2replace