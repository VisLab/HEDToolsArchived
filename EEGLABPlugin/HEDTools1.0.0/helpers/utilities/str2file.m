% Writes a string to a file. 
%
% Usage:
%
%   >>  str2file(str, file)
%
% Inputs:
%
% Required:
%
%   str
%                    A string that is written to a file.
%
%   file
%                    A file name that the string is written to. This can be
%                    a full path or a file name which gets written to the
%                    current directory. 
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

function str2file(str, file)
try
    fid = fopen(file, 'w');
    if fid == -1
        error('str2file:NoFile', 'no such file exists')
    end
    fprintf(fid, '%s', str);
catch
    disp('Can not write to file')
end
if fid ~= -1
    fclose(fid);
end
end % str2file