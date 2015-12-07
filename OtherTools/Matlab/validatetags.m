% This function takes in a tab-delimited text file containing HED tags 
% associated with a particular study and validates them based on the 
% tags and attributes in the HED XML file.
%
% Usage:
%   >>  validatetags(hed, tags, columns);
%   >>  validatetags(hed, tags, columns, varargin);
%
% Input:
%       'hed'       The name or the path of the HED XML file containing
%                   all of the tags.
%       'tags'      The name or the path of a tab-delimited text file
%                   containing HED tags associated with a particular study.
%       'columns'   The columns that contain the HED study tags. The 
%                   columns can be a scalar value or a vector.
%       Optional:
%       'extensionAllowed'
%                   True (default) if the validation accepts extension 
%                   allowed tags. There will be warnings generated for each
%                   extension allowed tag that is present. If false, the 
%                   validation will not accept extension allowed tags and 
%                   errors will be generated for each tag present. 
%       'header'    True (default)if the tab-delimited text file containing
%                   the HED study tags starts with a header row. This row
%                   will be skipped and not validated. False if the file 
%                   doesn't start with a header row. 
%       'output'    The directory where the output files will be written
%                   to. There will be three files generated containing
%                   the warnings, extension allowed warnings, and errors
%                   generated from the validation.
%
% Examples:
%                   To validate the HED study tags in file 
%                   'LSIE_06_Outdoor_all_events.txt' in the third column
%                   using HED XML file 'HED2.026.xml' to validate them with
%                   no header.
%
%                   validatetags('HED2.026.xml', ...
%                   'LSIE_01_Indoor_all_events.txt', 3, 'Header', false);
%
% Copyright (C) 2015 Jeremy Cockfield jeremy.cockfield@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
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

function validatetags(hed, tags, columns, varargin)
p = parseArguments();
Maps = parsehed(hed);
[errors, warnings, extensions] = ...
    parsetags(Maps, tags, columns, varargin{:});
writeOutput();

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('Hed', @(x) (~isempty(x) && ischar(x)));
        p.addRequired('Tags', @(x) (~isempty(x) && ischar(x)));
        p.addRequired('Columns', @(x) (~isempty(x) && ...
            isa(x,'double') && length(x) >= 1));
        p.addParamValue('ExtensionAllowed', true, ...
            @(x) validateattributes(x, {'logical'}, {})); %#ok<NVREPL>
        p.addParamValue('Header', true, @islogical); %#ok<NVREPL>
        p.addParamValue('Output', fileparts(tags), ...
            @(x) ischar(x) && 7 == exist(x, 'dir')); %#ok<NVREPL>
        p.parse(hed, tags, columns, varargin{:});
        p = p.Results;
    end % parseArguments

    function writeOutput()
        % Writes the warnings, extension allowed warnings, and errors to 
        % the output files
        dir = p.Output;
        [~, file, ext] = fileparts(p.Tags);
        errorFile = fullfile(dir, [file '_err' ext]);
        warningFile = fullfile(dir, [file '_wrn' ext]);
        extensionFile = fullfile(dir, [file '_ext' ext]);
        try
            fileId = fopen(errorFile,'w');
            fprintf(fileId, '%s', errors);
            fclose(fileId);
            fileId = fopen(warningFile,'w');
            fprintf(fileId, '%s', warnings);
            fclose(fileId);
            fileId = fopen(extensionFile,'w');
            fprintf(fileId, '%s', extensions);
            fclose(fileId);
        catch me
            fclose(fileId);
            rethrow(me);
        end
    end % writeOutput

end % validatetags