EEG = pop_loadset('eeg_studyLevel2_Experiment_X2_Traffic_session_1_subject_1_task_Conditi_H,LH,HL)_ARL_BC__R4_EEG_CIB_recording_1.set');
EEG = hedepoch(EEG, 'Event/Category/Participant response, Attribute/Offset');

