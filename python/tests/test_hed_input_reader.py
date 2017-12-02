import unittest;
from validation.hed_input_reader import HedInputReader;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.file_with_extension = 'file_with_extension.txt';
        cls.integer_key_dictionary = {1: 'one', 2: 'two', 3: 'three'};
        cls.integer_list = [1, 2, 3];
        cls.comma_separated_string_with_double_quotes = 'a,b,c,"d,e,f"';
        cls.comma_delimited_list_with_double_quotes = ['a', 'b', 'c', "d,e,f"];
        cls.comma_delimiter = ',';

    def test_get_file_extension(self):
        file_extension = HedInputReader.get_file_extension(self.file_with_extension);
        self.assertIsInstance(file_extension, basestring);
        self.assertTrue(file_extension);

    def test_file_path_has_extension(self):
        file_extension = HedInputReader.file_path_has_extension(self.file_with_extension);
        self.assertIsInstance(file_extension, bool);
        self.assertTrue(file_extension);

    def test_subtract_1_from_dictionary_keys(self):
        one_subtracted_key_dictionary = HedInputReader.subtract_1_from_dictionary_keys(self.integer_key_dictionary);
        self.assertIsInstance(one_subtracted_key_dictionary, dict);
        self.assertTrue(one_subtracted_key_dictionary);
        original_dictionary_key_sum = sum(self.integer_key_dictionary.keys());
        new_dictionary_key_sum = sum(one_subtracted_key_dictionary.keys());
        original_dictionary_key_length = len(self.integer_key_dictionary.keys());
        self.assertEqual(original_dictionary_key_sum - new_dictionary_key_sum, original_dictionary_key_length);

    def test_subtract_1_from_list_elements(self):
        one_subtracted_list = HedInputReader.subtract_1_from_list_elements(self.integer_list);
        self.assertIsInstance(one_subtracted_list, list);
        self.assertTrue(one_subtracted_list);
        original_list_sum = sum(self.integer_list);
        new_list_sum = sum(one_subtracted_list);
        original_list_length = len(self.integer_list);
        self.assertEqual(original_list_sum - new_list_sum, original_list_length);

    def test_split_delimiter_separated_string_with_quotes(self):
        split_string = HedInputReader.split_delimiter_separated_string_with_quotes(
            self.comma_separated_string_with_double_quotes,
            self.comma_delimiter);
        self.assertIsInstance(split_string, list);
        self.assertEqual(split_string, self.comma_delimited_list_with_double_quotes);



if __name__ == '__main__':
    unittest.main();
