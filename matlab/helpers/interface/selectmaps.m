% Allows a user to select the fields to be tagged using the CTagger.
%
% Usage:
%
%   >>  [fMap, excluded] = selectmaps(fMap)
%
%   >>  [fMap, excluded] = selectmaps(fMap, 'key1', 'value1', ...)
%
% Input:
%
%   Required:
%
%   fMap             A fieldMap object that contains the tag map
%                    information prior to tagging.
%
%   Optional (key/value):
%
%   'ExcludeFields'
%                    A cell array containing the field names to exclude.
%
%   'Fields'
%                    A cell array containing the field names to extract
%                    tags for.
%
%   'PrimaryField'
%                    The name of the primary field. Only one field can be
%                    the primary field. A primary field requires a label,
%                    category, and a description. The default is the type
%                    field.
%
%   'SelectFields'
%                    If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%
% Output:
%
%   fMap             A fieldMap object that contains the tag map
%                    information after tagging.
%
%   fields           The fields that the user decides to tag.
%
%   excluded         The fields that the user decides to exclude from
%                    tagging.
%
%   canceled         True if the user cancels. False if otherwise.
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

function [fMap, fields, excluded, canceled] = selectmaps(fMap, varargin)
p = parseArguments(fMap, varargin{:});
[fields, excluded, primaryField, canceled] = selectFields2Tag(p);
fMap.setPrimaryMap(primaryField);

    function [taggedUserFields, excludedUserFields, primaryUserField, ...
            canceled] = selectFields2Tag(p)
        % Select fields to tag with a menu
        inputTaggedFields = p.fMap.getFields();
        if ~isempty(p.Fields)
        inputTaggedFields = intersect(p.Fields, inputTaggedFields, ...
            'stable');
        end
        inputExcludedFields = setdiff(p.ExcludeFields, inputTaggedFields);
        canceled = false;
        [sortedTaggedFields, inputPrimaryField] = ...
            putPrimaryFirst(p.PrimaryField, inputTaggedFields);
        [loader, submitted] = showSelectionMenu(inputExcludedFields, ...
            sortedTaggedFields, inputPrimaryField);
        taggedUserFields = cell(loader.getTagFields());
        excludedUserFields = cell(loader.getExcludeFields());
        primaryUserField = char(loader.getPrimaryField());
        if ~submitted
            canceled = true;
            return;
        end
    end % selectFields2Tag

    function [loader, submitted] = showSelectionMenu(excluded, fields, ...
            primaryField)
        % Show a java field selection menu
        fprintf('\n---Now select the fields you want to tag---\n');
        title = 'Please select the fields that you would like to tag';
        loader = javaObject('edu.utsa.tagger.FieldSelectLoader', title, ...
            excluded, fields, primaryField);
        [notified, submitted] = checkMenuStatus(loader);
        while (~notified)
            pause(0.5);
            [notified, submitted] = checkMenuStatus(loader);
        end
    end % showSelectionMenu

    function [notified, submitted] = checkMenuStatus(loader)
        % Check the status of the java field selection menu
        notified = loader.isNotified();
        submitted = loader.isSubmitted();
    end % checkMenuStatus

    function [fields, primaryField] = putPrimaryFirst(primaryField, fields)
        % Moves the primary field to the beginning of the list of fields
        if sum(strcmp(fields, primaryField)) == 0
            primaryField = '';
        else
            pos = find(strcmp(fields, primaryField));
            temp = fields{pos};
            fields{pos} = fields{1};
            fields{1} = temp;
        end
    end % putPrimaryFirst

    function p = parseArguments(fMap, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('fMap', @(x) (~isempty(x) && ...
            isa(x, 'fieldMap')));
        parser.addParamValue('ExcludeFields', {}, ...
            @(x) (iscellstr(x)));
        parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
        parser.addParamValue('PrimaryField', 'type', @(x) ...
            (isempty(x) || ischar(x)))
        parser.addParamValue('SelectFields', true, @islogical);
        parser.parse(fMap, varargin{:});
        p = parser.Results;
    end % parseArguments

end % selectmaps