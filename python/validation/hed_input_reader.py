import warnings;
import xlrd;

class HedInputReader:

    TSV_EXTENSION = ['tsv', 'txt'];
    CSV_EXTENSION = ['csv'];
    EXCEL_EXTENSION = ['xls', 'xlsx'];
    FILE_EXTENSION = ['csv', 'tsv', 'txt', 'xls', 'xlsx'];
    STRING_INPUT = 'string';
    FILE_INPUT = 'file';
    TAB_DELIMITER = '\t';
    COMMA_DELIMITER = ',';


    def __init__(self, hed_input, hed_tag_columns=2, worksheet='', specific_hed_tag_columns={}):
        self.hed_input = hed_input;
        self.hed_tag_columns;
        self.worksheet = worksheet;
        self.specific_hed_tag_columns = specific_hed_tag_columns;
        self.check_hed_input_type(hed_input);
        self.file_extension = HedInputReader.get_file_extension(hed_input);
        if HedInputReader.get_file_extension(hed_input) in HedInputReader.FILE_EXTENSION:
            self.validate_hed_tags_in_file(hed_input);


        if self.type == HedInputReader.STRING_INPUT:
            self.validate_hed_string(hed_input);
        else:

    def validate_hed_tags_in_file(self):
        with open
        pass;

    def check_hed_input_type(self, hed_input):
        split_hed_input = hed_input.rsplit('.', 1);
        if split_hed_input > 1:
            self.type = HedInputReader.FILE_INPUT;
            extension = split_hed_input[-1].lower();
            if extension in HedInputReader.TSV_EXTENSION:
                self.delimiter = HedInputReader.TAB_DELIMITER;
            elif extension in HedInputReader.CSV_EXTENSION:
                self.delimiter = HedInputReader.COMMA_DELIMITER;
            elif extension in HedInputReader.EXCEL_EXTENSION:
                pass;
            else:
                warnings.warn('File input specified is not supported');
        else:
            self.type = HedInputReader.FILE_INPUT;

    def validate_hed_string(self, hed_string):
        pass;

    @staticmethod
    def open_workbook_worksheet(self, workbook_path, worksheet_name=''):
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
    def get_hed_tag_from_text_file(file_object, tag_columns, column_delimiter):
        """Reads the next line of HED tags from the text file.

        Parameters
        ----------
        file_object: file object
             A file object pointing to a text file.
        tag_columns: list
            A list of integers containing the columns that contain the HED tags.
        column_delimiter: string
            A delimiter used to split the columns.
        Returns
        -------
        list
            A list of containing the HED tags. Each element in the list contains the HED tags from a particular column.

        """
        pass;

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




