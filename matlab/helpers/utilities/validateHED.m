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
%       issues
%                   A cell array containing all of the validation errors.
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

function issues = validatehed(hedSchema, hedXML, varargin)
p = parseArguments(hedSchema, hedXML, varargin{:});
validator = edu.utsa.hedschema.XMLValidator(hedSchema, hedXML);
validator.validateXml();
issues = cell(validator.getErrors())';
if p.generateWarnings
    issues = [issues cell(validator.getWarnings())'];
end
if p.writeOutput
    writeOutputFiles();
end

    function p = parseArguments(hedSchema, hedXML, varargin)
        % Parses the arguements passed in and returns the results
        p = inputParser();
        p.addRequired('hedSchema', @(x) ~isempty(x) && ischar(x) && ...
            exist(hedSchema, 'file') == 2);
        p.addRequired('hedXML', @(x) ~isempty(x) && ischar(x) && ...
            exist(hedXML, 'file') == 2);
        p.addParamValue('generateWarnings', false, ...
            @(x) validateattributes(x, {'logical'}, {}));
        dir = fileparts(hedXML);
        p.addOptional('outDir', dir, ...
            @(x) ~isempty(x) && ischar(x));
        p.addParamValue('writeOutput', false, @islogical);
        p.parse(hedSchema, hedXML, varargin{:});
        p = p.Results;
    end % parseArguments

    function writeOutputFiles(p)
        % Writes the issues and replace tags found to a log file and a
        % replace file
        [~, p.file] = fileparts(p.tsvFile);
        p.ext = '.txt';
        try
            if ~isempty(p.issues)
                createLogFile(p, false);
            else
                createLogFile(p, true);
            end
        catch
            throw(MException('validatehed:cannotWrite', ...
                'Could not write output file'));
        end
    end % writeOutputFiles

    function createLogFile(p, empty)
        % Creates a log file containing any issues found through the
        % validation
        numErrors = length(p.issues);
        errorFile = fullfile(p.outDir, [p.file '_log' p.ext]);
        fileId = fopen(errorFile,'w');
        if ~empty
            fprintf(fileId, '%s', p.issues{1});
            for a = 2:numErrors
                fprintf(fileId, '\n%s', p.issues{a});
            end
        else
            fprintf(fileId, 'No issues were found.');
        end
        fclose(fileId);
    end % createLogFile

end % validatehed