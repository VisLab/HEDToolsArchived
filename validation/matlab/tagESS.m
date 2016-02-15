function EEG = tagESS(essStruct)
EEG = struct('event', []);
EEG.event = populateEventStruct(essStruct.eventCodes.eventCode);
EEG = tageeg(EEG);

    function eventsStruct = populateEventStruct(eventCodes)
        numEvents = length(eventCodes);
        eventsStruct(numEvents).type = '';
        eventsStruct(numEvents).usertags = '';
        for a = 1:numEvents
            eventsStruct(a).type = eventCodes(a).code;
            eventsStruct(a).usertags = eventCodes(a).condition.tag;
        end
    end
end

