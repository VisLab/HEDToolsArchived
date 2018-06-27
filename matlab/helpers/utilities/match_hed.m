function matchMask = match_hed(hedStrings, queryHEDString)
% matchVector = match_hed(hedStrings, queryHEDString)
% Inputs: 
%
% hedStrings:      a cell array of input HED string we want to see whether they match a query string
% queryHEDString:  the query HED string
% Outputs:
%
% matchMask: a logical array the length of hedStrings with true valus where hedStrings matched queryHEDString
%
% Example
% >> matchMask = match_hed({'a' 'a/b/c' 'b/d/d'}, 'b')
% >> matchMask =
% 
%      0
%      0
%      1

[uniuqeHEDStrings, ~, ids] = unique(hedStrings);

matchMask = false(length(hedStrings), 1);
for i=1:length(uniuqeHEDStrings)
    
    % for now since there is a bug in findhedevents() which does not mathc by default to
    % Attribute/Onset, we remove this when an offset of not preset
    if isempty(strfind(lower(uniuqeHEDStrings{i}), 'attribute/offset'))
        uniuqeHEDStrings{i} = strrep(uniuqeHEDStrings{i}, 'Attribute/Onset', '');
        uniuqeHEDStrings{i} = strrep(uniuqeHEDStrings{i}, 'attribute/onset', '');
        uniuqeHEDStrings{i} = strrep(uniuqeHEDStrings{i}, 'Attribute/onset', '');
    end;
    
   if strcmp(strtrim(uniuqeHEDStrings{i}), strtrim(queryHEDString))
       matchMask(ids == i) = true;
       break
   end;
    
   if isempty(strfind(lower(queryHEDString), ' || '))
    matchMask(ids == i) =  findhedevents(uniuqeHEDStrings{i}, queryHEDString, 'exclusiveTags', ...
                {'Attribute/Intended effect', 'Attribute/Offset', 'Attribute/Participant indication'});
   else
        parts  = strsplit(lower(queryHEDString), ' || ');
        matchMask(ids == i) = false;
        for j=1:length(parts)
            matchMask(ids == i) = matchMask(ids == i) | ...
                findhedevents(uniuqeHEDStrings{i}, parts{j}, 'exclusiveTags', ...
                {'Attribute/Intended effect', 'Attribute/Offset', 'Attribute/Participant indication'});
        end;
   end;
end;