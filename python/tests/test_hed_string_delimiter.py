import unittest;
from validation.hed_string_delimiter import HedStringDelimiter;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mixed_hed_string = 'tag1,(tag2,tag5,(tag1),tag6),tag2,(tag3,tag5,tag6),tag3';
        cls.group_hed_string = '(tag1, tag2)';
        cls.removal_elements = ['(tag2,tag5,(tag1),tag6)', '(tag3,tag5,tag6)'];

    def test_split_hed_string(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter._split_hed_string();
        self.assertTrue(tag_set);
        self.assertIsInstance(tag_set, set);

    def test_get_tag_set(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter.get_tag_set();
        self.assertTrue(tag_set);
        self.assertIsInstance(tag_set, set);

    def test_get_top_level_tags(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter.get_tag_set();
        top_level_tag_set = hed_string_delimiter.get_top_level_tags();
        self.assertTrue(top_level_tag_set);
        self.assertIsInstance(top_level_tag_set, set);
        self.assertNotEqual(len(tag_set), len(top_level_tag_set));

    def test_hed_string_is_a_group(self):
        is_group = HedStringDelimiter.hed_string_is_a_group(self.mixed_hed_string);
        self.assertFalse(is_group);
        self.assertIsInstance(is_group, bool);
        is_group = HedStringDelimiter.hed_string_is_a_group(self.group_hed_string);
        self.assertTrue(is_group);
        self.assertIsInstance(is_group, bool);

if __name__ == '__main__':
    unittest.main();
