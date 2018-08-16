% Allows a user to extract epochs based on HED tags using a GUI.
%
% Usage:
%
%   >>  [EEG, indices, com] = pop_epochhed(EEG);
%
%   >>  [EEG, indices, com] = pop_epochhed(EEG, querystring);
%
%   >>  [EEG, indices, com] = pop_epochhed(EEG, querystring, ...
%                             'key1', value1 ...);
%
% Menu Options:
%
%   Time-locking HED tag(s)
%                A query string consisting of tags that you want to search
%                for. Two tags separated by a comma use the AND operator
%                by default, meaning that it will only return a true match
%                if both the tags are found. The OR (||) operator returns
%                a true match if either one or both tags are found.
%
%   ...
%                Brings up search bar for specifiying Time-locking HED
%                tag(s).
%
%   Exclusive HED tag(s)
%                A comma-separated list of tags that nullify matches to
%                other tags. If these tags are present in both the EEG
%                dataset event tags and the tag string then a match will be
%                returned. The default is
%                Attribute/Intended effect, Attribute/Offset,
%                Attribute/Participant indication.
%
%   Epoch limits
%                Epoch latency limits [start end] in seconds relative to
%                the time-locking event. The default is [-1 2].
%
%   Name for the new dataset
%                [edit box] epochhed() function equivalent: 'newname'
%
%   Out-of-bounds EEG limits if any
%                [min max] data limits. If one positive value is given,
%                the opposite value is used for lower bound. For example,
%                use [-50 50].
%
% Inputs:
%
%   EEG
%                Input dataset. Data may already be epoched; in this case,
%                extract (shorter) subepochs time locked to epoch events.
%
%   querystring
%                A query string consisting of tags that you want to search
%                for. Two tags separated by a comma use the AND operator
%                by default, meaning that it will only return a true match
%                if both the tags are found. The OR (||) operator returns
%                a true match if either one or both tags are found.
%
%   timelim
%                Epoch latency limits [start end] in seconds relative to
%                the time-locking event {default: [-1 2]}
%
% Optional inputs:
%
%   'epochinfo'
%                ['yes'|'no'] Propagate event information into the new
%                epoch structure {default: 'yes'}
%
%   'eventindices'
%                [integer vector] Extract data epochs time locked to the
%                indexed event numbers.
%
%   'newname'
%                [string] New dataset name {default: "[old_dataset]
%                epochs"}
%
%   'valuelim'
%                [min max] or [max]. Lower and upper bound latencies for
%                trial data. Else if one positive value is given, use its
%                negative as the lower bound. The given values are also
%                considered outliers (min max) {default: none}
%
%   'verbose'
%                ['yes'|'no'] {default: 'yes'}
%
% deprecated
%
%   'timeunit'   Time unit ['seconds'|'points'] If 'seconds,' consider
%                events times to be in seconds. If 'points,' consider
%                events as indices into the data array. The default is
%                'points'.
%
% Outputs:
%
%   EEG
%              Output dataset that has extracted data epochs.
%
%   indices
%              Indices of accepted events.
%
%   com
%              A command string that calls the underlying epochhed
%              function.
%
% Copyright (C) 2012-2018 Thomas Rognon tcrognon@gmail.com,
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [EEG, indices, com] = pop_epochhed(EEG, querystring, timelim, ...
    varargin)
indices = [];
com = '';
% Display help if inappropriate number of arguments
if nargin < 1
    help pop_epochhed;
    return;
end;

p = parseArguments(EEG, querystring, varargin);
if nargin < 2
    % Find all the unique tags in the events
    if ~exist('tagstring','var')
        querystring = '';
    end
    
    uniquetags = finduniquetags(arrayfun(@concattags, EEG.event, ...
        'UniformOutput', false));
    % Get input arguments from GUI
    [canceled, querystring, exclusiveTags, newName, timelim, valueLim] = ...
        epochhed_input(EEG.setname, querystring, uniquetags);
    if canceled
        return;
    end
    [EEG, indices] = epochhed(EEG, querystring, 'timelim', timelim, ...
        'exclusivetags', exclusiveTags, 'newname', newName, 'valuelim', ...
        valueLim);
    com = char(['epochhed(EEG, ' ...
        '''' querystring ''', ', ...
        '''timelim'', ''', vector2str(timelim) ', ' ...
        '''exclusivetags'', ''' cellstr2str(exclusiveTags) ''', ' ...
        '''newname'', ''' newName ''', ' ...
        '''valuelim'', ' vector2str(valueLim) ')']);
    return;
end

[EEG, indices] = epochhed(EEG, querystring, varargin{:});
com = char(['pop_epochhed(EEG, ' ...
    '''' querystring ''', ', ...
    '''timelim'', ''', vector2str(timelim) ', '...
    keyvalue2str(varargin{:})]);

    function p = parseArguments(EEG, querystring, varargin)
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('EEG', @(x) ~isempty(x) && isstruct(x));
        p.addRequired('querystring', @(x) ischar(x));
        p.addParamValue('timelimits', [-1 2], @(x) isnumeric(x) && ...
            numel(x) == 2);
        p.addParamValue('eventindices', 1:length(EEG.event), ...
            @isnumeric); %#ok<NVREPL>
        p.addParamValue('exclusivetags', ...
            {'Attribute/Intended effect', 'Attribute/Offset', ...
            'Attribute/Participant indication'}, @iscellstr); %#ok<NVREPL>
        p.addParamValue('mask', [], ...
            @islogical); %#ok<NVREPL>
        p.addParamValue('newname', [EEG.setname ' epochs'], ...
            @(x) ischar(x)); %#ok<NVREPL>
        p.addParamValue('timeunit', 'points', ...
            @(x) any(strcmpi({'points', 'seconds'}, x))); %#ok<NVREPL>
        p.addParamValue('valuelim', [-inf inf], ...
            @(x) isnumeric(x) && any(numel(x) == [1 2])) %#ok<NVREPL>
        p.addParamValue('verbose', 'on', ...
            @(x) any(strcmpi({'on', 'off'}, x)));  %#ok<NVREPL>
        p.parse(EEG, querystring, varargin{:});
        p = p.Results;
    end % parseArguments

end % pop_epochhed