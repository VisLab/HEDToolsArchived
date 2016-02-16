% This function takes in a ESS structure and tags it using the ctagger. 
%
% Usage:
%
%   >>  essStruct = tagESS(essStruct);
%
% Input:
%
%       essStruct
%                   An ESS structure containing HED tags.
%
% Output:
%
%       essStruct
%                   An ESS structure that is newly tagged from the ctagger.
%
% Examples:
%                   Tag the ESS structure 'essStruct' with ctagger.
%
%                   essStruct = tagESS(essStruct);
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
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

function essStruct = tagESS(essStruct)
eegStruct = struct('event', []);
eegStruct.event = copyESSTags(essStruct.eventCodes.eventCode);
eegStruct = tageeg(eegStruct);
essStruct.eventCodes.eventCode = ...
    copyEEGTags(essStruct.eventCodes.eventCode, eegStruct.event);

    function eegEventsStruct = copyESSTags(essEvents)
        % Copy tags from ESS events structure into EEG events structure 
        numEvents = length(essEvents);
        eegEventsStruct(numEvents).type = '';
        eegEventsStruct(numEvents).usertags = '';
        for a = 1:numEvents
            eegEventsStruct(a).type = essEvents(a).code;
            eegEventsStruct(a).usertags = essEvents(a).condition.tag;
        end
    end % copyESSTags

    function essEventsStruct = copyEEGTags(essEvents, eegEvents)
        % Copy tags from EEG events structure into ESS events structure
        essEventsStruct = essEvents;
        numEvents = length(essEvents);
        for a = 1:numEvents
            essEventsStruct(a).condition.tag = eegEvents(a).usertags;
        end
    end % copyEEGTags

end % tagESS