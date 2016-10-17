% This function will extract data epochs time locked to events that contain
% specified HED tags. The event tags are assumed to be stored in the
% .event.usertags field of EEG structure passed in.
%
% Usage:
%
%   >> EEG = epochhed(EEG, tags)
%
%   >> EEG = epochhed(EEG, tags, varargin)
%
% Inputs:
%
%   EEG          Input dataset. Data may already be epoched; in this case,
%                extract (shorter) subepochs time locked to epoch events.
%                The dataset is assumed to be tagged and has a .usertags
%                field in the .event structure.
%   tags         A search string consisting of tags to extract data epochs.
%                The tag search uses boolean operators (AND, OR, NOT) to
%                widen or narrow the search. Two tags separated by a comma
%                use the AND operator by default which will only return
%                events that contain both of the tags. The OR operator
%                looks for events that include either one or both tags
%                being specified. The NOT operator looks for events that
%                contain the first tag but not the second tag. To nest or
%                organize the search statements use square brackets.
%                Nesting will change the order in which the search
%                statements are evaluated. For example,
%                "/attribute/visual/color/green AND
%                [/item/2d shape/rectangle/square OR
%                /item/2d shape/ellipse/circle]".
%
% Optional inputs:
%
%   'newname'    New dataset name. The default is "[old_dataset] epochs"
%
%   'timelim'    Epoch latency limits [start end] in seconds relative to
%                the time-locking event. The default is [-1 2].
%   'valuelim'   [min max] data limits. If one positive value is given,
%                the opposite value is used for lower bound. For example,
%                use [-50 50] to remove artifactual epoch. The default is
%                [-Inf Inf].
%
%   'verbose'    ['on'|'off']. The default is 'on'.
%
% deprecated
%
%   'timeunit'   Time unit ['seconds'|'points'] If 'seconds,' consider
%                events times to be in seconds. If 'points,' consider
%                events as indices into the data array. The default is
%                'points'.
% Outputs:
%
%   EEG          Output dataset that has extracted data epochs.
%
% Copyright (C) 2012-2016 Thomas Rognon tcrognon@gmail.com,
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

function [EEG, indices] = epochhed(EEG, tags, varargin)
p = parseArguments();
indices = findhedevents(EEG, 'tags', tags);
allLatencies = [EEG.event.latency];
matchedLatencies = allLatencies(indices);
[newtimelimts, acceptedEventIndecies, epochevent] = epochData();
updateFields();
newevent = duplicateEvents();
modifyEvents();
checkBoundaryEvents();

    function checkBoundaryEvents()
        % Check for boundary events
        disp('hed_epoch(): checking epochs for data discontinuity');
        if ~isempty(EEG.event) && ischar(EEG.event(1).type)
            tmpevent = EEG.event;
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
                EEG = pop_select(EEG, 'notrial', indexepoch);
                acceptedEventIndecies = acceptedEventIndecies(setdiff(...
                    1:length(acceptedEventIndecies),indexepoch));
            end
        end
    end % checkBoundaryEvents

    function newevent = duplicateEvents()
        % Count the number of events to duplicate and duplicate them
        totlen = 0;
        for index=1:EEG.trials, ...
                totlen = totlen + length(epochevent{index}); end
        EEG.event(1).epoch = 0;
        if totlen ~= 0
            newevent(totlen) = EEG.event(1);
        else
            newevent = [];
        end
    end % duplicateEvents

    function [newtimelimts, acceptedEventIndecies, epochevent] = ...
            epochData()
        % Epoch the data based on the event latencies
        if isempty(matchedLatencies)
