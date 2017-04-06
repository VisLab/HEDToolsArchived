% Adds the paths needed to run the HEDTools, including the java paths. This
% script will need to be called if the HEDTools is not being used as an
% EEGLAB plug-in. 
%
% Copyright (C) 2012-2013
% Jeremy Cockfield, UTSA, jeremy.cockfield@gmail.com
% Kay Robbins, UTSA, kay.robbins@utsa.edu
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1.07 USA

wPath = which('eeglab.m');
if ~isempty(wPath)
    addhedpaths(true)
    fprintf('Using %s for eeglab\n', wPath);
    return;
else
    addhedpaths(false);
end