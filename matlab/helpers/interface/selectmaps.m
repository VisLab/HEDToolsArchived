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
%   'PrimaryEventField'
%                    The name of the primary field. Only one field can be
%                    the primary field. A primary field requires a label,
%                    category, and a description. The default is the type
%                    field.
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

function [canceled, ignoredEventFields] = selectmaps(fMap, varargin)
p = parseArguments(fMap, varargin{:});
[canceled, ignoredEventFields, primaryEventField] = selectFields2Tag(p);
fMap.setPrimaryMap(primaryEventField);

    function [canceled, ignoredEventFields, primaryEventField] = ...
            selectFields2Tag(p)
        % Select fields to ignore/tag with a menu
        canceled = false;
        [loader, submitted] = showSelectionMenu({}, p.fMap.getFields(), ...
            p.PrimaryEventField);
        ignoredEventFields = cell(loader.getIgnoredFields());
        primaryEventField = char(loader.getPrimaryField());
        if ~submitted
            canceled = true;
            return;
        end
    end % selectFields2Tag

    function [loader, submitted] = ...
            showSelectionMenu(ignoredEventFields, taggedEventFields, ...
            primaryEventField)
        % Show a java field selection menu
        fprintf('\n---Now select the fields you want to tag---\n');
        title = ['Please select the event fields that you would like' ...
            ' to tag'];
        loader = javaObject('edu.utsa.tagger.FieldSelectLoader', title, ...
            ignoredEventFields, taggedEventFields, primaryEventField);
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

    function p = parseArguments(fMap, varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addRequired('fMap', @(x) (~isempty(x) && ...
            isa(x, 'fieldMap')));
        parser.addParamValue('PrimaryEventField', 'type', @(x) ...
            (isempty(x) || ischar(x)))
        parser.parse(fMap, varargin{:});
        p = parser.Results;
    end % parseArguments

end % selectmaps