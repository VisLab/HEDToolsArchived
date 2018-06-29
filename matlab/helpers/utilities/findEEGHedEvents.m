% This function will return a boolean mask corresponding to the tagged EEG
% events that contain query string matches.  
%
% Usage:
%
%   >> [matchMask, tags] = findEEGHedEvents(EEG, queryString)
%
%   >> [matchMask, tags] = findEEGHedEvents(EEG, queryString, varargin)
%
% Inputs:
%
%   EEG
%                Input dataset. The dataset is assumed to be tagged and has
%                a .usertags and/or .hedtags fields in the .event
%                structure.
%
% queryString  
%                A query string consisting of tags that you want to search
%                for. Two tags separated by a comma use the AND operator
%                by default, meaning that it will only return a true match
%                if both the tags are found. The OR (||) operator returns
%                a true match if either one or both tags are found.
%
% Optional inputs (key/value):
%
%   'exclusivetags'
%                A cell array of tags that nullify matches to other tags.
%                If these tags are present in both the EEG dataset event
%                tags and the tag string then a match will be returned.
%                By default, this argument is set to
%                {'Attribute/Intended effect', 'Attribute/Offset',
%                Attribute/Participant indication}.
%
% Outputs:
%
%   matchMask    
%                A logical array the length of hedStrings with true values
%                where hedStrings matched queryHedString.
%
%   tags    
%                A array of strings containing the HED tags where matches
%                where found.  
%
% Copyright (C) 2012-2018 Thomas Rognon tcrognon@gmail.com,
% Jeremy Cockfield jeremy.cockfield@gmail.com, and
% Kay Robbins kay.robbins@utsa.edu
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

function [matchMask, tags] = findEEGHedEvents(EEG, queryString, varargin)
parsedArguments = parseInputArguments(EEG, queryString, varargin{:});
hedStringsArray = arrayfun(@concattags, parsedArguments.EEG.event, ...
    'UniformOutput', false);
matchMask = cellfun(@(x) findhedevents(x, queryString, ...
    'exclusivetags', parsedArguments.exclusivetags), hedStringsArray);
tags = hedStringsArray(matchMask);


    function p = parseInputArguments(EEG, queryString, varargin)
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('EEG', @(x) ~isempty(x) && isstruct(x));
        p.addRequired('queryString', @(x) ischar(x));
        p.addParamValue('exclusivetags', ...
            {'Attribute/Intended effect', 'Attribute/Offset', ...
            'Attribute/Participant indication'}, ...
            @iscellstr); %#ok<NVREPL>
        p.parse(EEG, queryString, varargin{:});
        p = p.Results;
    end % parseInputArguments

end % findEEGHedEvents