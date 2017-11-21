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

    def __init__(self, hed_input, hed_tag_columns=2, worksheet='', specific_hed_tag_columns={}):
        self.hed_input = hed_input;
        self.hed_tag_columns = HedInputReader.subtract_1_from_list_elements(hed_tag_columns);
        self.worksheet = worksheet;
        self.specific_hed_tag_columns = specific_hed_tag_columns;
        if self.hed_input_has_valid_file_extension:
            pass;
        else:
            self.validate_hed_string(self.hed_input);

    def hed_input_is_a_text

    def validate_hed_tags_in_file(self):

    pass;

    def hed_input_has_valid_file_extension(self):
        """Checks to see if the hed input has a valid file extension.

        Parameters
        ----------
        Returns
        -------
        boolean
            True if the hed input has a valid file extension. False, if otherwise.

        """
        hed_input_has_extension = HedInputReader.file_path_has_extension(self.hed_input);
        hed_input_file_extension = HedInputReader.get_file_extension(self.hed_input);
        if hed_input_has_extension and hed_input_file_extension in HedInputReader.FILE_EXTENSION:
            return True;
        return False;

    def validate_hed_tags_in_text_file(self):
        with open(self.hed_input) as opened_text_file:
            for text_file_line in opened_text_file:
                HedInputReader.get_hed_tag_from_text_file(text_file_line, self.hed_tag_columns, self.column_delimiter)
                pass;


    def check_hed_input_type(self):
        if extension in HedInputReader.TSV_EXTENSION:
            self.delimiter = HedInputReader.TAB_DELIMITER;
        elif extension in HedInputReader.CSV_EXTENSION:
            self.delimiter = HedInputReader.COMMA_DELIMITER;
        elif extension in HedInputReader.EXCEL_EXTENSION:
            pass;

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
    def get_hed_tag_from_text_file_line(text_file_line, hed_tag_columns, column_delimiter):
        """Reads the next line of HED tags from the text file.

        Parameters
        ----------
        text_file_line: string
            The line in the text file that contains the HED tags.
        hed_tag_columns: list
            A list of integers containing the columns that contain the HED tags.
        column_delimiter: string
            A delimiter used to split the columns.
        Returns
        -------
        list
            A list of containing the HED tags. Each element in the list contains the HED tags from a particular column.

        """
        split_line = text_file_line.split(column_delimiter);
        pass;

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




