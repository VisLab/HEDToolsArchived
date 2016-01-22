% Community event tagger
% Version 1.1 (beta)
%
% The Community Event Tagger is a GUI for supporting user assignment of
% tags
%
% Authors: Thomas Rognon and Kay Robbins, UTSA 2012-2013
%
%
% Top-level functions
%   pop_tagdir        - Allows a user to tag a directory of datasets using 
%                       a GUI 
%   pop_tageeg        - Allows a user to tag a EEG structure using a GUI
%   pop_tagstudy      - Allows a user to tag a EEGLAB study using a GUI
%
% Helpers
%   createdb          - Creates a ctagger database
%   createdbc         - Creates a ctagger database from a property file 
%   csvMap            - Object encapsulating the csv representation of a 
%                       tag map
%   dbcreds           - GUI for input needed to create or edit database 
%                       credentials
%   editmaps          - Allows a user to selectively edit the tags using 
%                       the ctagger GUI
%   editmaps_db       - Allows a user to selectively edit the tags using 
%                       the ctagger database
%   fieldMap          - Object encapsulating xml tags and type-tagMap 
%                       association
%   findtags          - Creates a fieldMap object for the existing tags in
%                       a data structure
%   getfilelist       - Gets a list of the files in a directory tree
%   getutypes         - Returns a cell array with the unique values in the
%                       type field of estruct
%   hedManager        - utility provided by Nima Bidely Shamlo UCSD for
%                       managing the XML hierarchy
%   merge_taglists    - Returns a merged cell array of tags conforming to
%                       preservePrefix
%   merge_tagstrings  - Returns a merged cell array of tags
%   selectmaps        - Allows a user to select the fields to be used
%   splitcsv          - Returns a cell array of cell strings from parsing
%                       a csv file
%   tagcsv            - Allows a user to tag a csv file of event code 
%                       specifications
%   tagdir            - Allows a user to tag an entire tree directory of 
%                       similar EEG .set files
%   tagdir_input      - GUI for input needed to create inputs for tagdir 
%                       function
%   tagdlg            - GUI helper for selectmaps
%   tageeg            - Allows a user to tag a EEG structure
%   tageeg_input      - GUI for input needed to create inputs for tageeg 
%   tagMap            - Object encapsulating the tags and value labels of 
%                       one type
%   tagstudy          - Allows a user to tag a EEGLAB study
%   tagstudy_input    - GUI for input needed to create inputs for tagstudy
%   writetags         - Writes tags to a structure from the fieldMap 
%                       information
