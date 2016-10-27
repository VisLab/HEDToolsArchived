% The following sections contain code examples for tagging a EEG dataset, a 
% directory of EEG datasets, and a EEG study. 

%% Set the example directory (PLEASE SET THIS)
exampleDir = 'HEDToolsExampleArchive';

%% Tag the data in the EEG structure
EEG = pop_loadset([exampleDir filesep ...
    'EEGLABSet' filesep 'eeglab_data_ch1.set']);
[EEG, fMap, excluded] = tageeg(EEG, 'SaveDataset', true); %#ok<*ASGLU>

%% Tag the data in a specified directory
[fMap, fPaths, excluded] = tagdir([exampleDir filesep 'EEGLABSet'], ...
    'SaveDatasets', true);