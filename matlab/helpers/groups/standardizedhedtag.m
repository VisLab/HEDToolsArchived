% This function removes the trailing slashes and converts a tag string to
% lowercase.
%
% Usage:
%
%   >>  tag = standardizedhedtag(tag)
%
% Input:
%
%   tag
%                   A tag string.
%
% Output:
%
%   tag
%                   A tag string that has had the trailing slash removed
%                   and has been converted to lowercase. 
%
% Copyright (C) 2015 Nima Bigdely-Shamlo nima.bigdely@qusp.io
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

function tag = standardizedhedtag(tag)
tag = lower(tag);
if ~isempty(tag) && tag(end) == '/'
    tag = tag(1:(end-1));
end; % standardizedhedtag