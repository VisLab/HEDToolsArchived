% Adds the paths needed to run the HEDTools, including the java paths. If
% EEGLAB is being used then the workspace variables will be saved in a
% temporary file before the java paths are added and restored after.
%
% Usage:
%
%   >> addhedpaths()
%
% Input:
%
%   Required:
%
%   usingEEGLAB
%                    If true, EEGLAB is being used with HEDTools. The
%                    workspace will be saved before adding the jar files
%                    and then restored after. If false, EEGLAB is not being
%                    used with the HEDTools. 
%
% Copyright (C) 2012-2013
% Jeremy Cockfield, UTSA, jeremy.cockfield@gmail.com
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1.07 USA

function addhedpaths(usingEEGLAB)
addFolders();
if usingEEGLAB
    preserveWorkspace();
else
    addJavaPaths();
end

    function tempDirectory = getTemporaryDirectory()
        % Returns the temporary directory on the system, if not present
        % then it will return the current directory
        if ~exist(tempdir, 'dir')
            warning(['HEDTools: Your system does not have a temporary' ...
                ' directory defined... Using the current directory.']);
            tempDirectory = pwd; %#ok<*NASGU>
        else
            tempDirectory = tempdir;
        end
    end % getTemporaryDirectory

    function preserveWorkspace()
        % Add the jar files needed to run HEDTools and preserves the 
        % workspace
        try
            tempDirectory = getTemporaryDirectory();
            copyWorkspace(tempDirectory);
            addJavaPaths();
            restoreWorkspace(tempDirectory);
        catch mex
            warning(['HEDTools: Could not add supporting Java tools' ...
                'to path']);
        end
    end % preserveWorkspace

    function copyWorkspace(tempDirectory)
        % Copies the workspace into a temporary file
        saveExp = sprintf('save(%s, ''-mat'');', ['''' tempDirectory ...
            'tmp.mat' '''']);
        evalin('base', saveExp);
    end % copyWorkspace

    function restoreWorkspace(tempDirectory)
        % Restores the workspace from a temporary file
        loadExp = sprintf('load(%s, ''-mat'');', ['''' tempDirectory ...
            'tmp.mat' '''']);
        evalin('base', loadExp);
        delete([tempDirectory 'tmp.mat']);
    end % restoreWorkspace

    function addJavaPaths()
        % Adds the JAR files to the java class path
        tPath = fileparts(which('eegplugin_hedtools.m'));
        jarPath = [tPath filesep 'jars' filesep];  % With jar
        javaaddpath([jarPath 'ctagger.jar']);
        javaaddpath([jarPath 'jackson.jar']);
        javaaddpath([jarPath 'hedconversion.jar']);
    end % addJavaPaths

    function addFolders()
        % Add folders to the search path
        tmp = which('tageeg');
        if isempty(tmp)
            myPath = fileparts(mfilename('fullpath'));
            addpath(genpath(myPath));
        end
    end % addFolders

end % addhedpaths