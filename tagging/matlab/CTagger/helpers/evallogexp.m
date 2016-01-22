% This function evaluates a tag search string using eval.
%
% Usage:
%   >>  tagsFound = evallogexp(exp, tags, nonGrouptags, groupTags)
%
% Inputs:
%
%  exp           A short-circuit logical expression that will be evaluated.
%
%  tags          A cellstr containing all event tags.
%
%  nonGrouptags  A cellstr containing all event non-group tags.
%
%  groupTags     A cellstr containing all event group tags.
%
% Outputs:
%
%  tagsFound     True, if the tags are found. False, if otherwise.
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function tagsFound = evallogexp(exp, tags, nonGrouptags, ...
    groupTags) %#ok<INUSD>
tagsFound = evaluateExpression(exp);

    function tagsFound = evaluateExpression(expression)
        % This function evaluates an expression using eval
        tagsFound = false;
        try
            tagsFound = eval(expression);
        catch
        end
    end  % evaluateExpression

end % evallogexp