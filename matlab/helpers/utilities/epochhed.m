% This function will extract data epochs time locked to events that contain
% specified HED tags. The HED tags are assumed to be stored in the
% .event.usertags and/or .event.hedtags field of EEG structure passed in.
%
% Usage:
%
%   >> EEG = epochhed(EEG, tagstring, timelimits)
%
%   >> EEG = epochhed(EEG, tagstring, timelimits, varargin)
%
% Inputs:
%
%   EEG
%                Input dataset. Data may already be epoched; in this case,
%                extract (shorter) subepochs time locked to epoch events.
%                The dataset is assumed to be tagged and has a .usertags
%                and/or .hedtags fields in the .event structure.
%
%   tagstring
%                A comma separated list of HED tags that you want to search
%                for. All tags in the list must be present in the HED
%                string.
%
%   timelimits
%                Epoch latency limits [start end] in seconds relative to
%                the time-locking event. The default is [-1 2].
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
%   'newname'
%                New dataset name. The default is "[old_dataset] epochs"
%
%   'valuelim'
%                [min max] data limits. If one positive value is given,
%                the opposite value is used for lower bound. For example,
%                use [-50 50] to remove artifactual epoch. The default is
%                [-Inf Inf].
%
%   'verbose'
%                ['on'|'off']. The default is 'on'.
%
% deprecated
%
%   'timeunit'
%                Time unit ['seconds'|'points'] If 'seconds,' consider
%                events times to be in seconds. If 'points,' consider
%                events as indices into the data array. The default is
%                'points'.
% Outputs:
%
%   EEG
%                Output dataset that has extracted data epochs.
%
%   indices
%                The indices of accepted events.  
%
%   epochHedStrings
%                A cell array of HED strings associated with the
%                time-locking event for each epoch.
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

function [EEG, indices, epochHedStrings] = epochhed(EEG, tagstring, ...
    timelimits, varargin)
parsedArguments = parseArguments(EEG, tagstring, timelimits, varargin{:});
hedStringsArray = arrayfun(@concattags, parsedArguments.EEG.event, ...
    'UniformOutput', false);
hedStringMatchIndices = cellfun(@(x) findhedevents(x, tagstring, ...
    'exclusivetags', parsedArguments.exclusivetags), hedStringsArray);
parsedArguments.allLatencies = [parsedArguments.EEG.event.latency];
parsedArguments.matchedLatencies = ...
    parsedArguments.allLatencies(hedStringMatchIndices);