%             error('pop_epoch(): empty epoch range (no epochs were found).');
            fprintf('pop_epoch(): empty epoch range (no epochs were found).\n');
        end;
        fprintf('hed_epoch():%d epochs selected\n', ...
            length(matchedLatencies));
        switch lower(p.timeunit)
            case 'points',
                [EEG.data, newtimelimts, acceptedEventIndecies, ...
                    epochevent] = epoch(EEG.data, matchedLatencies, ...
                    [p.timelim(1) p.timelim(2)]*EEG.srate, ...
                    'valuelim', p.valuelim, 'allevents', allLatencies, ...
                    'verbose', p.verbose);
                newtimelimts = newtimelimts/EEG.srate;
            case 'seconds',
                [EEG.data, newtimelimts, acceptedEventIndecies, ...
                    epochevent] = ...
                    epoch(EEG.data, matchedLatencies, p.timelim, ...
                    'valuelim', p.valuelim, 'srate', EEG.srate, ...
                    'allevents', allLatencies, 'verbose', p.verbose);
            otherwise, disp('hed_epoch(): invalid event time format'); ...
                    beep; return;
        end
        matchedLatencies = matchedLatencies(acceptedEventIndecies);
        fprintf('hed_epoch():%d epochs generated\n', ...
            length(acceptedEventIndecies));
    end % epochData

    function modifyEvents()
        % Modify the event structure accordingly (latencies and add epoch
        % field)
        count = 1;
        for index=1:EEG.trials
            for indexevent = epochevent{index}
                newevent(count) = EEG.event(indexevent);
                newevent(count).epoch = index;
                newevent(count).latency = newevent(count).latency ...
                    - matchedLatencies(index) - ...
                    newtimelimts(1)*EEG.srate + 1 + EEG.pnts*(index-1);
                count = count + 1;
            end
        end
        EEG.event = newevent;
        EEG.epoch = [];
        EEG = eeg_checkset(EEG, 'eventconsistency');
    end % modifyEvents

    function p = parseArguments()
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('EEG', @(x) ~isempty(x) && isstruct(x));
        p.addRequired('tags', @(x) ischar(x));
        p.addParamValue('matchtype', 'Exact', ...
            @(x) any(strcmpi({'Exact', 'Prefix'}, ...
            x))); %#ok<NVREPL>
        p.addParamValue('newname', [EEG.setname ' epochs'], ...
            @(x) ischar(x)); %#ok<NVREPL>
        p.addParamValue('timelim', [-1 2], ...
            @(x) isnumeric(x) && numel(x) == 2);  %#ok<NVREPL>
        p.addParamValue('timeunit', 'points', ...
            @(x) any(strcmpi({'points', 'seconds'}, x))); %#ok<NVREPL>
        p.addParamValue('valuelim', [-inf inf], ...
            @(x) isnumeric(x) && any(numel(x) == [1 2])) %#ok<NVREPL>
        p.addParamValue('verbose', 'on', ...
            @(x) any(strcmpi({'on', 'off'}, x)));  %#ok<NVREPL>
        p.parse(EEG, tags, varargin{:});
        p = p.Results;
    end % parseArguments

    function updateFields()
        % Update other fields
        if p.timelim(1) ~= newtimelimts(1) && ...
                p.timelim(2)-1/EEG.srate ~= newtimelimts(2)
            fprintf(['hed_epoch(): time limits have been adjusted to' ...
                ' [%3.3f %3.3f] to fit data points limits\n'], ...
                newtimelimts(1), newtimelimts(2)+1/EEG.srate);
        end
        EEG.xmin = newtimelimts(1);
        EEG.xmax = newtimelimts(2);
        EEG.pnts = size(EEG.data,2);
        EEG.trials = size(EEG.data,3);
        EEG.icaact = [];
        if ~isempty(EEG.setname)
            if ~isempty(EEG.comments)
                EEG.comments = strvcat(['Parent dataset "' ...
                    EEG.setname '": ----------'], ...
                    EEG.comments); %#ok<DSTRVCT>
            end
            EEG.comments = strvcat(['Parent dataset: ' ...
                EEG.setname ], ' ', EEG.comments); %#ok<DSTRVCT>
        end
        EEG.setname = p.newname;
    end % updateFields

end % epochhed