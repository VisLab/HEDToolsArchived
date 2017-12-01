import unittest;
from validation.hed_input_reader import HedInputReader;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.file_with_extension = 'file_with_extension.txt';

    def test_get_file_extension(self):
        file_extension = HedInputReader.get_file_extension(self.file_with_extension);
        self.assertIsInstance(file_extension, basestring);
        self.assertTrue(file_extension);

    def test_file_path_has_extension(self):
        file_extension = HedInputReader.file_path_has_extension(self.file_with_extension);
        self.assertIsInstance(file_extension, bool);
        self.assertTrue(file_extension);

if __name__ == '__main__':
    unittest.main();
