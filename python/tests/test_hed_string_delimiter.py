import unittest;
from validation.hed_string_delimiter import HedStringDelimiter;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mixed_hed_string = 'tag1,(tag2,tag5,(tag1),tag6),tag2,(tag3,tag5,tag6),tag3';

    def test_split_top_level_hed_string_tags(self):
        hed_string_delimiter = HedStringDelimiter(self.mixed_hed_string);
        top_level_tag_set = hed_string_delimiter.split_top_level_hed_string_tags();
        self.assertTrue(top_level_tag_set);
        self.assertIsInstance(top_level_tag_set, set);

if __name__ == '__main__':
    unittest.main();
