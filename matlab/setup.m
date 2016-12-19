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