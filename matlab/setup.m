%% Set up the paths
% Run from HEDTools directory or have HEDTools directory in your path
configPath = which('eegplugin_hedtools.m');
if isempty(configPath)
    error('Cannot configure: change to ctagger directory');
end
dirPath = strrep(configPath, [filesep 'eegplugin_hedtools.m'],'');
addpath(genpath(dirPath));

%% Now add java jar paths
jarPath = [dirPath filesep 'jars' filesep];  % With jar
warning off all;
try
    javaaddpath([jarPath 'ctagger.jar']);
    javaaddpath([jarPath 'jackson.jar']);
    javaaddpath([jarPath 'hedconversion.jar']);
catch mex
end
warning on all;

%% Set up the path to EEGLAB. Comment this section out if not using EEGLAB

% See if eeglab already in the path
wPath = which('eeglab.m');
if ~isempty(wPath)
    fprintf('Using %s for eeglab\n', wPath);
    return;
end

% See if ctagger has been installed as an EEGLAB plugin
p = strfind(configPath, 'plugins');
if isempty(p)
    PLUG_PATH = '';
else
    PLUG_PATH = configPath(1:p-2);
end
if ~isempty(PLUG_PATH)
    fprintf('Adding default EEGLAB path %s\n', PLUG_PATH);
    addpath(genpath(PLUG_PATH));
    return;
end

% See if user has hardcoded in a path
EEGLAB_PATH = '';  % Give full path of eeglab installation if not using as plugin
if isdir(EEGLAB_PATH)
    fprintf('Adding default EEGLAB path %s\n', EEGLAB_PATH);
    addpath(genpath(EEGLAB_PATH));
    return;
else
    warning('setup:NoEEGLAB', ...
        ['Edit setup.m so that EEGLABPath is the full pathname ' ...
        'of directory containing EEGLAB if you want to use EEGLAB']);
end