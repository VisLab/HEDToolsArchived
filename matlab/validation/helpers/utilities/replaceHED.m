% This function replaces the current HED schema from the one in the HED
% repository under BigEEGConsortium.
%
% Examples:
%
%                   Download the latest HED schema from the HED repository
%                   under BigEEGConsortium first and then replace the
%                   current HED schema with it.
%
%                   downloadLatestHED();
%                   replaceHED();
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function replaceHED()
HED = 'HED.xml';
wikiPath = [tempdir 'temp.mediawiki'];
hedAttributes = 'HEDMaps.mat';
hedPath = which(HED);
hedMapsPath = strrep(hedPath, HED, hedAttributes);
wiki2XML(wikiPath, hedPath);
delete(wikiPath);
hedMaps = mapHEDAttributes(hedPath); %#ok<NASGU>
save(hedMapsPath, 'hedMaps');
end % replaceHED