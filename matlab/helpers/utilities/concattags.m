% Concatenates the event .usertags and .hedtags fields if they are
% available.
%
% Usage:
%
%   >>  tags = concattags(event)
%
% Input:
%
%   Required:
%
%   event
%                    A event structure that contains a .usertags and/or
%                    .hedtags field. 
%
% Output:
%
%   tags
%                    A concatenated string consisting of the .usertags and
%                    .hedtags fields if they are available. If neither are
%                    present a empty string is returned. 
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

function tags = concattags(event)
if fieldAvailable(event, 'usertags') && ...
        fieldAvailable(event, 'hedtags')
    tags = [event.usertags ',' event.hedtags];
elseif fieldAvailable(event, 'usertags') && ...
        ~fieldAvailable(event, 'hedtags')
    tags = event.usertags;
elseif ~fieldAvailable(event, 'usertags') && ...
        fieldAvailable(event, 'hedtags')
    tags = event.hedtags;
elseif ~fieldAvailable(event, 'usertags') && ...
        ~fieldAvailable(event, 'hedtags')
    tags = '';
end

    function available = fieldAvailable(event, fieldName)
        % True if the field is present and not empty
        available = isfield(event, fieldName) && ...
            ~isempty(event.(fieldName));
    end % fieldAvailable

end % concattags