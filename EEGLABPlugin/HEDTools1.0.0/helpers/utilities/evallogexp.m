% This function evaluates a tag search string using eval.
%
% Usage:
%
%   >>  tagsFound = evallogexp(exp, tags, nonGrouptags, groupTags)
%
% Input:
%
%   expression
%                A short-circuit logical expression that will be evaluated.
%
%   tags
%                A cellstr containing all event tags.
%
%   nonGrouptags
%                A cellstr containing all event non-group tags.
%
%   groupTags
%                A cellstr containing all event group tags.
%
% Output:
%
%   tagsFound     True if the tags are found. False if otherwise.
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

function tagsFound = evallogexp(expression, tags, nonGrouptags, ...
    groupTags) %#ok<INUSD>
tagsFound = false;
if ~isempty(expression)
    try
        tagsFound = eval(expression);
    catch
        warning('Unable to evaluate search string');
    end
end
end % evallogexp