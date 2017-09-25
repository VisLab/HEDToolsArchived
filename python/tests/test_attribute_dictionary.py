import unittest;
import defusedxml;
from defusedxml.lxml import parse;
from validation import attribute_dictionary;
import random;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.HED_XML = 'data/HED.xml';
        self.tag_attributes = ['extensionAllowed', 'requireChild', 'takesValue', 'isNumeric', 'required', \
                               'position', 'unique', 'predicateType'];

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

    def test_get_tag_name(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        tag_name = attribute_dictionary.get_tag_name(tag_element);
        self.assertIsInstance(tag_name, basestring);
        self.assertTrue(tag_name);

    def test_get_parent_tag_name(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        parent_tag_name = attribute_dictionary.get_parent_tag_name(tag_element);
        self.assertIsInstance(parent_tag_name, basestring);
        self.assertTrue(parent_tag_name);

    def test_get_tag_path(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        parent_tag_name = attribute_dictionary.get_tag_path(tag_element);
        self.assertIsInstance(parent_tag_name, basestring);
        self.assertTrue(parent_tag_name);

    def test_get_all_ancestor_tag_names(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        all_ancestor_tags = attribute_dictionary.get_ancestor_tag_names(tag_element);
        self.assertIsInstance(all_ancestor_tags, list);
        self.assertTrue(all_ancestor_tags);

    def test_get_tag_paths_by_attribute(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        for tag_attribute in self.tag_attributes:
            print(tag_attribute);
            tag_paths = attribute_dictionary.get_tag_paths_by_attribute(hed_root_element, tag_attribute);
            self.assertIsInstance(tag_paths, list);
            self.assertTrue(tag_paths);

if __name__ == '__main__':
    unittest.main();
