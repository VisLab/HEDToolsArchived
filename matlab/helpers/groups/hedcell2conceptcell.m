% Converts a hed cell, output from hedstring2cell, to a similar
% structure but with certain tags grouped inside special structures, having
% a field called 'concept', this allows assigning attributes to multiples
% items (and making concepts), e.g. 'Item/1, Attribute/A, Item/2' to be
% converted to concept[Item/1, Attribute/A], concept[Item/2, Attribute/A].
% special attributes, such as Attribute/Intended effect can be dealth with
% better this way... we then compare the concept cells together for HED
% query matching.
%
% Usage:
%
%   >>  hedConceptCell = hedcell2conceptcell(hedCell)
%
% Input:
%
%   hedCell
%                    A cell array containing a HED tags.
%
% Output:
%
%   hedConceptCell
%                    A concept cell array.
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

function hedConceptCell = hedcell2conceptcell(hedCell)
if ischar(hedCell)
    hedConceptCell = hedCell;
elseif isstruct(hedCell)
elseif iscell(hedCell)
    primaryTags  = {'Item' 'Attribute/'};
    attributeMask = false(length(hedCell), 1);
    primaryMask = attributeMask;
    
    for i=1:length(hedCell)
        attributeMask(i) =  ischar(hedCell{i}) &&  hed_tag_match(hedCell{i}, 'Attribute');
        primaryMask(i) =  ischar(hedCell{i}) &&  hed_tag_match(hedCell{i}, 'Item');
    end;
    
    ItemIds = find(primaryMask);
    for i = 1:length(ItemIds)
        concept{i}.primaryTag = hedCell{ItemIds(i)};
        concept{i}.attributes = hedCell(attributeMask);
    end;
    
    hedCell(primaryMask | attributeMask) = [];
    hedConceptCell = [hedCell concept];
end; % hedcell2conceptcell