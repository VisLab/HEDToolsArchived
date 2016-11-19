function [] = addhedpaths()
% Adds the paths needed to run the HEDTools, including the java paths.

tmp = which('tageeg');
if isempty(tmp)
    myPath = fileparts(which('pop_tageeg.m'));
    addpath(genpath(myPath));
end;
tPath = fileparts(which('eegplugin_hedtools.m'));

% Add the jar files needed to run this
jarPath = [tPath filesep 'jars' filesep];  % With jar
try
    javaaddpath([jarPath 'ctagger.jar']);
    javaaddpath([jarPath 'jackson.jar']);
    javaaddpath([jarPath 'hedconversion.jar']);
catch mex   %#ok<NASGU>
    warning('HEDTools: Could not add supporting Java tools to path');
end