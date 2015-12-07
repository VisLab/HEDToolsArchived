% This function validates a HED XML file against a HED XML schema file.
% The warnings and errors generated from the validation will be written to
% two separated files.
%
% Usage:
%   >>  validatehed(schema, hed);
%   >>  validatehed(schema, hed, varargin);
%
% Input:
%       'schema'    The name or the path to the HED XML schema file used
%                   to define the structure and constraints of the HED
%                   XML file.
%       'hed'       The name or the path to the HED XML file containing all
%                   of the tags.
%       Optional:
%       'output'    The path to the directory that the output is written
%                   to. The output will be written to two files. One file
%                   will contain the warnings generated and other file will
%                   contain the errors generated. The warnings file name
%                   will be the 'hed' file name with _wrn appended to the
%                   end of it with .txt as its extension. The errors file
%                   will be the 'hed' file name with _err appended to the
%                   end of it with .txt as its extension. If 'output' is
%                   not specified then the 'output' directory path will be
%                   the same as the 'hed' file directory path.
%
% Examples:
%                   To validate a HED XML file 'HED2.026.xml' against
%                   the HED XML schema file 'HEDSchema2.026.xsd'.
%
%                   validatehed('HEDSchema2.026.xsd', 'HED2.026.xml');
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


function validatehed(schema, hed, varargin)
p = parseArguments();
addJars();
writeOutput();

    function writeOutput()
        % Writes the warnings and errors to their respective files
        dir = p.Output;
        [~, file, ext] = fileparts(p.Hed);
        errorsFile = fullfile(dir, [file '_err' ext]);
        warningsFile = fullfile(dir, [file '_wrn' ext]);
        xmlValidator = edu.utsa.hedschema.XMLValidator(schema, hed, ...
            warningsFile, errorsFile);
        xmlValidator.validateXml();
    end  % writeOutput

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('Schema', @(x) ~isempty(x) && ischar(x));
        p.addRequired('Hed', @(x) ~isempty(x) && ischar(x));
        dir = fileparts(hed);
        p.addOptional('Output', dir, @(x) ~isempty(x) && ischar(x));
        p.parse(schema, hed, varargin{:});
        p = p.Results;
    end % parseArguments

end % validatehed