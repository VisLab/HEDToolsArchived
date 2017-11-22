import xlrd;


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

    def __init__(self, hed_input, hed_tag_columns=2, worksheet='', prefixed_hed_tag_columns={}):
        """Constructor for the HedInputReader class.

        Parameters
        ----------
        hed_input: string
            A HED string or a spreadsheet file containing HED tags. If a string is passed in then no other arguments
            need to be specified.
        hed_tag_columns: list
            A list of integers containing the columns that contain the HED tags. The default value is the 2nd column.
        worksheet: string
            The name of the Excel workbook worksheet that contains the HED tags.
        prefixed_hed_tag_columns: dictionary
            A dictionary containing the HED tag column names that corresponds to tags that need to be prefixed with a
            parent tag path.
        Returns
        -------
        HedInputReader object
            A HedInputReader object.

        """
        self.hed_input = hed_input;
        self.hed_tag_columns = HedInputReader.subtract_1_from_list_elements(hed_tag_columns);
        self.worksheet = worksheet;
        self.prefixed_hed_tag_columns = prefixed_hed_tag_columns;
        if HedInputReader.hed_input_has_valid_file_extension(self.hed_input):
            self.file_extension = HedInputReader.get_file_extension(self.hed_input);
            if HedInputReader.file_is_a_text_file(self.file_extension):
                self.delimiter = HedInputReader.get_delimiter_from_text_file_extension(self.file_extension);
                self.validate_hed_tags_in_text_file(self);
            else:
                pass;
        else:
            self.validate_hed_string(self.hed_input);

    def validate_hed_tags_in_text_file(self):
        with open(self.hed_input) as opened_text_file:
            for text_file_line in opened_text_file:
                hed_string = HedInputReader.get_hed_string_from_text_file_line(text_file_line, self.hed_tag_columns,
                                                                               self.column_delimiter);
                self.validate_hed_string(hed_string);
                pass;

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
    def validate_hed_string(self, hed_string):
        return '';


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
        """Reads the next line of HED tags from the excel file.

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
    def get_hed_string_from_text_file_line(text_file_line, hed_tag_columns, column_delimiter,
                                           prefixed_hed_tag_columns={}):
        """Reads in the current line of HED tags from the text file. The hed tag columns will be concatenated to form a
           HED string.

        Parameters
        ----------
        text_file_line: string
            The line in the text file that contains the HED tags.
        hed_tag_columns: list
            A list of integers containing the columns that contain the HED tags.
        column_delimiter: string
            A delimiter used to split the columns.
        prefixed_hed_tag_columns: dictionary
            A dictionary containing the HED tag column names that corresponds to tags that need to be prefixed with a
            parent tag path.
        Returns
        -------
        string
            A HED string containing the concatenated HED tag columns.

        """
        split_line = text_file_line.split(column_delimiter);
        hed_tags = [];
        for hed_tag_column in hed_tag_columns:
            hed_tags.append(split_line[hed_tag_column]);
        return ','.join(hed_tags);

    @staticmethod
    def subtract_1_from_list_elements(integer_list):
        """Reads the next line of HED tags from the text file.

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
        """Reads the next line of HED tags from the text file.

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
    a = 'fdskjfdkfjdkdslfjtsv';
    print(a.rsplit('.', 1)[-1]);




