% getutypes
% Returns a cell array with the unique values in the type field of estruct
%
% Usage:
%   >>  tValues = getutypes(estruct, type)
%
% Description:
% tValues = getutypes(estruct, type) returns a cell array with the unique
% values in the type field of estruct
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for getutypes:
%
%    doc getutypes
%
% See also: tageeg, tageeg_input, pop_tageeg
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
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
%
% $Log: getutypes.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function tValues = getutypes(estruct, type)
tValues = {};
if ~isstruct(estruct) || ~isfield(estruct, type)
    return;
end
try
    values = {estruct.(type)};
    isNum = cell2mat(cellfun(@isnumeric, values, 'UniformOutput', false));
    tValues = unique(cellfun(@num2str, values, 'UniformOutput', false));
    if sum(isNum) > 0 && sum(~cellfun(@isempty, strfind(tValues, '.'))) > 0
        tValues = {};
        return;
    end
    tEmpty = cellfun(@isempty, tValues);
    tValues(tEmpty) = [];
    tNaN = strcmpi('NaN', tValues);
    tValues(tNaN) = [];
catch ME %#ok<NASGU>
end
end % getutypes

