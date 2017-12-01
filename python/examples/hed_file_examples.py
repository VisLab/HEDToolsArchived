from validation.hed_input_reader import HedInputReader

if __name__ == '__main__':
    # # Example 1: Valid TSV file
    # spreadsheet_path = '../tests/data/BCIT_GuardDuty_HED_tag_spec_v27.tsv';
    # hed_input_reader = HedInputReader(spreadsheet_path, tag_columns=[2]);
    # print('BCIT_GuardDuty_HED_tag_spec_v27.tsv validation issues:\n' + hed_input_reader.get_validation_issues());

    # # Example 2: Valid CSV file
    # spreadsheet_path = '../tests/data/TX14 HED Tags v9.87.csv';
    # prefixed_needed_tag_columns = {2: 'Long', 3: 'Description', 4: 'Label', 5: 'Category', 7: 'Attribute'}
    # hed_input_reader = HedInputReader(spreadsheet_path, tag_columns=[6],
    #                                   prefixed_needed_tag_columns=prefixed_needed_tag_columns);
    # print('TX14 HED Tags v9.87.csv validation issues:\n' + hed_input_reader.get_validation_issues());

    # Example 3: InValid CSV file (Label column removed)
    spreadsheet_path = '../tests/data/TX14 HED Tags v9.87.csv';
    prefixed_needed_tag_columns = {2: 'Long', 3: 'Description', 5: 'Category', 7: 'Attribute'}
    hed_input_reader = HedInputReader(spreadsheet_path, tag_columns=[1],
                                      prefixed_needed_tag_columns=prefixed_needed_tag_columns);
    print('TX14 HED Tags v9.87.csv validation issues:\n' + hed_input_reader.get_validation_issues());