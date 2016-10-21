function EEG = tsv2eeg(EEG, filename, fieldname, eventColumn, tagColumns)
tsvMap = tagtsv(filename, fieldname, eventColumn, tagColumns);
uniqueValues = tsvMap.getCodes();
values = extractfield(EEG.event, 'type');
if iscell(values)
    values = cellfun(@num2str, values, 'UniformOutput', false);
else
    values = arrayfun(@num2str, values, 'UniformOutput', false);
end
    for a = 1:length(EEG.event)
        EEG.event(a).hedtags = '';
        tList = getValue(tsvMap, num2str(EEG.event(a).type));
        if ~isempty(tList)
            EEG.event(a).hedtags = tagList.stringify(tList.getTags());
        end
    end
end

