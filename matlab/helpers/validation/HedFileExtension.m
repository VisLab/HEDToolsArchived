% This class contains utility functions that retrieve information related
% to HED spreadsheet file extensions.
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

classdef HedFileExtension
    
    properties
        filePath;
    end % Instance properties
    
    properties(Constant)
        FILE_EXTENSIONS = {'xls', 'xlsx', 'tsv', 'txt'};
        EXCEL_FILE_EXTENSIONS = {'xls', 'xlsx'};
        TSV_FILE_EXTENSIONS = {'tsv', 'txt'};
    end % Constant properties
    
    methods
        
        function obj = HedFileExtension(filePath)
            obj.filePath = filePath;
        end
        function extension = getCanonicalFileExtension(obj)
            % Gets the canonical file extension of the specified file path.
            [~,~,extension] = fileparts(obj.filePath);
            extension = lower(strrep(extension, '.', ''));
        end % getFileExtension
        
        function isValid = fileHasValidExtension(obj, validExtensions)
            % Returns true if the file path is a valid extension
            extension = obj.getCanonicalFileExtension();
            isValid = ismember(extension, lower(validExtensions));
        end % fileHasValidExtension
        
        function hasExtension = hasExcelExtension(obj)
            % Returns true if the file path has a Excel extension
            hasExtension = obj.fileHasValidExtension(...
                obj.EXCEL_FILE_EXTENSIONS);
        end % hasExcelExtension
        
        function hasExtension = hasTsvExtension(obj)
            % Returns true if the file path has a TSV extension
            hasExtension = obj.fileHasValidExtension(...
                obj.TSV_FILE_EXTENSIONS);
        end % hasTsvExtension
        
        function hasExtension = hasSpreadsheetExtension(obj)
            % Returns true if the file path has a spreadsheet extension
            hasExtension = obj.fileHasValidExtension(obj.FILE_EXTENSIONS);
        end % hasSpreadsheetExtension
        
    end % Public methods
    
end % HedFileExtension