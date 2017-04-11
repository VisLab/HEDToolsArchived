% This function takes in a group tag string and converts it into a cell
% array or structure array based on the number of tildes.
%
% Usage:
%
%   >>  newBody = processtildes(body, format, keepTildes)
%
% Input:
%
%   body
%                   A tag string containing a group.
%
%   groupFormat
%                   The options are 'cell' or 'struct'. The 'cell' option
%                   converts a group tag string into a cell array. The
%                   'struct' option converts a group tag string into
%                   stucture array. The structure array has three fields
%                   representing 'subject', 'verb', and 'object'
%
%   keepTildes
%                   If the 'cell' format option is selected and
%                   'keepTildes' is true, then the tildes are kept inside
%                   the cell array. If false, the tildes are removed.
%
% Output:
%
%   newBody
%                   A cell array containing the group tags that have been
%                   processed.
%
% Copyright (C) 2015 Nima Bigdely-Shamlo nima.bigdely@qusp.io,
% Jeremy Cockfield, UTSA jeremy.cockfield@gmail.com, and
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

function newBody = processtildes(body, groupFormat, keepTildes)
if strcmpi(groupFormat, 'cell') && keepTildes
    newBody = splitWithTildes(body);
    return;
end
tildeParts = strsplit(body, '~');
switch length(tildeParts)  % there are some tildes
    case 1 % no tildes
        newBody = body;
    case 2 % subject ~ verb
        newBody = splitWithoutTildes(tildeParts, 2, groupFormat);
    case 3 % subject ~ verb ~ object
        newBody = splitWithoutTildes(tildeParts, 3, groupFormat);
    otherwise
        error('There are too many tildes in %s.', body);
end

    function newBody = splitWithoutTildes(tildeParts, tildeCount, format)
        % Returns a cell array or struct with tildes
        triplet = {'subject', 'verb', 'object'};
        for a = 1:tildeCount
            if strcmpi(format, 'cell')
                newBody{a} = hedstring2cell(tildeParts{a}); %#ok<AGROW>
            else
                newBody.(triplet{a}) = hedstring2cell(tildeParts{a});
            end
        end
    end % splitWithoutTildes

    function newBody = splitWithTildes(body)
        % Returns a cell array with tildes
        [token, remain] = strtok(body, '~');
        if isempty(remain)
            newBody = body;
            return;
        end
        newBody{1} = hedstring2cell(token, 'keepTildes', true);
        newBody = unnestCell(newBody, 1);
        index = 2;
        while ~isempty(remain)
            newBody{index} = '~';
            index = index + 1;
            [token, remain] = strtok(remain, '~'); %#ok<STTOK>
            newBody{index} = hedstring2cell(token, 'keepTildes', ...
                true);
            newBody = unnestCell(newBody, index);
            index = length(newBody) +1;
        end
    end % splitWithTildes

    function unnestedCellArray = unnestCell(cellArray, pos)
        unnestedCellArray = cellArray;
        numElements = length(cellArray);
        nestedElements = cellArray{pos};
        if ~strncmp('@id_',nestedElements,4)
            unnestedCellArray = nestedElements;
            if pos > 1
                unnestedCellArray = [cellArray(1:pos-1) unnestedCellArray];
            end
            if pos < numElements
                unnestedCellArray = [unnestedCellArray ...
                    cellArray(pos+1:end)];
            end
            if ischar(unnestedCellArray)
                unnestedCellArray = {unnestedCellArray};
            end
        end
    end

end % processtildes