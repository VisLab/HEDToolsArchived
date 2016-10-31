function [overwriteDatasets, savefMap, fMapPath, fMapDescription] = ...
    savetags_input()
checkText1 = 'Overwrite the original dataset(s) to include the HED tags';
checkText2 = 'Save the tags as a field map';
overwriteDatasets = false;
savefMap = false;
fMapPath = '';
fMapDescription = '';
geometry = {1 1 1 [1 4 0 .75 1]};
uilist = { ...
    { 'Style' 'checkbox' 'string' checkText1} ...
    { 'Style' 'checkbox' 'string' checkText2 'callback' ...
    @savefMapCallback} ...
    { } ...
    { 'Style' 'text' 'string' 'field map file name:'} ...
    { 'Style' 'edit' 'string' fMapPath 'tag' 'fMapPath' 'enable' 'off'} ...
    { 'Style' 'edit' 'string' fMapDescription 'Max' 2 'tag' ...
    'fMapDescription' 'enable' 'off'} ...
    { 'Style' 'pushbutton' 'string' 'Browse' 'callback' ...
    @browsefMapCallback 'tag'  'fMapBrowseButton' 'enable' 'off'} ...
    { 'Style' 'pushbutton' 'string' 'Edit description' 'callback' ...
    @fMapdescriptionCallback 'tag'  'fMapDescriptionButton'}};

results = inputgui( geometry, uilist, 'pophelp(''pop_savetags'')', ...
    'Save HED tags -- pop_savetags()');
if ~isempty(results)
    overwriteDatasets = logical(results{1});
    savefMap = logical(results{2});
    fMapPath = results{3};
    fMapDescription = results{4};
end

    function fMapdescriptionCallback(~, ~)
        % Callback for field map 'Edit description' button
        description = get(findobj('Tag', 'fMapDescription'), 'String');
        description = pop_comments(description, 'Field map description');
        set(findobj('Tag', 'fMapDescription'), 'String', description);
    end % fMapdescriptionCallback

    function savefMapCallback(src, ~)
        % Callback for save field map checkbox
        value = get(src, 'Max') == get(src, 'Value');
        status = getOnOff(value);
        set(findobj('Tag', 'fMapPath'), 'enable', status);
        set(findobj('Tag', 'fMapBrowseButton'), 'enable', status);
    end % savefMapCallback

    function status = getOnOff(logValue)
        % Returns 'on' if the logValue is true, 'off' if otherwise
        status = 'off';
        if logValue
            status = 'on';
        end
    end % getOnOff

    function browsefMapCallback(~, ~)
        % Callback for field map 'Browse' button
        [file,path] = uiputfile({'*.mat', 'MATLAB Files (*.mat)'}, ...
            'Save event tags', 'fMap.mat');
        if ischar(file) && ~isempty(file)
            saveMapFile = fullfile(path, file);
            set(findobj('Tag', 'fMapPath'), 'String', saveMapFile);
        end
    end % browseSaveTagsCallback

end % pop_savetags