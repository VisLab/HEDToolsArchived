% This class contains the interface that does the actual validation and
% return any issues found. 
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

classdef TagValidator
    
    properties
        hedMaps
    end
    
    properties(Constant, Access=private)
        capWarnings = 'cap';
        capExpression = '^[a-z]|/[a-z]|[^|]\s+[A-Z]';
    end % Instance properties
    
    methods
        
        function obj = TagValidator(hedMaps)
            % Constructor
            obj.hedMaps = hedMaps;
        end % TagValidator
        
        function warnings = checkCaps(obj, originalTag)
            % Returns true if the tag isn't correctly capitalized
            warnings = '';
            if checkIfParentTagTakesValue(obj, originalTag)
                return;
            elseif invalidCapsFoundInTag(obj, originalTag)
                warnings = warningReporter(obj.capWarnings, 'tag', ...
                    originalTag);
            end
        end % runHedStringValidator
        
    end % Public methods
    
    methods(Access=private)
        
        function invalidCaps = invalidCapsFoundInTag(obj, tag)
            % Returns true if invalid caps were found in a tag. False, if
            % otherwise. The first letter of the tag is supposed to be
            % capitalized and all subsequent words are supposed to be
            % lowercase.
            invalidCaps = ~isempty(regexp(tag, obj.capExpression, 'once'));
        end % invalidCapsFoundInTag
        
        function takesValue = checkIfParentTagTakesValue(obj, tag)
            % Returns true if the parent tag takes a value. False, if
            % otherwise.
            takesValue = false;
            slashPositions = strfind(tag, '/');
            if ~isempty(slashPositions)
                valueTag = [tag(1:slashPositions(end)) '#'];
                if obj.hedMaps.takesValue.isKey(lower(valueTag))
                    takesValue = true;
                end
            end
        end % checkIfParentTagTakesValue
           
    end % Private methods
    
end % TagValidator