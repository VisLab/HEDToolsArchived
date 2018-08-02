% This function will extract data epochs time locked to events that contain
% specified HED tags. The HED tags are assumed to be stored in the
% .event.usertags and/or .event.hedtags field of EEG structure passed in.
%
% Usage:
%
%   >> EEG = extractEpochs(EEG, mask)
%
% Inputs:
%
%   EEG
%                Input dataset. Data may already be epoched; in this case,
%                extract (shorter) subepochs time locked to epoch events.
%                The dataset is assumed to be tagged and has a .usertags
%                and/or .hedtags fields in the .event structure.
%
%   mask  
%                A logical array the length of hedStrings with true values
%                where hedStrings matched queryHedString.
%
% Outputs:
%
%   EEG
%                Output dataset that has extracted data epochs.
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

function EEG = extractEpochs(EEG, mask)
parseArguments(EEG, mask);
EEG = epochhed(EEG, '', 'mask', mask);

  function p = parseArguments(EEG, mask)
        % Parses the arguments passed in and returns the results
        p = inputParser();
        p.addRequired('EEG', @(x) ~isempty(x) && isstruct(x));
        p.addRequired('mask', @(x) islogical(x));
        p.parse(EEG, mask);
        p = p.Results;
    end % parseArguments

end % extractEpochs