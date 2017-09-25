import unittest;
import defusedxml;
from defusedxml.lxml import parse;
from validation import attribute_dictionary;
import random;


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
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        parent_tag_name = attribute_dictionary.get_parent_tag_name(tag_element);
        self.assertIsInstance(parent_tag_name, basestring);
        self.assertTrue(parent_tag_name);

    def test_get_parent_tag_name(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        parent_tag_name = attribute_dictionary.get_parent_tag_name(tag_element);
        self.assertIsInstance(parent_tag_name, basestring);
        self.assertTrue(parent_tag_name);

    def test_get_all_ancestor_tags(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        all_ancestor_tags = attribute_dictionary.get_all_ancestor_tags(tag_element);
        self.assertIsInstance(all_ancestor_tags, list);
        self.assertTrue(all_ancestor_tags);


if __name__ == '__main__':
    unittest.main();
