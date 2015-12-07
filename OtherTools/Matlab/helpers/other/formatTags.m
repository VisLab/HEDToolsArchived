function fTags = formatTags(tags, isCanonical)
% Formats the hed tags
fTags = regexprep(tags,'"','');
fTags = deStringify(fTags);
fTags = removeEmptyCells(fTags);
if isCanonical
    for c = 1:length(fTags)
        fTags{c} = getCanonical(fTags{c});
    end
end

    function [tlist, errormsg] = deStringify(tstring)
        % Create a cell array representing a comma-separated string of
        % tags
        tlist = {};
        errormsg = '';
        if isempty(tstring) || ~ischar(tstring)
            errormsg = 'input empty or not a string';
            return;
        end
        try
            tlist = regexpi(tstring, ',(?![^\(]*\))', 'split');
            % Remove empty cells
            tlist = tlist(~cellfun(@isempty, tlist));
            for k = 1:length(tlist)
                if ~isempty(regexpi(tlist{k}, '^\s*\(', 'once'))
                    tlist{k} = regexprep(tlist{k}, '[\(\)]', '');
                    tlist{k} = regexpi(tlist{k}, ...
                        ',', 'split');
                    if any(~cellfun(@isempty, strfind(tlist{k}, '~')))
                        tlist{k} = ...
                            splitTildesInGroup(tlist{k});
                    end
                end
                tlist{k} = strtrim(tlist{k});
                msg = tagList.validate(tlist{k});
                if ~isempty(msg)
                    errormsg = [errormsg '[' msg ']']; %#ok<AGROW>
                end
            end
        catch mex
            errormsg = [errormsg '[' mex.message ']'];
        end
    end % deStringify

    function tCanonical = getCanonical(tgroup)
        % Returns a sorted version of a valid tag or tag group
        tCanonical = {};
        if isempty(tgroup)
            return;
        elseif ischar(tgroup)
            tCanonical = strtrim(tgroup);
            if ~strcmp(tCanonical(1), '/')
                tCanonical = ['/', tCanonical];
            end
            if strcmp(tCanonical(end), '/')
                tCanonical = tCanonical(1:end-1);
            end
            return
        elseif ~iscellstr(tgroup)
            return;
        end
        tgroup = strtrim(tgroup(:))';   % make sure a row
        empties = cellfun(@isempty, tgroup);
        tgroup(empties) = [];   % remove empties
        for k = 1:length(tgroup)
            if ~strcmp(tgroup{k}, '~') && ~strcmp(tgroup{k}(1), '/')
                tgroup{k} = ['/', tgroup{k}];
            end
            if ~strcmp(tgroup{k}, '~') && strcmp(tgroup{k}(end), '/')
                tgroup{k} = tgroup{k}(1:end - 1);
            end
        end
        empties = cellfun(@isempty, tgroup);
        tgroup(empties) = [];   % remove empties
        tildepos = find(strcmpi('~', tgroup));
        tCanonical = cell(1, length(tgroup));
        tindex = [0 tildepos length(tgroup) + 1];
        for k = 1:length(tildepos) + 1
            theind = (tindex(k) + 1):(tindex(k+1) - 1);
            tCanonical(theind) = tgroup(theind);
            if tindex(k+1) <= length(tgroup)
                tCanonical{tindex(k+1)} = '~';
            end
        end
    end % getCanonical

    function tRemoved = removeEmptyCells(tgroup)
        tRemoved = tgroup(~cellfun('isempty',tgroup));
        for a = 1:length(tgroup)
            if iscellstr(tgroup{a})
                tRemoved{a} = tRemoved{a}(~cellfun('isempty',tRemoved{a}));
            end
        end
    end % removeEmptyCells

    function tildeTagGroup = splitTildesInGroup(TagGroup)
        % Splits the tildes in the cellstr tag group
        tildeTagGroup = {};
        tagGroupCount  = 1;
        numGroupTags = length(TagGroup);
        for groupTagNum = 1:numGroupTags
            if strfind(TagGroup{groupTagNum}, '~')
                tildeTags = strtrim(strsplit(...
                    TagGroup{groupTagNum}, '~'));
                numTildeGroupTags = length(tildeTags);
                for numTildeGroupTag = 1:numTildeGroupTags-1
                    tildeTagGroup{tagGroupCount} = ...
                        tildeTags{numTildeGroupTag}; %#ok<AGROW>
                    tagGroupCount  = tagGroupCount + 1;
                    tildeTagGroup{tagGroupCount} = '~'; %#ok<AGROW>
                    tagGroupCount  = tagGroupCount + 1;
                end
                tildeTagGroup{tagGroupCount} = ...
                    tildeTags{numTildeGroupTags}; %#ok<AGROW>
                tagGroupCount  = tagGroupCount + 1;
            else
                tildeTagGroup{tagGroupCount} = ...
                    TagGroup{groupTagNum}; %#ok<AGROW>
                tagGroupCount  = tagGroupCount + 1;
            end
        end
    end % splitTildesInGroup

end % formatTags