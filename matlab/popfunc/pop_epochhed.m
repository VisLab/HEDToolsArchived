% Allows a user to extract epochs based on HED tags using a GUI.
%
% Usage:
%
%   >>  [EEG, indices, com] = pop_epochhed(EEG);
%
%   >>  [EEG, indices, com] = pop_epochhed(EEG, events, timelimits);
%
%   >>  [EEG, indices, com] = pop_epochhed(EEG, events, timelimits, ...
%                             'key1', value1 ...);
%
%   Graphic interface:
%
%   "Time-locking HED tag(s)"
%                [edit box] Select 'Edit > Event values'
%                to see a list of event.type values; else use the push
%                button. To use event types containing spaces, enter in
%                single-quotes. epoch() function command line equivalent:
%                'typerange'
%
%   "..."
%                [push button] Input HED tag(s) using search bar.
%
%   "Epoch limits"
%                [edit box] epoch latency range [start, end] in seconds
%                relative to the time-locking events. epoch() function
%                equivalent: 'timelim'
%
%   "Name for the new dataset"
%                [edit box] epoch() function equivalent: 'newname'
%
%   "Out-of-bounds EEG ..."
%                [edit box] Rejection limits ([min max], []=none). epoch()
%                function equivalent: 'valuelim'
%
% Inputs:
%
%   EEG
%                Input dataset. Data may already be epoched; in this case,
%                extract (shorter) subepochs time locked to epoch events.
%
%   tags         
%                A search string consisting of tags to extract data epochs.
%                The tag search uses boolean operators (AND, OR, AND NOT)
%                to widen or narrow the search. Two tags separated by a
%                comma use the AND operator by default which will only
%                return events that contain both of the tags. The OR
%                operator looks for events that include either one or both
%                tags being specified. The AND NOT operator looks for
%                events that contain the first tag but not the second tag.
%                To nest or organize the search statements use square
%                brackets. Nesting will change the order in which the
%                search statements are evaluated. For example,
%                "/attribute/visual/color/green AND
%                [/item/2d shape/rectangle/square OR
%                /item/2d shape/ellipse/circle]".
%
%   timelim      Epoch latency limits [start end] in seconds relative to
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [EEG, indices, com] = pop_epochhed(EEG, tags, timelim, varargin)
indices = [];
com = '';
% Display help if inappropriate number of arguments
if nargin < 1
    help pop_epochhed;
    return;
end;


if nargin < 3
    % Find all the unique tags in the events    
    if ~exist('tags','var')
        tags = '';
    end
    uniquetags = finduniquetags(arrayfun(@concattags, EEG.event, ...
        'UniformOutput', false));
    % Get input arguments from GUI
    [canceled, tags, newName, timelim, valueLim] = ...
        epochhed_input(EEG.setname, tags, uniquetags);
    if canceled
        return;
    end
    [EEG, indices] = epochhed(EEG, tags, timelim, 'newname', newName, ...
        'valuelim', valueLim);
    com = char(['epochhed(EEG, ' ...
        '''' tags ''', ', ...
        vector2str(timelim) ', ' ...
        '''newname'', ''' newName ''', ' ...
        '''valuelim'', ' vector2str(valueLim) ')']);
    return;
end

[EEG, indices] = epochhed(EEG, tags, timelim, varargin{:});
com = char(['pop_epochhed(EEG, ' ...
    '''' tags ''', ', ...
    vector2str(timelim) ', '...
    keyvalue2str(varargin{:})]);

end % pop_hedepoch