import unittest;
from validation.hed_string_delimiter import HedStringDelimiter;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mixed_hed_string = 'tag1,(tag2,tag5,(tag1),tag6),tag2,(tag3,tag5,tag6),tag3';
        cls.removal_elements = ['(tag2,tag5,(tag1),tag6)', '(tag3,tag5,tag6)'];

    def test_split_hed_string(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        top_level_tag_set = hed_string_delimiter.split_hed_string();
        self.assertTrue(top_level_tag_set);
        self.assertIsInstance(top_level_tag_set, set);

    def test_get_tag_set(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter.get_tag_set();
        self.assertTrue(tag_set);
        self.assertIsInstance(tag_set, set);

    # def test_remove_elements_from_set(self):
    #     hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
    #     top_level_tags = hed_string_delimiter.split_hed_string();
    #     set_with_removed_elements = hed_string_delimiter.remove_elements_from_set(self.mixed_hed_string,
    #                                                                               self.removal_elements);
    #     self.assertTrue(set_with_removed_elements);
    #     self.assertIsInstance(set_with_removed_elements, set);

if __name__ == '__main__':
    unittest.main();
