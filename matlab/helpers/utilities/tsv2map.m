% Reads in a tab-separated file and stores the events and associated tags
% in a tagMap.
%
% Usage:
%
%   >>  tsvMap = tsv2map(filename)
%
%   >>  tsvMap = tsv2map(filename, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   filename
%                    The name (if added to the workspace) or full path
%                    (if not added to the workspace) of a tab-separated
%                    file.
%
%   Optional (key/value):
%
%   fieldname
%                    The field name in the tagMap that is associated with
%                    the values in a tab-separated file. The default value
%                    is 'type'.
%
%   eventColumn
%                    The event column in the tab-separated file. This is a
%                    scalar integer. The default value is 1
%                    (the first column).
%
%   hasHeader
%                   True (default) if the the tab-separated input file has
%                   a header. The first row will not be validated otherwise
%                   it will and this can generate issues.
%
%   tagColumn
%                    The tag column(s) in the tab-separated file. This can
%                    be a scalar integer or an integer vector. The default
%                    value is 2 (the second column).
%
% Output:
%
%   tsvMap
%                    A tagMap containing the events and associated tags
%                    from the tab-separated file.
%
% Examples:
%
%  Store a tab-separated file 'BCI Data Specification.tsv' with event types
%  in column '1' and HED tags in columns '3','4','5','6' in a tagMap
%  'tsvMap' as field 'type'.
%
%  tsvMap = tagtsv('BCI Data Specification.tsv', 'fieldname', 'type' ...
%  'eventColumn', 1, 'tagColumn', [3,4,5,6])
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

function tsvMap = tsv2map(filename, varargin)
p = parseArguments(filename, varargin{:});
tsvMap = tagMap('Field', p.fieldname);
lineNumber = 1;
try
    fileId = fopen(p.filename);
    [line, lineNumber] = checkFileHeader(p.hasHeader, fileId);
    while ischar(line)
        event = getLineValues(p, line, p.eventColumn, false);
        tags = getLineValues(p, line, p.tagColumn, true);
        if ~isempty(event)
            addTags2Map(tsvMap, event, tags);
        end
        lineNumber = lineNumber + 1;
        line = fgetl(fileId);
    end
    if fileId ~= -1
        fclose(fileId);
    end
catch ME
    if fileId ~= -1
        fclose(fileId);
    end
    throw(MException(ME.identifier, ...
        sprintf('Line %d : %s', lineNumber, ME.message)));
end

    function addTags2Map(tsvMap, event, tags)
        % Adds tags to a TagMap
        tList = tagList(event);
        tList.addString(tags);
        tsvMap.addValue(tList);
    end % addTags2Map

    function [line, lineNumber] = checkFileHeader(hasHeader, fileId)
        % Checks to see if the file has a header and skips it if it does
        lineNumber = 1;
        line = fgetl(fileId);
        if hasHeader
            line = fgetl(fileId);
            lineNumber = 2;
        end
    end % checkFileHeader

    function values = getLineValues(p, line, column, tag)
        % Reads the column values on a tab-delimited line
        delimitedLine = textscan(line, '%s', 'delimiter', '\t');
        if tag
            [delimitedLine{1}, column] = getSpecificColumns(p, ...
                delimitedLine{1});
        end
        delimitedLineCount = 1:length(delimitedLine{1});
        availableColumns = intersect(delimitedLineCount, column);
        nonemptyColumns = availableColumns(~cellfun(@isempty, ...
            delimitedLine{1}(availableColumns)));
        values = strjoin(delimitedLine{1}(nonemptyColumns), ', ');
    end % getLineValues

    function [delimitedLine, column] = getSpecificColumns(p, delimitedLine)
        % Gets specific tag columns and appends the appropriate prefix to
        % it if it's not present 
        numColumns =  length(delimitedLine);
        column = p.tagColumn;
        if ~isempty(p.attributeColumn) && numColumns >= p.attributeColumn
            delimitedLine{p.attributeColumn} = ...
                appendPrefix(delimitedLine{p.attributeColumn}, ...
                'Attribute/');
            column = union(column, p.attributeColumn);
        end
        if ~isempty(p.categoryColumn) && numColumns >= p.categoryColumn
            delimitedLine{p.categoryColumn} = ...
                appendPrefix(delimitedLine{p.categoryColumn}, ...
                'Event/Category/');
            column = union(column, p.categoryColumn);
        end
        if ~isempty(p.descriptionColumn) && numColumns >= ...
                p.descriptionColumn
            delimitedLine{p.descriptionColumn} = ...
                appendPrefix(delimitedLine{p.descriptionColumn}...
                , 'Event/Description/');
            column = union(column, p.descriptionColumn);
        end
        if ~isempty(p.labelColumn) && numColumns >= p.labelColumn
            delimitedLine{p.labelColumn} = ...
                appendPrefix(delimitedLine{p.labelColumn}, ...
                'Event/Label/');
            column = union(column, p.labelColumn);
        end
        if ~isempty(p.longnameColumn) && numColumns >= p.longnameColumn
            delimitedLine{p.longnameColumn} = ...
                appendPrefix(delimitedLine{p.longnameColumn}, ...
                'Event/Long name/');
            column = union(column, p.longnameColumn);
        end
    end % getSpecificColumns

    function specificLine = appendPrefix(specificLine, specificStr)
        % Appends a prefix to a tag column if it isn't present
        if ~isempty(specificLine)
            specificTags = textscan(specificLine, '%s', 'delimiter', ',');
            pos = ~strncmpi(specificTags{1}, specificStr, ...
                length(specificStr));
            specificTags{1}(pos) = strcat(specificStr, ...
                specificTags{1}(pos));
            specificLine = strjoin(specificTags{1}, ', ');
        end
    end % appendPrefix

    function p = parseArguments(filename, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('filename', @(x) ~isempty(x) && ...
            ischar(filename));
        parser.addParamValue('attributeColumn', [], @(x) ~isempty(x) ...
            && isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('categoryColumn', [], @(x) ~isempty(x) ...
            && isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('descriptionColumn', [], @(x) ~isempty(x) ...
            && isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('eventColumn', 1, @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('fieldname', 'type', @(x) ~isempty(x) && ...
            ischar(x));
        parser.addParamValue('hasHeader', true, @islogical);
        parser.addParamValue('labelColumn', [], @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('longnameColumn', [], @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) == 1 && rem(x,1) == 0);
        parser.addParamValue('tagColumn', 2, @(x) ~isempty(x) && ...
            isnumeric(x) && length(x) >= 1 && all(rem(x,1) == 0));
        parser.parse(filename, varargin{:});
        p = parser.Results;
    end % parseArguments

end % tsv2map