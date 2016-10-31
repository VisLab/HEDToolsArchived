% This function takes in a wiki text file containing all of the HED tags,
% their attributes, and unit classes and looks for the version number.
%
% Usage:
%
%   >>  version = getwikiversion(wikiFile)
%
% Input:
%
%   wikiFile        The name or the path of the wiki text file containing
%                   all of the HED tags.
%
% Output:
%
%   version
%                   The version of the wiki file. Will return an empty
%                   string if there is no version number in the file.
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

function version = getwikiversion(wikiFile)
p = parseArguments(wikiFile);
version = '';
try
    fileId = fopen(p.hedWiki);
    wikiLine = fgetl(fileId);
    while ischar(wikiLine)
        if strfind(wikiLine, 'HED version:')
            numericIndexes = ismember(wikiLine, '0123456789.');
            version = wikiLine(numericIndexes);
            break;
        end
        wikiLine = fgetl(fileId);
        lineNumber = lineNumber + 1;
    end
    fclose(fileId);
catch
    fclose(fileId);
    warning('No version was found');
end

    function p = parseArguments(wikiFile)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('hedWiki', @(x) ~isempty(x) && ischar(x) && ...
            2 == exist(x, 'file'));
        p.parse(wikiFile);
        p = p.Results;
    end % parseArguments

end % getwikiversion