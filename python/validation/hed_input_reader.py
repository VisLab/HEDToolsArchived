import xlrd;
from validation.hed_dictionary import HedDictionary
from validation.tag_validator import TagValidator;
from validation.hed_string_delimiter import HedStringDelimiter;
from validation import error_reporter;


class HedInputReader:

    TSV_EXTENSION = ['tsv', 'txt'];
    CSV_EXTENSION = ['csv'];
    EXCEL_EXTENSION = ['xls', 'xlsx'];
    FILE_EXTENSION = ['csv', 'tsv', 'txt', 'xls', 'xlsx'];
    TEXT_EXTENSION = ['csv', 'tsv', 'txt'];
    STRING_INPUT = 'string';
    FILE_INPUT = 'file';
    TAB_DELIMITER = '\t';
    COMMA_DELIMITER = ',';
    HED_XML_FILE = '../hed/HED.xml';
    PREFIX_TAG_COLUMN_TO_PATH = {'Attribute': 'Attribute/', 'Category': 'Event/Category',
                                 'Description': 'Event/Description', 'Label': 'Event/Label', 'Long': 'Event/Long name'};

    def __init__(self, hed_input, tag_columns=[2], has_headers=True, worksheet='', prefixed_needed_tag_columns={}):
        """Constructor for the HedInputReader class.

        Parameters
        ----------
        hed_input: string
            A HED string or a spreadsheet file containing HED tags. If a string is passed in then no other arguments
            need to be specified.
        tag_columns: list
            A list of integers containing the columns that contain the HED tags. The default value is the 2nd column.
        has_headers: boolean
            True if file has headers. False, if otherwise.
        worksheet: string
            The name of the Excel workbook worksheet that contains the HED tags.
        prefixed_needed_tag_columns: dictionary
            A dictionary containing the HED tag column names that corresponds to tags that need to be prefixed with a
            parent tag path.
        Returns
        -------
        HedInputReader object
            A HedInputReader object.

        """
        self.hed_input = hed_input;
        self.tag_columns = HedInputReader.subtract_1_from_list_elements(tag_columns);
        self.has_headers = has_headers;
        self.worksheet = worksheet;
        self.prefixed_needed_tag_columns = prefixed_needed_tag_columns;
        self.hed_dictionary = HedDictionary(HedInputReader.HED_XML_FILE);
        self.tag_validator = TagValidator(self.hed_dictionary);
        if HedInputReader.hed_input_has_valid_file_extension(self.hed_input):
            self.file_extension = HedInputReader.get_file_extension(self.hed_input);
            if HedInputReader.file_is_a_text_file(self.file_extension):
                self.column_delimiter = HedInputReader.get_delimiter_from_text_file_extension(self.file_extension);
                self.validation_issues = self.validate_hed_tags_in_text_file();
            else:
                pass;
        else:
            self.validation_issues = self.validate_hed_string(self.hed_input);

    def validate_hed_tags_in_text_file(self):
        """Validates the HED tags in a text file.

         Parameters
         ----------
         Returns
         -------
         string
             The validation issues that were found in the text file.

         """
        validation_issues = '';
        with open(self.hed_input) as opened_text_file:
            for text_file_row_number, text_file_row in enumerate(opened_text_file):
                if HedInputReader.row_contains_headers(self.has_headers, text_file_row_number):
                    continue;
                validation_issues = self.append_validation_issues_if_found(validation_issues,
                                                                           text_file_row_number, text_file_row);
        return validation_issues;

    def append_validation_issues_if_found(self, validation_issues, row_number, file_row):
        """Appends the validation issues associated with a particular row in a spreadsheet.

         Parameters
         ----------
        validation_issues: string
            A validation string that contains all the issues found in the spreadsheet.
         row_number: integer
            The row number that the issues are associated with.
        file_row: string
            The row in the spreadsheet that contains the HED string.
         Returns
         -------
         string
             The validation issues with the appended issues found in the particular row.

         """
        hed_string = HedInputReader.get_hed_string_from_text_file_row(file_row, self.tag_columns,
                                                                      self.column_delimiter,
                                                                      self.prefixed_needed_tag_columns);
        if hed_string:
            row_validation_issues = self.validate_hed_string(hed_string);
            if row_validation_issues:
                validation_issues += HedInputReader.generate_row_issue_message(row_number) + \
                                     row_validation_issues;
        return validation_issues;

    def validate_hed_string(self, hed_string):
        """Validates the tags in a HED string.

         Parameters
         ----------
         hed_string: string
            A HED string.
         Returns
         -------
         string
             The validation issues associated with the HED string.

         """
        validation_issues = '';
        hed_string_delimiter = HedStringDelimiter(hed_string);
        validation_issues += self.tag_validator.run_hed_string_validators(hed_string);
        if not validation_issues:
            validation_issues += self.validate_individual_tags_in_hed_string(hed_string_delimiter);
            validation_issues += self.validate_top_levels_in_hed_string(hed_string_delimiter);
            validation_issues += self.validate_tag_levels_in_hed_string(hed_string_delimiter);
            validation_issues += self.validate_groups_in_hed_string(hed_string_delimiter);
        return validation_issues;

    def validate_tag_levels_in_hed_string(self, hed_string_delimiter):
        """Validates the tags at each level in a HED string. This pertains to the top-level, all groups, and nested
           groups.

         Parameters
         ----------
         hed_string_delimiter: HedStringDelimiter object
            A HEDStringDelimiter object.
         Returns
         -------
         string
             The validation issues associated with each level in the HED string.

         """
        validation_issues = '';
        tag_groups = hed_string_delimiter.get_tag_groups();
        formatted_tag_groups = hed_string_delimiter.get_formatted_tag_groups();
        original_and_formatted_tag_groups = zip(tag_groups, formatted_tag_groups);
        for original_tag_group, formatted_tag_group in original_and_formatted_tag_groups:
            validation_issues += self.tag_validator.run_tag_level_validators(original_tag_group, formatted_tag_group);
        top_level_tags = hed_string_delimiter.get_top_level_tags();
        formatted_top_level_tags = hed_string_delimiter.get_formatted_top_level_tags();
        original_and_formatted_top_level_tags = zip(top_level_tags, formatted_top_level_tags);
        for top_level_tag, formatted_top_level_tag in original_and_formatted_top_level_tags:
            validation_issues += self.tag_validator.run_tag_level_validators(top_level_tag, formatted_top_level_tag);
        return validation_issues;

    def validate_top_levels_in_hed_string(self, hed_string_delimiter):
        """Validates the top-level tags in a HED string.

         Parameters
         ----------
         hed_string_delimiter: HedStringDelimiter object
            A HEDStringDelimiter object.
         Returns
         -------
         string
             The validation issues associated with the top-level tags in the HED string.

         """
        validation_issues = '';
        formatted_top_level_tags = hed_string_delimiter.get_formatted_top_level_tags();
        validation_issues += self.tag_validator.run_top_level_validators(formatted_top_level_tags);
        return validation_issues;

    def validate_groups_in_hed_string(self, hed_string_delimiter):
        """Validates the groups in a HED string.

         Parameters
         ----------
         hed_string_delimiter: HedStringDelimiter object
            A HEDStringDelimiter object.
         Returns
         -------
         string
             The validation issues associated with the groups in the HED string.

         """
        validation_issues = '';
        tag_groups = hed_string_delimiter.get_tag_groups();
        formatted_tag_groups = hed_string_delimiter.get_formatted_tag_groups();
        original_and_formatted_tag_groups = zip(tag_groups, formatted_tag_groups);
        for original_tag_group, formatted_tag_group in original_and_formatted_tag_groups:
            validation_issues += self.tag_validator.run_tag_group_validators(original_tag_group);
        return validation_issues;

    def validate_individual_tags_in_hed_string(self, hed_string_delimiter):
        """Validates the individual tags in a HED string.

         Parameters
         ----------
         hed_string_delimiter: HedStringDelimiter object
            A HEDStringDelimiter object.
         Returns
         -------
         string
             The validation issues associated with the individual tags in the HED string.

         """
        validation_issues = '';
        tag_set = hed_string_delimiter.get_tag_set();
        formatted_tag_set = hed_string_delimiter.get_formatted_tag_set();
        original_and_formatted_tags = zip(tag_set, formatted_tag_set);
        for original_tag, formatted_tag in original_and_formatted_tags:
            validation_issues += self.tag_validator.run_individual_tag_validators(original_tag, formatted_tag);
        return validation_issues;

    @staticmethod
    def row_contains_headers(has_headers, row_number):
        """Checks to see if the row contains headers.

         Parameters
         ----------
        has_headers: boolean
            True if file has headers. False, if otherwise.
         row_number: integer
            The row number of the spreadsheet.
         Returns
         -------
         boolean
             True if the row contains the headers. False, if otherwise.

         """
        return has_headers and row_number == 0

    @staticmethod
    def generate_row_issue_message(row_number, has_headers=True):
        """Generates a row issue message that is associated with a particular row in a spreadsheet.

         Parameters
         ----------
         row_number: integer
            The row number that the issue is associated with.
         Returns
         -------
         string
             The row issue message.

         """
        if has_headers:
            row_number += 1;
        return error_reporter.report_error_type('row', error_row=row_number);

    @staticmethod
    def file_is_a_text_file(file_extension):
        """Checks to see if the file extension provided is one that corresponds to a text file.

         Parameters
         ----------
         file_extension: string
            A file extension.
         Returns
         -------
         boolean
             True if the file is a text file. False, if otherwise.

         """
        return file_extension in HedInputReader.TEXT_EXTENSION;

    @staticmethod
    def hed_input_has_valid_file_extension(hed_input):
        """Checks to see if the hed input has a valid file extension.

        Parameters
        ----------
        Returns
        -------
        boolean
            True if the hed input has a valid file extension. False, if otherwise.

        """
        hed_input_has_extension = HedInputReader.file_path_has_extension(hed_input);
        hed_input_file_extension = HedInputReader.get_file_extension(hed_input);
        return hed_input_has_extension and hed_input_file_extension in HedInputReader.FILE_EXTENSION;

    @staticmethod
    def get_delimiter_from_text_file_extension(file_extension):
        """Gets the delimiter that is associated with the file extension.

        Parameters
        ----------
        file_extension: string
            A file extension.
        Returns
        -------
        string
            The delimiter that is associated with the file extension. For example, .txt and .tsv will return tab
            as the delimiter and .csv will return comma as the delimiter.

        """
        delimiter = '';
        if file_extension in HedInputReader.TSV_EXTENSION:
            delimiter = HedInputReader.TAB_DELIMITER;
        elif file_extension in HedInputReader.CSV_EXTENSION:
            delimiter = HedInputReader.COMMA_DELIMITER;
        return delimiter;

    @staticmethod
    def open_workbook_worksheet(workbook_path, worksheet_name=''):
        """Opens an Excel workbook worksheet.

        Parameters
        ----------
        workbook_path: string
            The path to an Excel workbook.
        worksheet_name: string
            The name of the workbook worksheet that will be opened. The default will be the first worksheet of the
            workbook.
        Returns
        -------
        Sheet object
            A Sheet object representing an Excel workbook worksheet.

        """
        workbook = xlrd.open_workbook(workbook_path);
        if not worksheet_name:
            return workbook.sheet_by_index(0);
        return workbook.sheet_names(worksheet_name);

    @staticmethod
    def get_hed_tag_from_excel_file(worksheet, tag_columns):
        """Reads the next row of HED tags from the excel file.

        Parameters
        ----------
        worksheet: Sheet object
             A Sheet object representing an Excel workbook worksheet.
        tag_columns: list
            A list of integers containing the columns that contain the HED tags.
        Returns
        -------
        list
            A list of containing the HED tags. Each element in the list contains the HED tags from a particular column.

        """
        pass;

    @staticmethod
    def get_hed_string_from_text_file_row(text_file_row, hed_tag_columns, column_delimiter,
                                          prefixed_needed_tag_columns={}):
        """Reads in the current row of HED tags from the text file. The hed tag columns will be concatenated to form a
           HED string.

        Parameters
        ----------
        text_file_row: string
            The row in the text file that contains the HED tags.
        hed_tag_columns: list
            A list of integers containing the columns that contain the HED tags.
        column_delimiter: string
            A delimiter used to split the columns.
        prefixed_needed_tag_columns: dictionary
            A dictionary containing the HED tag column names that corresponds to tags that need to be prefixed with a
            parent tag path.
        Returns
        -------
        string
            A HED string containing the concatenated HED tag columns.

        """
        hed_tags = [];
        # if column_delimiter == HedInputReader.COMMA_DELIMITER:
        split_row = HedInputReader.split_delimiter_separated_string_with_quotes(text_file_row, column_delimiter);
        # else:
        #     split_row = text_file_row.split(column_delimiter);
        for hed_tag_column in hed_tag_columns:
            row_hed_tags = split_row[hed_tag_column];
            if hed_tag_column in prefixed_needed_tag_columns:
                row_hed_tags = HedInputReader.prepend_paths_to_prefixed_needed_tag_columns(row_hed_tags,
                                                                                           prefixed_needed_tag_columns,
                                                                                           hed_tag_column);
            hed_tags.append(row_hed_tags);
        return ','.join(hed_tags);

    @staticmethod
    def prepend_paths_to_prefixed_needed_tag_columns(hed_tags, prefixed_needed_tag_columns,
                                                     prefixed_needed_tag_column_key):
        prepended_hed_tags = [];
        split_hed_tags = hed_tags.split(',');
        for hed_tag in split_hed_tags:
            prepended_hed_tag = prefixed_needed_tag_columns[prefixed_needed_tag_column_key] + hed_tag;
            prepended_hed_tags.append(prepended_hed_tag);
        return ','.join(hed_tags);

    @staticmethod
    def split_delimiter_separated_string_with_quotes(delimiter_separated_string, delimiter):
        """Splits a comma separated-string.

        Parameters
        ----------
        delimiter_separated_string
            A delimiter separated string.
        delimiter
            A delimiter used to split the string.
        Returns
        -------
        list
            A list containing the individual tags and tag groups in the HED string. Nested tag groups are not split.

        """
        split_string = [];
        number_of_double_quotes = 0;
        current_tag = '';
        for character in delimiter_separated_string:
            if character == HedStringDelimiter.DOUBLE_QUOTE_CHARACTER:
                number_of_double_quotes += 1;
            elif number_of_double_quotes % 2 == 0 and character == delimiter:
                split_string.append(current_tag.strip());
                current_tag = '';
            else:
                current_tag += character;
        split_string.append(current_tag.strip());
        return split_string;

    @staticmethod
    def subtract_1_from_list_elements(integer_list):
        """Reads the next row of HED tags from the text file.

        Parameters
        ----------
        integer_list: list
            A list of integers.
        Returns
        -------
        list
            A list of containing each element subtracted by 1.

        """
        return [x-1 for x in integer_list];

    @staticmethod
    def subtract_1_from_dictionary_keys(integer_dictionary):
        """Reads the next row of HED tags from the text file.

        Parameters
        ----------
        integer_list: list
            A list of integers.
        Returns
        -------
        list
            A list of containing each element subtracted by 1.

        """
        minus_1_dictionary = {};
        keys = integer_dictionary.keys();
        keys = [x-1 for x in keys];
        values = integer_dictionary.values();
        key_values = zip(keys, values);
        for key, value in key_values:
            minus_1_dictionary[key] = value;
        return minus_1_dictionary;
    
    @staticmethod
    def file_path_has_extension(file_path):
        """Checks to see if file path has an extension.

        Parameters
        ----------
        file_path: string
             A file path.
        Returns
        -------
        boolean
            Returns True if the file path has an extension. False, if otherwise.

        """
        if len(file_path.rsplit('.', 1)) > 1:
            return True;
        return False;

    @staticmethod
    def get_file_extension(file_path):
        """Reads the next row of HED tags from the text file.

        Parameters
        ----------
        file_path: string
             A file path.
        Returns
        -------
        string
            The extension of the file path.

        """
        return file_path.rsplit('.', 1)[-1].lower();


if __name__ == '__main__':
    spreadsheet_path = '../tests/data/TX14 HED Tags v9.87.tsv';
    # hed_string = 'Event/Category/Participant response, ' \
    #              '(Participant ~ Action/Button press/Keyboard ~ Participant/Effect/Body part/Arm/Hand/Finger)';
    prefixed_needed_tag_columns = {2: 'Long', 3: 'Description', 4: 'Label', 5: 'Category', 7: 'Attribute'}
    hed_input_reader = HedInputReader(spreadsheet_path, tag_columns=[2,3,4,5,6,7], prefixed_needed_tag_columns=prefixed_needed_tag_columns);
    print(hed_input_reader.validation_issues);
    # print(hed_input_reader.validation_issues);
    # a = 'tag1,tag2,"tag3,tag4"';
    # split_string = HedInputReader.split_delimiter_separated_string_with_quotes(a);