parsedArguments = epochData(parsedArguments);
parsedArguments = updateFields(parsedArguments);
parsedArguments = duplicateEvents(parsedArguments);
parsedArguments = modifyEvents(parsedArguments);
parsedArguments = checkBoundaryEvents(parsedArguments);
EEG = parsedArguments.EEG;
indices = parsedArguments.acceptedEventIndecies;
hedStringMatchPositions = find(hedStringMatchIndices);
hedStringAcceptedIndices= hedStringMatchPositions(indices);
epochHedStrings = hedStringsArray(hedStringAcceptedIndices);


    function parsedArguments = checkBoundaryEvents(parsedArguments)
        % Check for boundary events
        disp('hed_epoch(): checking epochs for data discontinuity');
        if ~isempty(parsedArguments.EEG.event) && ...
                ischar(parsedArguments.EEG.event(1).type)
            tmpevent = parsedArguments.EEG.event;
            boundaryindex = strmatch('boundary', ...
                { tmpevent.type }); %#ok<MATCH2>
            if ~isempty(boundaryindex)
                indexepoch = [];
                for tmpindex = boundaryindex
                    if isfield(tmpevent, 'epoch')
                        indexepoch = [indexepoch ...
                            tmpevent(tmpindex).epoch]; %#ok<AGROW>
                    else
                        indexepoch = 1; % only one epoch
                    end
                end
                parsedArguments.EEG = pop_select(parsedArguments.EEG, ...
                    'notrial', indexepoch);
                parsedArguments.acceptedEventIndecies = ...
                    parsedArguments.acceptedEventIndecies(setdiff(...
                    1:length(parsedArguments.acceptedEventIndecies), ...
                    indexepoch));
            end
        end
    end % checkBoundaryEvents

    function parsedArguments = duplicateEvents(parsedArguments)
        % Count the number of events to duplicate and duplicate them
        totlen = 0;
        for index=1:parsedArguments.EEG.trials, ...
                totlen = totlen + ...
                length(parsedArguments.epochevent{index});
        end
        parsedArguments.EEG.event(1).epoch = 0;
        if totlen ~= 0
            parsedArguments.newevent(totlen) = ...
                parsedArguments.EEG.event(1);
        else
            parsedArguments.newevent = [];
        end
    end % duplicateEvents

    function parsedArguments = epochData(parsedArguments)
        % Epoch the data based on the event latencies
        if isempty(parsedArguments.matchedLatencies)
            fprintf(['pop_epoch(): empty epoch range (no epochs were' ...
                ' found).\n']);
        end;
        fprintf('hed_epoch():%d epochs selected\n', ...
            length(parsedArguments.matchedLatencies));
        switch lower(parsedArguments.timeunit)
            case 'points',
                [parsedArguments.EEG.data, ...
                    parsedArguments.newtimelimts, ...
                    parsedArguments.acceptedEventIndecies, ...
                    parsedArguments.epochevent] = ...
                    epoch(parsedArguments.EEG.data, ...
                    parsedArguments.matchedLatencies, ...
                    [parsedArguments.timelimits(1) ...
                    parsedArguments.timelimits(2)]*...
                    parsedArguments.EEG.srate, ...
                    'valuelim', parsedArguments.valuelim, 'allevents', ...
                    parsedArguments.allLatencies, ...
                    'verbose', parsedArguments.verbose);
                parsedArguments.newtimelimts = ...
                    parsedArguments.newtimelimts/parsedArguments.EEG.srate;
            case 'seconds',
                [parsedArguments.EEG.data, ...
                    parsedArguments.newtimelimts, ...
                    parsedArguments.acceptedEventIndecies, ...
                    parsedArguments.epochevent] = ...
                    epoch(parsedArguments.EEG.data, ...
                    parsedArguments.matchedLatencies, ...
                    parsedArguments.timelimits, ...
                    'valuelim', parsedArguments.valuelim, 'srate', ...
                    parsedArguments.EEG.srate, ...
                    'allevents', parsedArguments.allLatencies, ...
                    'verbose', parsedArguments.verbose);
            otherwise, disp('hed_epoch(): invalid event time format'); ...
                    beep; return;
        end
        parsedArguments.matchedLatencies = ...
            parsedArguments.matchedLatencies(...
            parsedArguments.acceptedEventIndecies);
        fprintf('hed_epoch():%d epochs generated\n', ...
            length(parsedArguments.acceptedEventIndecies));
    end % epochData

    function parsedArguments = modifyEvents(parsedArguments)
        % Modify the event structure accordingly (latencies and add epoch
        % field)
        count = 1;
        for index=1:parsedArguments.EEG.trials
            for indexevent = parsedArguments.epochevent{index}
                parsedArguments.newevent(count) = ...
                    parsedArguments.EEG.event(indexevent);
                parsedArguments.newevent(count).epoch = index;
                parsedArguments.newevent(count).latency = ...
                    parsedArguments.newevent(count).latency ...
                    - parsedArguments.matchedLatencies(index) - ...
                    parsedArguments.newtimelimts(1)*...
                    parsedArguments.EEG.srate + 1 + ...
                    parsedArguments.EEG.pnts*(index-1);
                count = count + 1;
            end
        end
        parsedArguments.EEG.event = parsedArguments.newevent;
        parsedArguments.EEG.epoch = [];
        parsedArguments.EEG = eeg_checkset(parsedArguments.EEG, ...
            'eventconsistency');
    end % modifyEvents

    function p = parseArguments(EEG, tagstring, timelimits, varargin)
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('EEG', @(x) ~isempty(x) && isstruct(x));
        p.addRequired('tagstring', @(x) ischar(x));
        p.addRequired('timelimits', @(x) isnumeric(x) && ...
            numel(x) == 2);
        p.addParamValue('eventindices', 1:length(EEG.event), ...
            @isnumeric); %#ok<NVREPL>
        p.addParamValue('exclusivetags', ...
            {'Attribute/Intended effect', 'Attribute/Offset'}, ...
            @iscellstr); %#ok<NVREPL>
        p.addParamValue('newname', [EEG.setname ' epochs'], ...
            @(x) ischar(x)); %#ok<NVREPL>
        p.addParamValue('timeunit', 'points', ...
            @(x) any(strcmpi({'points', 'seconds'}, x))); %#ok<NVREPL>
        p.addParamValue('valuelim', [-inf inf], ...
            @(x) isnumeric(x) && any(numel(x) == [1 2])) %#ok<NVREPL>
        p.addParamValue('verbose', 'on', ...
            @(x) any(strcmpi({'on', 'off'}, x)));  %#ok<NVREPL>
        p.parse(EEG, tagstring, timelimits, varargin{:});
        p = p.Results;
    end % parseArguments

    function parsedArguments = updateFields(parsedArguments)
        % Update other fields
        if parsedArguments.timelimits(1) ~= ...
                parsedArguments.newtimelimts(1) && ...
                parsedArguments.timelimits(2)-1/parsedArguments.EEG.srate ...
                ~= parsedArguments.newtimelimts(2)
            fprintf(['hed_epoch(): time limits have been adjusted to' ...
                ' [%3.3f %3.3f] to fit data points limits\n'], ...
                parsedArguments.newtimelimts(1), ...
                parsedArguments.newtimelimts(2)+1/...
                parsedArguments.EEG.srate);
        end
        parsedArguments.EEG.xmin = parsedArguments.newtimelimts(1);
        parsedArguments.EEG.xmax = parsedArguments.newtimelimts(2);
        parsedArguments.EEG.pnts = size(parsedArguments.EEG.data,2);
        parsedArguments.EEG.trials = size(parsedArguments.EEG.data,3);
        parsedArguments.EEG.icaact = [];
        if ~isempty(parsedArguments.EEG.setname)
            if ~isempty(parsedArguments.EEG.comments)
                parsedArguments.EEG.comments = ...
                    strvcat(['Parent dataset "' ...
                    parsedArguments.EEG.setname '": ----------'], ...
                    parsedArguments.EEG.comments); %#ok<DSTRVCT>
            end
            parsedArguments.EEG.comments = strvcat(['Parent dataset: ' ...
                parsedArguments.EEG.setname ], ' ', ...
                parsedArguments.EEG.comments); %#ok<DSTRVCT>
        end
        parsedArguments.EEG.setname = parsedArguments.newname;
    end % updateFields

end % epochhed