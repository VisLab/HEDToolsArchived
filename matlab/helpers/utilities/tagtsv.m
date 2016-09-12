% Reads in a tab-separated file and stores the events and associated tags
% in a tagMap.
%
% Usage:
%
%   >>  tsvMap = tagtsv(filename, fieldname, eventColumn, tagColumns)
%
% Input:
%
%   Required:
%
%   filename
%                    The name or full path to a tab-separated file.
%
%   fieldname
%                    The field name in the tagMap that is associated with
%                    the values in a tab-separated file.
%
%   eventColumn
%                    The event column in the tab-separated file. This is a
%                    scalar value.
%
%   tagColumns
%                    The tag columns in the tab-separated file. This can be
%                    a scalar value or a vector. 
%
% Output:
%
%   tsvMap  
%                    A cell array containing the field names to exclude.
%
% Examples:
%
%  s = tagtsv('BCI Data Specification.txt', 'type' 1, [3,4,5,6])
%
%  Store a tab separated file 'BCI Data Specification.txt' with events
%  in column '1' and tags in columns '3','4','5','6' in a tagMap as field
%  'type'.
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

function tsvMap = tagtsv(filename, fieldname, eventColumn, tagColumns)
p = parseArguments(filename, fieldname, eventColumn, tagColumns);
s = tdfread(p.filename,'\t');
tsvMap = tagMap('Field', p.fieldname);
if ~isempty(s)
    colNames = fieldnames(s);
    numRows = size(s.(colNames{1}),1);
    for  rowNum = 1:numRows
        event = readEvent(s, rowNum, colNames, p.eventColumn);
        tags = readTags(s, rowNum, colNames, p.tagColumns);
        if ~isempty(event) && ~strcmpi(event, 'NaN') && ~isempty(tags)
            addTags2Map(tsvMap, event, tags);
        end
    end
end

    function addTags2Map(tsvTagMap, event, tags)
        % Adds tags to a TagMap
        tList = tagList(event);
        tList.addString(tags);
        tsvTagMap.addValue(tList);
    end % addTags2Map

    function p = parseArguments(filename, fieldname, eventColumn, ...
            tagColumns)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('filename', @(x) (~isempty(x) && ischar(filename)));
        parser.addRequired('fieldname', @(x) (~isempty(x) && ischar(fieldname)));
        parser.addRequired('eventColumn', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) == 1));
        parser.addRequired('tagColumns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        parser.parse(filename, fieldname, eventColumn, tagColumns);
        p = parser.Results;
    end % parseArguments

    function event = readEvent(s, rowNum, colNames, eventColumn)
        % Reads the event column from a tab separated row
        numCols = length(eventColumn);
        for eventColumn = 1:numCols
            if ~isempty(strtrim(num2str(s.(colNames{eventColumn(...
                    eventColumn)})(rowNum,:))))
                event = ...
                    strtrim(num2str(s.(colNames{eventColumn(...
                    eventColumn)})(rowNum,:)));
            end
        end
        event = regexprep(event,',','', 'once');
    end % readEvent

    function tags = readTags(s, rowNum, colNames, tagColumns)
        % Reads the tag columns from a tab separated row
        numCols = length(tagColumns);
        tags = '';
        for tagColumn = 1:numCols
            try
                if ~isempty(strtrim(num2str(s.(colNames{tagColumns(...
                        tagColumn)})(rowNum,:))))
                    tags = [tags,',',strtrim(num2str(s.(...
                        colNames{tagColumns(...
                        tagColumn)})(rowNum,:)))]; %#ok<AGROW>
                end
            catch
            end
        end
        tags = regexprep(tags,',','', 'once');
    end % readTags

end % tagtsv