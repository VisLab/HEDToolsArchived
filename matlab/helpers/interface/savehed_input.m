function [overwriteHED, saveHED, hedPath] = savehed_input()
checkText1 = 'Create/Overwrite the user HED with the current';
checkText2 = 'Save the current HED as a separate XML file (outside of HEDTools)';
overwriteHED = false;
saveHED = false;
hedPath = '';
geometry = {1 1 1 [1 4 .75]};
uilist = { ...
    { 'Style' 'checkbox' 'string' checkText1} ...
    { 'Style' 'checkbox' 'string' checkText2 'callback' ...
    @saveHEDCallback} ...
    { } ...
    { 'Style' 'text' 'string' 'HED file name:'} ...
    { 'Style' 'edit' 'string' hedPath 'tag' 'fMapPath' 'enable' 'off'} ...
    { 'Style' 'pushbutton' 'string' 'Browse' 'callback' ...
    @browseHEDCallback 'tag'  'fMapBrowseButton' 'enable' 'off'}};

results = inputgui( geometry, uilist, 'pophelp(''pop_savetags'')', ...
    'Save HED schema -- pop_savehed()');
if ~isempty(results)
    overwriteHED = logical(results{1});
    saveHED = logical(results{2});
    hedPath = results{3};
end

    function saveHEDCallback(src, ~)
        % Callback for save HED checkbox
        value = get(src, 'Max') == get(src, 'Value');
        status = getOnOff(value);
        set(findobj('Tag', 'fMapPath'), 'enable', status);
        set(findobj('Tag', 'fMapBrowseButton'), 'enable', status);
    end % saveHEDCallback

    function status = getOnOff(logValue)
        % Returns 'on' if the logValue is true, 'off' if otherwise
        status = 'off';
        if logValue
            status = 'on';
        end
    end % getOnOff

    function browseHEDCallback(~, ~)
        % Callback for field map 'Browse' button
        [file,path] = uiputfile({'*.xml', 'XML Files (*.xml)'}, ...
            'Save HED schema', 'HED.xml');
        if ischar(file) && ~isempty(file)
            saveMapFile = fullfile(path, file);
            set(findobj('Tag', 'fMapPath'), 'String', saveMapFile);
        end
    end % browseHEDCallback

end % pop_savetags