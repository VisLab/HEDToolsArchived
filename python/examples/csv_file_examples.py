from validation.hed_input_reader import HedInputReader

if __name__ == '__main__':
    spreadsheet_path = '../tests/data/TX14 HED Tags v9.87.csv';
    prefixed_needed_tag_columns = {2: 'Long', 3: 'Description', 4: 'Label', 5: 'Category', 7: 'Attribute'}
    hed_input_reader = HedInputReader(spreadsheet_path, tag_columns=[6],
                                      prefixed_needed_tag_columns=prefixed_needed_tag_columns);
    print('TX14 HED Tags v9.87.csv validation issues:\n' + hed_input_reader.get_validation_issues());