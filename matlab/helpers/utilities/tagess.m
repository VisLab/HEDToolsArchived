% This function takes in a ESS structure and tags it using the CTagger. 
%
% Usage:
%
%   >>  ESS = tagess(ESS);
%
% Input:
%
%   ESS
%                   An ESS structure with or without HED tags.
%
% Output:
%
%   ESS
%                   An ESS structure that is newly tagged from the CTagger.
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

function ESS = tagess(ESS)
EEG = struct('event', [], 'etc', []);
EEG = ess2eeg(ESS, EEG);
EEG = tageeg(EEG);
ESS = eeg2ess(EEG, ESS);

    function EEG = ess2eeg(ESS, EEG)
        % Copy tags from ESS structure into EEG structure
        numEvents = length(ESS.eventCodesInfo);
        for a = 1:numEvents
            EEG.event(a).type = ESS.eventCodesInfo(a).code;
            values(a).code = ESS.eventCodesInfo(a).code; %#ok<AGROW>
            values(a).tags = ...
                tagList.deStringify(ESS.eventCodesInfo(a).condition.tag); %#ok<AGROW>
        end
        map = struct('field', 'type', 'values', values);
        EEG.etc.tags = struct('xml', '', 'map', map);
    end % ess2eeg

    function ESS = eeg2ess(EEG, ESS)
        % Copy tags from EEG structure into ESS structure
        numEvents = length(EEG.etc.tags.map(1).values);
        for a = 1:numEvents
            ESS.eventCodesInfo(a).condition.tag = ...
                tagList.stringify(EEG.etc.tags.map(1).values(a).tags);
        end
    end % eeg2ess

end % tagess