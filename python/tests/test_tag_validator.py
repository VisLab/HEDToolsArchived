import unittest;
from validation import tag_validator, tag_dictionary;
import random;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.hed_xml = '../tests/data/HED.xml';
        self.tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        random_require_child_key = random.randint(0, len(self.tag_dictionaries['requireChild']));
        random_tag_key = random.randint(0, len(self.tag_dictionaries['tags']));
        self.required_child_tag = \
            self.tag_dictionaries['requireChild'][self.tag_dictionaries['requireChild'].keys()[random_require_child_key]];
        self.invalid_original_tag = 'This/Is/A/Tag';
        self.invalid_formatted_tag = 'this/is/a/tag';
        self.valid_original_tag = 'Event/Label';
        self.valid_formatted_tag = 'event/label';
        self.valid_tag_group_string = 'This/Is/A/Tag ~ This/Is/Another/Tag ~ This/Is/A/Different/Tag';
        self.invalid_tag_group_string = 'This/Is/A/Tag ~ ~ This/Is/Another/Tag ~ This/Is/A/Different/Tag';

    def test_check_if_tag_is_valid(self):
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        validation_error = tag_validator.check_if_tag_is_valid(self.tag_dictionaries, self.invalid_original_tag, \
                                                           self.invalid_formatted_tag);
        self.assertIsInstance(validation_error, basestring);
        self.assertTrue(validation_error);
        validation_error = tag_validator.check_if_tag_is_valid(self.tag_dictionaries, self.valid_original_tag, \
                                                           self.valid_formatted_tag);
        self.assertIsInstance(validation_error, basestring);
        self.assertFalse(validation_error);

    def test_check_if_tag_requires_child(self):
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        validation_error = tag_validator.check_if_tag_requires_child(self.tag_dictionaries, self.required_child_tag, \
                                                           self.required_child_tag);
        self.assertIsInstance(validation_error, basestring);
        self.assertFalse(validation_error);

    def test_check_number_of_group_tildes(self):
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        validation_error = tag_validator.check_number_of_group_tildes(self.valid_tag_group_string);
        self.assertIsInstance(validation_error, basestring);
        self.assertFalse(validation_error);
        validation_error = tag_validator.check_number_of_group_tildes(self.invalid_tag_group_string);
        self.assertIsInstance(validation_error, basestring);
        self.assertTrue(validation_error);

if __name__ == '__main__':
    a = {1:'a', 2:'b'};
    print(len(a))
    # unittest.main();
