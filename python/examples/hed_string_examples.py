from validation.hed_input_reader import HedInputReader

if __name__ == '__main__':
    hed_string_1 = 'Event/Label/ButtonPuskDeny, Event/Description/Button push to deny access to the ID holder,' \
                   'Event/Category/Participant response, ' \
                   '(Participant ~ Action/Button press/Keyboard ~ Participant/Effect/Body part/Arm/Hand/Finger)';
    hed_string_2 = 'Event/Category/Participant response, ' \
                   '(Participant ~ Action/Button press/Keyboard ~ Participant/Effect/Body part/Arm/Hand/Finger)';
    hed_input_reader = HedInputReader(hed_string_1);
    print('HED string 1 validation issues:\n' + hed_input_reader.get_validation_issues());
    hed_input_reader = HedInputReader(hed_string_2);
    print('HED string 2 validation issues:\n' + hed_input_reader.get_validation_issues());