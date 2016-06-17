% This function validates a HED XML file against a HED XML schema file.
% The warnings and errors generated from the validation will be written to
% two separated files.
%
% Usage:
%   >>  [errors, warnings] = validateHED(hedSchema, hedXML);
%
%   >>  [errors, warnings] = validateHED(hedSchema, hedXML, varargin);
%
% Input:
%
%       hedSchema
%                   The name or the path to the HED XML schema file used
%                   to define the structure and constraints of the HED
%                   XML file.
%
%       hedXML
%                   The name or the path to the HED XML file containing all
%                   of the tags.
%
%       Optional:
%
%       'outputDirectory'
%                   The path to the directory that the output is written
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
%       'writeOutput'
%                   If false(default) the validation output is not written
%                   to separate files. If true the validation output is
%                   written to separate files.
%
% Output:
%
%       errors
%                   A cell array containing all of the validation errors.
%                   Each cell is associated with the validation errors on a
%                   particular line.
%
%       warnings
%                   A cell array containing all of the validation warnings.
%                   Each cell is associated with the validation warnings on
%                   a particular line.
%
% Examples:
%
%                   To validate a HED XML file 'HED2.026.xml' against
%                   the HED XML schema file 'HEDSchema2.026.xsd'.
%
%                   validatehed('HEDSchema2.026.xsd', 'HED2.026.xml');
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

function [errors, warnings] = validateHED(hedSchema, hedXML, varargin)
p = parseArguments();
addJars();
validator = edu.utsa.hedschema.XMLValidator(hedSchema, hedXML);
validator.validateXml();
errors = cell(validator.getErrors())';
warnings = cell(validator.getWarnings())';
if p.writeOutput
    writeOutputFiles();
end

    function p = parseArguments()
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('hedSchema', @(x) ~isempty(x) && ischar(x) && ...
            exist(hedSchema, 'file') == 2);
        p.addRequired('hedXML', @(x) ~isempty(x) && ischar(x) && ...
            exist(hedXML, 'file') == 2);
        dir = fileparts(hedXML);
        p.addOptional('outputDirectory', dir, ...
            @(x) ~isempty(x) && ischar(x));
        p.addParamValue('writeOutput', false, @islogical);
        p.parse(hedSchema, hedXML, varargin{:});
        p = p.Results;
    end % parseArguments

    function writeErrorFile(dir, file, ext)
        % Writes the errors to a file
        numErrors = size(errors, 2);
        errorFile = fullfile(dir, [file '_err' ext]);
        fileId = fopen(errorFile,'w');
        for a = 1:numErrors
            fprintf(fileId, '%s\n', errors{a});
        end
        fclose(fileId);
    end % writeErrorFile

    function writeOutputFiles()
        % Writes the errors, warnings, extension allowed warnings to
        % the output files
        dir = p.outputDirectory;
        [~, file] = fileparts(p.tsvFile);
        ext = '.txt';
        writeErrorFile(dir, file, ext);
        writeWarningFile(dir, file, ext);
    end % writeOutputFiles

    function writeWarningFile(dir, file, ext)
        % Writes the warnings to a file
        numWarnings = size(warnings, 2);
        warningFile = fullfile(dir, [file '_wrn' ext]);
        fileId = fopen(warningFile,'w');
        for a = 1:numWarnings
            fprintf(fileId, '%s\n', warnings{a});
        end
        fclose(fileId);
    end % writeWarningFile

end % validateHED