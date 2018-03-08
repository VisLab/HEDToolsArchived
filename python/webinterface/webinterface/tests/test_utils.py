import unittest;
from webinterface import utils;
import os;


class Test(unittest.TestCase):
    def setUp(self):
        self.major_version_key = 'major_versions';
        self.hed_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data/HED.xml');

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

if __name__ == '__main__':
    unittest.main();
