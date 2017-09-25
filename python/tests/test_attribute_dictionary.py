import unittest;
import defusedxml;
from defusedxml.lxml import parse;
from validation import attribute_dictionary;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.HED_XML = 'data/HED.xml';

    def test_get_hed_root_element(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        self.assertIsInstance(hed_root_element, defusedxml.lxml.RestrictedElement);

    def test_get_parent_tag_name(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        all_nodes = hed_root_element.xpath('.//node');
        tag_element = all_nodes[24];
        parent_tag_name = attribute_dictionary.get_parent_tag_name(tag_element);
        self.assertIsInstance(parent_tag_name, basestring);
        self.assertTrue(parent_tag_name);


if __name__ == '__main__':
    unittest.main();
