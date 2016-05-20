function tMap = extractTags(EEG, field, originalTags)
% Extract a tagmap from the usertags in the event structure.
tMap = tagMap();
allValues = {EEG.event.(field)};
usertags = {EEG.event.('usertags')};
uniqueValues = unique(cellfun(@num2str, allValues, 'UniformOutput', false));  % sample data 'rt' and 'square' for 'type'
uniqueValues = uniqueValues(~cellfun(@isempty, uniqueValues));
allValues = cellfun(@num2str, allValues, 'UniformOutput', false);
for k = 1:length(uniqueValues)
    foundValues = strcmpi(uniqueValues{k}, allValues); % events with this type
    allTags = usertags(foundValues);
    if ~isempty(allTags)
        originaltstring = tagList.deStringify(allTags{1});
        originaltstring = setdiff(originaltstring,originalTags);
        originalTagList = tagList(uniqueValues{k});
        originalTagList.addList(originaltstring);
        for j = 2:length(allTags)
            newtstring = tagList.deStringify(allTags{j});
            newtstring = setdiff(newtstring,originalTags);
            newTagList = tagList(uniqueValues{k});
            newTagList.addList(newtstring);
            originalTagList.intersect(newTagList);
        end
    end
    tMap.addValue(originalTagList);
end