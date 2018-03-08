import unittest;
from webinterface import utils;


class Test(unittest.TestCase):
    def setUp(self):
        self.major_version_key = 'major_versions';

    def test_find_major_hed_versions(self):
        hed_info = utils.find_major_hed_versions();
        self.assertTrue(self.major_version_key in hed_info);

    def test_file_extension_is_valid(self):
        file_name = 'abc.' + utils.SPREADSHEET_FILE_EXTENSIONS[0];
        is_valid = utils._file_extension_is_valid(file_name, utils.SPREADSHEET_FILE_EXTENSIONS);
        self.assertTrue(is_valid);


if __name__ == '__main__':
    unittest.main();
