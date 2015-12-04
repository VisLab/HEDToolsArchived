function [hedVector hedTag] = hed_to_vector(inputTag, onlyKeepUsedTags,  lowercaseimportantTags)
% [hedVector hedTag] = hed_to_vector(inputTag, removeUnused,  importantTags)
% Converts HED strings to numerical vectors.
%   Focuses on the most important HED tags.
%

% need to map 'Participant\Effect\Cognitive\Non-target' to 'Participant\Effect\Cognitive\Expected\Non-target'
% need to map 'Action\Control vehicle\Drive\Correct' to 'Action\Type\Control vehicle\Drive\Correct'
inputTag = strrep(inputTag, 'Participant\Effect\Cognitive\Non-target', 'Participant\Effect\Cognitive\Expected\Non-target');
inputTag = strrep(inputTag, 'Action\Control vehicle\Drive\Correct', 'Action\Type\Control vehicle\Drive\Correct');

if nargin < 2
    onlyKeepUsedTags = true;
end

if nargin < 3
    importantTags = {'Event\Category\Participant response', ...
        'Event\Category\Experimental stimulus', 'Event\Category\Experimental stimulus\Instruction\Attend', ...
        'Event\Category\Experimental stimulus\Instruction\Fixate', 'Event\Category\Experimental stimulus\Instruction\Recall', ...
        'Event\Category\Experimental stimulus\Instruction\Generate', 'Event\Category\Experimental stimulus\Instruction\Repeat', ...
        'Event\Category\Experimental stimulus\Instruction\Imagine', 'Event\Category\Experimental stimulus\Instruction\Rest', ...
        'Event\Category\Experimental stimulus\Instruction\Count', 'Event\Category\Experimental stimulus\Instruction\Walk', ...
        'Event\Category\Experimental stimulus\Instruction\Move', 'Event\Category\Experimental stimulus\Instruction\Speak', ...
        'Event\Category\Experimental stimulus\Instruction\Detect', 'Event\Category\Experimental stimulus\Instruction\Name', ...
        'Event\Category\Experimental stimulus\Instruction\Track', 'Event\Category\Experimental stimulus\Instruction\Encode', ...
        'Participant\Effect\Cognitive\Reward', 'Participant\Effect\Cognitive\Penalty', 'Participant\Effect\Cognitive\Error',...
        'Participant\Effect\Cognitive\Oddball', 'Participant\Effect\Cognitive\Target', 'Participant\Effect\Cognitive\Expected', ...
        'Participant\Effect\Cognitive\Expected\Non-Target', 'Participant\Effect\Cognitive\Non-Target', ...
        'Action\Type\Control vehicle\Drive\Correct', 'Action\Type\Button press', 'Participant\Effect\Visual'};
end;

hedVector = zeros(length(importantTags), length(inputTag));

% make all lower to simplify comparison
inputTag = lower(inputTag);
lowercaseimportantTags = lower(importantTags);

% make all slashed forward
inputTag = strrep(inputTag, '/', '\');
lowercaseimportantTags = strrep(lowercaseimportantTags, '/', '\');


for i=1:length(lowercaseimportantTags)
    cellforTag = strfind(inputTag, lowercaseimportantTags{i});
    cellforTag(cellfun(@isempty, cellforTag)) = {0};
    
    % exclude if it has offset
    cellforOffsetTag = strfind(inputTag, 'attribute\offset');
    cellforOffsetTag(cellfun(@isempty, cellforOffsetTag)) = {0};
    
    hedVector(i,:) = cell2mat(cellforTag) & ~cell2mat(cellforOffsetTag);
end;

if onlyKeepUsedTags
    id = any(hedVector,2);
    hedVector = hedVector(id,:);
    hedTag = importantTags(id);
else
    hedTag = importantTags;
end

end

