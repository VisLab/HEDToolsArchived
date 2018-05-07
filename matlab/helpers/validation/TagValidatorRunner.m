% This class contains an interface for calling underlying validation
% functions that do the heavy lifting. 
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

classdef TagValidatorRunner
    
    properties
        tagValidator
    end % Instance properties
    
    methods
        
        function obj = TagValidatorRunner(hedMaps)
            % Constructor
            obj.tagValidator = TagValidator(hedMaps);
        end % TagValidator
        
        function errors = runHedStringValidator(obj, hedString)
            errors = ...
                obj.tagValidator.checkNumberOfGroupBrackets(hedString);
            errors = ...
                [errors obj.tagValidator.checkForMissingCommas(hedString)];
        end % runHedStringValidator
        
        function errors = runTagGroupValidators(obj, tagGroup)
            errors = obj.tagValidator.checkNumberOfGroupTildes(tagGroup);
        end % runTagGroupValidators
        
        function errors = runTagLevelValidators(obj, originalTags, ...
                formattedTags)
            errors = obj.tagValidator.checkForMultipleUniquePrefixes(...
                obj.hedMaps, originalTags, formattedTags);
            errors = [errors obj.tagValidator.checkduplicate(obj.hedMaps, ...
                originalTags, formattedTags)];
        end % runTagLevelValidators
        
        function warnings = runTopLevelValidators(obj, ...
                formattedTopLevelTags)
            warnings = obj.checkrequired(obj.hedMaps, ...
                formattedTopLevelTags);
        end % runTopLevelValidators
        
    end % Public methods
    
end % TagValidator