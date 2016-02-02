% This function downloads the HED schema from the HED repository under
% BigEEGConsortium.
%
% Examples:
%
%                   Download the latest HED schema from the HED repository
%                   under BigEEGConsortium first and then replace the
%                   current HED schema with it.
%
%                   downloadHED();
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

function wikiVersion = downloadHED()
wikiURL = 'https://raw.githubusercontent.com/wiki/BigEEGConsortium/HED/HED-Schema.mediawiki';
wikiPath = [tempdir 'temp.mediawiki'];
websave(wikiPath, wikiURL);
wikiVersion = getWikiHEDVersion(wikiPath);
end % downloadHED