function [] = addhedpaths()
% Adds the paths needed to run the HEDTools, including the java paths.

tmp = which('tageeg');
if isempty(tmp)
    myPath = fileparts(which('pop_tageeg.m'));
    addpath(genpath(myPath));
end;

% Add the jar files needed to run this, preserving the base variables
try
    if ~exist(tempdir, 'dir')
        warning('HEDTools: Your system does not have a temporary directory defined');
        theDir = pwd; %#ok<*NASGU>
    else
        theDir = tempdir;
    end
        saveExp = sprintf('save(%s, ''-mat'');', ['''' theDir 'tmp.mat' '''']);
    loadExp = sprintf('load(%s, ''-mat'');', ['''' theDir 'tmp.mat' '''']);
    evalin('base', saveExp);
    tPath = fileparts(which('eegplugin_hedtools.m'));
    jarPath = [tPath filesep 'jars' filesep];  % With jar
    
    javaaddpath([jarPath 'ctagger.jar']);
    javaaddpath([jarPath 'jackson.jar']);
    javaaddpath([jarPath 'hedconversion.jar']);
    evalin('base', loadExp);
    delete([theDir 'tmp.mat']);    
catch mex   
    warning('HEDTools: Could not add supporting Java tools to path');
end
