% This function takes in a file containing the HED tags associated with a
% particular study and replaces the old HED tags with the new HED tags 
% that are specified in a HED remap file.
%
% Usage:
%   >>  replacetags(remap, tags, columns);
%   >>  replacetags(remap, tags, columns, varargin);
%
% Input:
%       'remap'     The name or the path of the HED remap file containing
%                   the mappings of old HED tags to new HED tags. This
%                   file is a two column tab-delimited file with the old 
%                   HED tags in one column and the new HED tags in another
%                   column.
%       'tags'      The name or the path of a tab-delimited text file
%                   containing HED tags associated with a particular study.
%       'columns'   The columns that contain the HED study tags. The 
%                   columns can be a scalar value or a vector.
%       Optional:
%       'header'    True if the tab-delimited text file containing the 
%                   HED study tags starts with a header row. This row will
%                   be skipped and not looked at. False if the file 
%                   doesn't start with a header row. 
%       'output'    The name or the path to the file that the output is
%                   written to. The output file will be a tab-delimited
%                   text file consisting of the new HED tags which replaced
%                   the old HED tags in each specified columns.
%
% Examples:
%                   To replace the old HED tags in file 
%                   'Reward Two Back Study.txt' with new HED tags in the
%                   fourth column using HED remap file 'HEDRemap.txt'. 
%
%                   replacetags ('HEDRemap.txt', ...
%                   'Reward Two Back Study.txt', 4) 
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function replacetags(remap, tags, columns, varargin)
p = parseArguments();
output = '';
remapMap = remap2map(p.RemapFile);
takeValueTags = getTakeValueTags(remapMap);
try
    fileId = fopen(p.TagFile);
    % tLine = checkHeader(fileId);
    tLine = checkHeader(fileId);
    while ischar(tLine)
        readTags(tLine, columns, false);
        tLine = fgetl(fileId);
    end
    fclose(fileId);
    writeOutput(output)
catch me
    fclose(fileId);
    rethrow(me);
end

    function tLine = checkHeader(fileId)
        % Checks to see if the file has a header line
        tLine = fgetl(fileId);
        if p.Header
            readTags(tLine, columns, true);
            tLine = fgetl(fileId);
        end
    end % checkHeader

    function remapTags = checkTakeValueTags(tag)
        % Checks for wildcard tags
        remapTags = '';
        [~, endIndexes] = regexp(tag, takeValueTags);
        takeValueTag = takeValueTags(~cellfun(@isempty, endIndexes));
        endIndex = endIndexes(~cellfun(@isempty,endIndexes));
        if ~isempty(takeValueTag) && ~isempty(endIndex)
            replaceStr = tag(endIndex{1}+1:end);
            remapTags = remapMap([takeValueTag{1} '/#']);
            remapTags = cellfun(@(x) strrep(x, '/#', replaceStr), ...
                remapTags, 'UniformOutput', false);
            remapTags = strjoin(remapTags, ',');
        end
    end % checkWildcardTags

    function takeValueTags = getTakeValueTags(remapMap)
        % Gets the take value tags from the remap Map
        remapKeys = remapMap.keys();
        takeValueTags = remapKeys(~cellfun(@isempty, ...
            regexp(remapKeys, '/\#$')));
        takeValueTags =  cellfun(@(x) strrep(x, '/#', ''), ...
            takeValueTags, 'UniformOutput', false);
    end % getTakeValueTags

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('RemapFile', @(x) ~isempty(x) && ischar(x));
        p.addRequired('TagFile', @(x) ~isempty(x) && ischar(x));
        p.addRequired('TagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        p.addParamValue('Header', true, @islogical); %#ok<NVREPL>
        [path, file] = fileparts(tags);
        p.addParamValue('OutputFile', ...
            fullfile(path, [file '_output.txt']), ...
            @(x) ~isempty(x) && ischar(x));  %#ok<NVREPL>
        p.parse(remap, tags, columns, varargin{:});
        p = p.Results;
    end % parseArguments

    function readTags(tLine, tagColumns, header)
        % Reads the tag columns from a tab-delimited row
        splitLine = strsplit(tLine, '\t');
        numCols = length(splitLine);
        for a = 1:numCols
            if ~header && ismember(a, tagColumns)
                splitTags = splitLine{tagColumns(1)};
                tags = str2cell(splitTags);
                remappedTags = remapTags(tags);
                remappedTags = cell2str(remappedTags);
                output = sprintf('%s%s\t', output, remappedTags);
            else
                output = sprintf('%s%s\t', output, splitLine{a});
            end
        end
        output = sprintf('%s\n', output);
    end % readTags

    function remappedTags = remapTags(tags)
        % Replaces the old HED tags with the new HED tags
        remappedTags = {};
        for a = 1:length(tags)
            if iscellstr(tags{a})
                remappedTags = [remappedTags ...
                    {remapTags(tags{a})}]; %#ok<AGROW>
            else
                try
                    remappedTags = [remappedTags ...
                        remapMap(lower(tags{a}))];  %#ok<AGROW>
                catch
                    remapTags = checkTakeValueTags(tags{a});
                    if ~isempty(remapTags)
                        remappedTags = [remappedTags ...
                            remapMap(lower(tags{a}))]; %#ok<AGROW>
                    else
                        remappedTags = [remappedTags tags{a}]; %#ok<AGROW>
                    end
                end
            end
        end
    end % remapTags

    function tags = str2cell(tags)
        % Converts the tags from a str to a cellstr
        tags = formatTags(tags, true);
    end % str2cell

    function strTags = cell2str(cellTags)
        % Converts the tags from a cellstr to a str
        strTags = '';
        for a = 1:length(cellTags)
            if iscellstr(cellTags{a})
                strTags = [strTags ',' '(' strjoin(cellTags{a}, ...
                    ',') ')']; %#ok<AGROW>
            else
                strTags = [strTags ',' cellTags{a}];     %#ok<AGROW>
            end
        end
        strTags = regexprep(strTags,'^,','');
    end % cell2str

    function writeOutput(output)
        % Writes the output to the file
        outputFile = p.OutputFile;
        fileId = fopen(outputFile,'w');
        fprintf(fileId, '%s', output);
        fclose(fileId);
    end % writeOutput

end % replacetags