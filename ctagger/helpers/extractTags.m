function tMap = extractTags(EEG, field)
% Extract a tagmap from the usertags in the event structure.
tMap = tagMap();
values = {EEG.event.(field)};
usertags = {EEG.event.('usertags')};
uniqueValues = unique(cellfun(@num2str, values, 'UniformOutput', false));  % sample data 'rt' and 'square' for 'type'
uniqueValues = uniqueValues(~cellfun(@isempty, uniqueValues));
% leftoverTags = TagList();
for k = 1:length(uniqueValues)
    theseValues = strcmpi(uniqueValues{k}, values); % events with this type
    theseTags = usertags(theseValues);
    myTagList = tagList(uniqueValues{k});
    if ~isempty(theseTags)
        myTagList.addString(theseTags{1});
        for j = 2:length(theseTags)
            newList = tagList(uniqueValues{k});
            newList.addString(theseTags{j});
            myTagList.intersect(newList);
            %         leftoverTags.union(newList);
        end
    end
    tMap.addValue(myTagList);
end
%leftoverTags that didn't appear in the tMap

