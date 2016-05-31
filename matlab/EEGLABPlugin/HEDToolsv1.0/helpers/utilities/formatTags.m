function fTags = formatTags(tags, isCanonical)
% Formats the hed tags
fTags = vTagList.deStringify(tags);
if isCanonical
    numTags = length(fTags);
    for c = 1:numTags
        fTags{c} = vTagList.getUnsortedCanonical(fTags{c});
    end
end
end % formatTags