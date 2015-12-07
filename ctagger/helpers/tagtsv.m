% tagtsv
% Reads in a tab separated file and stores the events and associated tags
% in a TagMap
%
% Usage:
%   >>  tsvTagMap = tagtsv(filename, fieldname, eventColumn, tagColumns)
%
% Description:
% tsvTagMap = tagtsv(filename, fieldname, eventColumn, tagColumns) reads in
% a tab separated file and stores the events and associated tags in a
% TagMap with a specified field.
%
% Example:
%  s = tagtsv('BCI Data Specification.txt', 'type' 1, [3,4,5,6])
%
%  Store a tab separated file 'BCI Data Specification.txt' with events
%  in column '1' and tags in columns '3','4','5','6' in a TagMap as field
%  'type'.
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for editmaps:
%
%    doc tagtsv
%
% See also: 
%
% Copyright (C) Kay Robbins, Jeremy Cockfield, and Thomas Rognon, UTSA,
% 2011-2015, kay.robbins.utsa.edu jeremy.cockfield.utsa.edu
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
%
% $Log: editmaps.m,v $
% $Revision: 2.0 10-Jul-2015 15:34:21 $
% $Initial version $
%

function tsvTagMap = tagtsv(filename, fieldname, eventColumn, tagColumns)
parser = inputParser;
parser.addRequired('Filename', @(x) (~isempty(x) && ischar(filename)));
parser.addRequired('FieldName', @(x) (~isempty(x) && ischar(fieldname)));
parser.addRequired('EventColumn', @(x) (~isempty(x) && ...
    isa(x,'double') && length(x) == 1));
parser.addRequired('TagColumns', @(x) (~isempty(x) && ...
    isa(x,'double') && length(x) >= 1));
parser.parse(filename, fieldname, eventColumn, tagColumns);

s = tdfread(filename,'\t');
tsvTagMap = tagMap('Field', fieldname);
if ~isempty(s)
    colNames = fieldnames(s);
    numRows = size(s.(colNames{1}),1);
    for  rowNum = 1:numRows
        event = readEvent(s, rowNum, colNames, eventColumn);
        tags = readTags(s, rowNum, colNames, tagColumns);
        if ~isempty(event) && ~strcmpi(event, 'NaN') && ~isempty(tags)
            addTagsToTagMap(tsvTagMap, event, tags);
        end
    end
end

    function addTagsToTagMap(tsvTagMap, event, tags)
        % Adds tags to a TagMap
        tList = tagList(event);
        tList.addString(tags);
        tsvTagMap.addValue(tList);
    end % addTagsToTagMap

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
    end

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