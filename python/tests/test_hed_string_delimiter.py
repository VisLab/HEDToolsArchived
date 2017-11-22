import unittest;
from validation.hed_string_delimiter import HedStringDelimiter;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mixed_hed_string = 'tag1,(tag2,tag5,(tag1),tag6),tag2,(tag3,tag5,tag6),tag3';
        cls.group_hed_string = '(tag1, tag2)';
        cls.removal_elements = ['(tag2,tag5,(tag1),tag6)', '(tag3,tag5,tag6)'];
        cls.unformatted_tag = '/Event/label/This label ends with a slash/'

    def test_split_hed_string_into_list(self):
        split_hed_string = HedStringDelimiter.split_hed_string_into_list(self.mixed_hed_string);
        self.assertTrue(split_hed_string);
        self.assertIsInstance(split_hed_string, list);

    def test_format_hed_tags_in_set(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter.get_tag_set();
        formatted_tag_set = HedStringDelimiter.format_hed_tags_in_set(tag_set);
        self.assertIsInstance(formatted_tag_set, set);
        self.assertEqual(len(tag_set), len(formatted_tag_set));

    def test_format_hed_tag(self):
        formatted_tag = HedStringDelimiter.format_hed_tag(self.unformatted_tag);
        correct_formatted_tag = self.unformatted_tag[1:-1].lower();
        self.assertTrue(formatted_tag);
        self.assertIsInstance(formatted_tag, basestring)
        self.assertNotEqual(self.unformatted_tag, formatted_tag);
        self.assertEqual(formatted_tag, correct_formatted_tag);

    def test_get_tag_set(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter.get_tag_set();
        self.assertTrue(tag_set);
        self.assertIsInstance(tag_set, set);

    def test_get_hed_string(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        hed_string = hed_string_delimiter.get_hed_string();
        self.assertTrue(hed_string);
        self.assertIsInstance(hed_string, basestring);
        self.assertEqual(hed_string, self.mixed_hed_string);

    def test_get_split_hed_string(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        split_hed_string = hed_string_delimiter.get_split_hed_string();
        self.assertTrue(split_hed_string);
        self.assertIsInstance(split_hed_string, list);

    def test_get_top_level_tags(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter.get_tag_set();
        top_level_tags = hed_string_delimiter.get_top_level_tags();
        self.assertTrue(top_level_tags);
        self.assertIsInstance(top_level_tags, list);
        self.assertNotEqual(len(tag_set), len(top_level_tags));

    def test__find_top_level_tags(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter.get_tag_set();
        top_level_tags_1 = hed_string_delimiter.get_top_level_tags();
        self.assertTrue(top_level_tags_1);
        self.assertIsInstance(top_level_tags_1, list);
        self.assertNotEqual(len(tag_set), len(top_level_tags_1));
        hed_string_delimiter._find_top_level_tags();
        top_level_tags_2 = hed_string_delimiter.get_top_level_tags();
        self.assertTrue(top_level_tags_2);
        self.assertIsInstance(top_level_tags_2, list);
        self.assertNotEqual(len(tag_set), len(top_level_tags_2));
        self.assertEqual(top_level_tags_1, top_level_tags_2);

    def test_get_tag_groups(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter.get_tag_set();
        group_tags = hed_string_delimiter.get_tag_groups();
        self.assertTrue(group_tags);
        self.assertIsInstance(group_tags, list);
        self.assertNotEqual(len(tag_set), len(group_tags));

    def test_find_group_tags(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        tag_set = hed_string_delimiter.get_tag_set();
        group_tags_1 = hed_string_delimiter.get_tag_groups();
        self.assertTrue(group_tags_1);
        self.assertIsInstance(group_tags_1, list);
        self.assertNotEqual(len(tag_set), len(group_tags_1));
        hed_string_delimiter._find_group_tags(hed_string_delimiter.get_split_hed_string());
        group_tags_2 = hed_string_delimiter.get_tag_groups();
        self.assertTrue(group_tags_2);
        self.assertIsInstance(group_tags_2, list);
        self.assertNotEqual(len(tag_set), len(group_tags_2));
        self.assertEqual(group_tags_1, group_tags_2);

    def test_hed_string_is_a_group(self):
        is_group = HedStringDelimiter.hed_string_is_a_group(self.mixed_hed_string);
        self.assertFalse(is_group);
        self.assertIsInstance(is_group, bool);
        is_group = HedStringDelimiter.hed_string_is_a_group(self.group_hed_string);
        self.assertTrue(is_group);
        self.assertIsInstance(is_group, bool);


if __name__ == '__main__':
    unittest.main();
