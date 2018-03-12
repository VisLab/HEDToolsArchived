import unittest;
from webinterface import utils;
import os;


class Test(unittest.TestCase):
    def setUp(self):
        self.major_version_key = 'major_versions';
        self.hed_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data/HED.xml');
        self.tsv_file1 = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data/tsv_file1.txt');

    def test_find_major_hed_versions(self):
        hed_info = utils.find_major_hed_versions();
        self.assertTrue(self.major_version_key in hed_info);

    def test_file_extension_is_valid(self):
        file_name = 'abc.' + utils.SPREADSHEET_FILE_EXTENSIONS[0];
        is_valid = utils._file_extension_is_valid(file_name, utils.SPREADSHEET_FILE_EXTENSIONS);
        self.assertTrue(is_valid);

    def test_get_validation_issue_count(self):
        issue_count = utils._get_validation_issue_count('');
        self.assertEqual(issue_count, 0);
        issue_count = utils._get_validation_issue_count('\t');
        self.assertEqual(issue_count, 1);

    def test_generate_spreadsheet_validation_filename(self):
        spreadsheet_filename = 'abc.xls';
        expected_spreadsheet_filename = 'validated_' + spreadsheet_filename.rsplit('.')[0] + '.txt';
        validation_file_name = utils._generate_spreadsheet_validation_filename(spreadsheet_filename, worksheet_name='');
        self.assertTrue(validation_file_name);
        self.assertEqual(expected_spreadsheet_filename, validation_file_name);

    def test_get_file_extension(self):
        spreadsheet_filename = 'abc.xls';
        expected_extension = 'xls';
        file_extension = utils._get_file_extension(spreadsheet_filename);
        self.assertTrue(file_extension);
        self.assertEqual(expected_extension, file_extension);

    def test_convert_other_tag_columns_to_list(self):
        other_tag_columns_str = '1,2,3';
        expected_other_columns = [1,2,3];
        other_tag_columns = utils._convert_other_tag_columns_to_list(other_tag_columns_str);
        self.assertTrue(other_tag_columns);
        self.assertEqual(expected_other_columns, other_tag_columns);

    def test_delete_file_if_it_exist(self):
        some_file = '3k32j23kj.txt';
        deleted = utils.delete_file_if_it_exist(some_file);
        self.assertFalse(deleted);

    def test_create_folder_if_needed(self):
        some_folder = '3k32j23kj';
        created = utils._create_folder_if_needed(some_folder);
        self.assertTrue(created);
        os.rmdir(some_folder);

    def test_copy_file_line_by_line(self):
        some_file1 = '3k32j23kj1.txt';
        some_file2 = '3k32j23kj2.txt';
        success = utils._copy_file_line_by_line(some_file1, some_file2);
        self.assertFalse(success);

    def test_initialize_worksheets_info_dictionary(self):
        worksheets_info_dictionary = utils._initialize_worksheets_info_dictionary();
        self.assertTrue(worksheets_info_dictionary);
        self.assertIsInstance(worksheets_info_dictionary, dict);

    def test_initialize_spreadsheet_columns_info_dictionary(self):
        worksheets_info_dictionary = utils._initialize_spreadsheet_columns_info_dictionary();
        self.assertTrue(worksheets_info_dictionary);
        self.assertIsInstance(worksheets_info_dictionary, dict);

    def test_get_text_file_column_names(self):
        column_names = utils._get_text_file_column_names(self.tsv_file1, '\t');
        self.assertTrue(column_names);
        self.assertIsInstance(column_names, list);

    def test_get_column_delimiter_based_on_file_extension(self):
        delimiter = utils._get_column_delimiter_based_on_file_extension(self.tsv_file1);
        tab_delimiter = '\t';
        self.assertTrue(delimiter);
        self.assertIsInstance(delimiter, str);
        self.assertEqual(tab_delimiter, delimiter);


if __name__ == '__main__':
    unittest.main();
