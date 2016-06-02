% The following sections contain code examples for tagging a EEG dataset, a 
% directory of EEG datasets, and a EEG study. 

%% Set the example directory (PLEASE SET THIS)
exampleDir = 'Path\To\HEDToolsTestArchive';

%% Tag the data in the EEG structure
EEG = pop_loadset([exampleDir filesep ...
    'EEGLABSet' filesep 'eeglab_data_ch1.set']);
[EEG, fMap, excluded] = tageeg(EEG); %#ok<*ASGLU>

%% Tag the data in a specified directory
[fMap, fPaths, excluded] = tagdir([exampleDir filesep 'EEGLABSet'], ...
    'SaveDatasets', false);

%% Tag the data represented by a study file
[fMap, fPaths, excluded] = tagstudy([exampleDir filesep ... 
    '5subjects' filesep 'n400clustedit.study'], ...
    'SaveDatasets', false);