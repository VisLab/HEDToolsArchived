import unittest;
from validation import tag_validator, tag_dictionary;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.hed_xml = '../tests/data/HED.xml';
        self.invalid_original_tag = 'This/Is/A/Tag';
        self.invalid_formatted_tag = 'this/is/a/tag';
        self.valid_original_tag = 'Event/Label';
        self.valid_formatted_tag = 'event/label';

    def test_check_if_tag_is_valid(self):
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        validation_error = tag_validator.check_if_tag_is_valid(tag_dictionaries, self.invalid_original_tag, \
                                                           self.invalid_formatted_tag);
        self.assertIsInstance(validation_error, basestring);
        self.assertTrue(validation_error);
        validation_error = tag_validator.check_if_tag_is_valid(tag_dictionaries, self.valid_original_tag, \
                                                           self.valid_formatted_tag);
        self.assertIsInstance(validation_error, basestring);
        self.assertFalse(validation_error);



if __name__ == '__main__':
    unittest.main();
