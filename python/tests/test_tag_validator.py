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
        self.valid_original_unique_tag_list = ['Event/Label/This is a label',
                                               'Event/Description/This is a description'];
        self.valid_formatted_unique_tag_list = ['event/label/this is a label',
             'event/description/this is a description'];
        self.invalid_original_unique_tag_list = ['Event/Label/This is a label', 'Event/Label/This is another label',
             'Event/Description/This is a description'];
        self.invalid_formatted_unique_tag_list = ['event/label/this is a label', 'event/label/this is another label',
             'event/description/this is a description'];
        self.valid_formatted_required_tag_list = ['event/label/this is a label', 'event/category/participant response',
             'event/description/this is a description'];
        self.invalid_formatted_required_tag_list = ['event/label/this is a label',
             'event/description/this is a description'];

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

    def test_check_if_multiple_unique_tags_exist(self):
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        validation_error = tag_validator.check_if_multiple_unique_tags_exist(tag_dictionaries, \
                                                                             self.valid_original_unique_tag_list, \
                                                                             self.valid_formatted_unique_tag_list);
        self.assertIsInstance(validation_error, basestring);
        self.assertFalse(validation_error);
        validation_error = tag_validator.check_if_multiple_unique_tags_exist(tag_dictionaries, \
                                                                             self.invalid_original_unique_tag_list, \
                                                                             self.invalid_formatted_unique_tag_list);
        self.assertIsInstance(validation_error, basestring);
        self.assertTrue(validation_error);

    def test_check_for_required_tags(self):
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        validation_error = tag_validator.check_for_required_tags(tag_dictionaries, 
                                                                             self.valid_formatted_required_tag_list);
        self.assertIsInstance(validation_error, basestring);
        self.assertFalse(validation_error);
        validation_error = tag_validator.check_for_required_tags(tag_dictionaries, 
                                                                             self.invalid_formatted_required_tag_list);
        self.assertIsInstance(validation_error, basestring);
        self.assertTrue(validation_error);

    def test_get_tag_path_slash_indices(self):
        tag_path_slash_indices = tag_validator.get_tag_path_slash_indices(self.valid_formatted_tag);
        self.assertIsInstance(tag_path_slash_indices, list);

    def test_get_tag_path_by_slash_indicie(self):
        tag_path_slash_indices = tag_validator.get_tag_path_slash_indices(self.valid_formatted_tag);
        tag_path = tag_validator.get_tag_path_substring_by_end_index(self.valid_formatted_tag,
                                                                             tag_path_slash_indices[0]);
        self.assertIsInstance(tag_path, basestring);
        self.assertNotEqual(self.valid_formatted_tag, tag_path);
        tag_path = tag_validator.get_tag_path_substring_by_end_index(self.valid_formatted_tag, 0);
        self.assertEqual(self.valid_formatted_tag, tag_path);

if __name__ == '__main__':
    unittest.main();
