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
        
        function issues = runHedStringValidator(obj, hedString)
            % Runs HED string validators.
            issues = ...
                obj.tagValidator.checkNumberOfGroupBrackets(hedString);
            issues = ...
                [issues obj.tagValidator.checkForMissingCommas(hedString)];
        end % runHedStringValidator
        
        function issues = runIndividualTagValidators(obj, originalTag, ...
                formattedTag, previousOriginalTag, ...
                previousFormattedTag, generateWarnings)
            % Runs the individual tag validators
            issues = obj.tagValidator.checkIfTagIsValid(originalTag, ...
                formattedTag, previousOriginalTag, previousFormattedTag);
            issues = [issues ...
                obj.tagValidator.checkUnitClassTagHasValidUnits(...
                originalTag, formattedTag)];
            issues = [issues ...
                obj.tagValidator.checkIfValidNumericalTag(...
                originalTag, formattedTag)];
            issues = [issues ...
                obj.tagValidator.checkIfTagRequiresAChild(...
                originalTag, formattedTag)];
            if generateWarnings
                issues = [issues ...
                    obj.tagValidator.checkUnitClassTagHasUnits(...
                    originalTag, formattedTag)];
                issues = [issues ...
                    obj.tagValidator.checkPathNameCaps(originalTag)];
                
            end
        end % runIndividualTagValidators
        
        function issues = runTagGroupValidators(obj, tagGroup)
            % Runs the tag group validators
            issues = obj.tagValidator.checkNumberOfGroupTildes(tagGroup);
        end % runTagGroupValidators
        
        function issues = runTagLevelValidators(obj, originalTags, ...
                formattedTags)
            % Runs the tag level validators.
            issues = obj.tagValidator.checkForMultipleUniquePrefixes(...
                formattedTags);
            issues = [issues ...
                obj.tagValidator.checkForDuplicateTags(originalTags, ...
                formattedTags)];
        end % runTagLevelValidators
        
        function issues = runTopLevelValidators(obj, ...
                formattedTopLevelTags, generateWarnings, ...
                missingRequiredTagsAreErrors)
            % Runs the top-level tag validators.
            if ~generateWarnings && ~missingRequiredTagsAreErrors
                issues = '';
            else
                issues = obj.tagValidator.checkIfRequiredTagsPresent(...
                    formattedTopLevelTags, ...
                    missingRequiredTagsAreErrors);
            end
        end % runTopLevelValidators
        
    end % Public methods
    
end % TagValidator