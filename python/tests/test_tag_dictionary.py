import unittest;
import defusedxml;
from defusedxml.lxml import parse;
from validation import tag_dictionary;
import random;


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.hed_xml = 'data/HED.xml';
        self.unit_class_tag = 'unitClass';
        self.tag_attributes = ['extensionAllowed', 'requireChild', 'takesValue', 'isNumeric', 'required', \
                               'position', 'unique', 'predicateType', 'default'];
        self.default_tag_attribute = 'default';
        self.string_list = ['This/Is/A/Tag', 'This/Is/Another/Tag'];

    def test_get_hed_root_element(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        self.assertIsInstance(hed_root_element, defusedxml.lxml.RestrictedElement);

    def test_get_parent_tag_name(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        parent_tag_name = tag_dictionary.get_parent_tag_name(tag_element);
        self.assertIsInstance(parent_tag_name, basestring);
        self.assertTrue(parent_tag_name);

    def test_get_element_tag_value(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        tag_name = tag_dictionary.get_element_tag_value(tag_element);
        self.assertIsInstance(tag_name, basestring);
        self.assertTrue(tag_name);

    def test_get_parent_tag_name(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        parent_tag_name = tag_dictionary.get_parent_tag_name(tag_element);
        self.assertIsInstance(parent_tag_name, basestring);

    def test_get_tag_name_from_tag_element(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        tag_elements = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(tag_elements));
        tag_element = tag_elements[random_node];
        parent_tag_name = tag_dictionary.get_tag_name_from_tag_element(tag_element);
        self.assertIsInstance(parent_tag_name, basestring);
        self.assertTrue(parent_tag_name);

    def test_get_all_ancestor_tag_names(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        all_nodes = hed_root_element.xpath('.//node');
        random_node = random.randint(1, len(all_nodes));
        tag_element = all_nodes[random_node];
        all_ancestor_tags = tag_dictionary.get_ancestor_tag_names(tag_element);
        self.assertIsInstance(all_ancestor_tags, list);
        self.assertTrue(all_ancestor_tags);

    def test_get_tags_by_attribute(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        for tag_attribute in self.tag_attributes:
            attribute_tags, attribute_tag_elements = tag_dictionary.get_tags_by_attribute(hed_root_element, tag_attribute);
            self.assertIsInstance(attribute_tags, list);
            self.assertTrue(attribute_tags);

    def test_string_list_2_lowercase_dictionary(self):
        lowercase_dictionary = tag_dictionary.string_list_2_lowercase_dictionary(self.string_list);
        self.assertIsInstance(lowercase_dictionary, dict);
        self.assertTrue(lowercase_dictionary);

    def test_populate_tag_attribute_dictionaries(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml)
        attribute_dictionaries = tag_dictionary.populate_tag_attribute_dictionaries(hed_root_element);
        self.assertIsInstance(attribute_dictionaries, dict);
        for attribute_dictionary_key in attribute_dictionaries:
            self.assertIsInstance(attribute_dictionaries[attribute_dictionary_key], dict);

    def test_get_elements_by_attribute(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        for tag_attribute in self.tag_attributes:
            attribute_elements = tag_dictionary.get_elements_by_attribute(hed_root_element, tag_attribute);
            self.assertIsInstance(attribute_elements, list);
            self.assertTrue(attribute_elements);

    def test_populate_default_unit_tag_dictionary(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        attribute_tags, attribute_tag_elements = tag_dictionary.get_tags_by_attribute( \
            hed_root_element, self.default_tag_attribute);
        default_unit_tag_dictionary = tag_dictionary.populate_default_unit_tag_dictionary(attribute_tags, \
                                                                                          attribute_tag_elements, \
                                                                                          self.default_tag_attribute);
        self.assertIsInstance(default_unit_tag_dictionary, dict);

    def test_get_elements_by_tag_name(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        unit_class_elements = tag_dictionary.get_elements_by_tag_name(hed_root_element, self.unit_class_tag);
        self.assertIsInstance(unit_class_elements, list);

    def test_populate_unit_class_units_dictionary(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        unit_class_elements = tag_dictionary.get_elements_by_tag_name(hed_root_element, self.unit_class_tag);
        unit_class_units_dictionary = tag_dictionary.populate_unit_class_units_dictionary(unit_class_elements);
        self.assertIsInstance(unit_class_units_dictionary, dict);

    def test_populate_unit_class_units_dictionary(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        unit_class_elements = tag_dictionary.get_elements_by_tag_name(hed_root_element, self.unit_class_tag);
        unit_class_units_dictionary = tag_dictionary.populate_unit_class_units_dictionary(unit_class_elements);
        self.assertIsInstance(unit_class_units_dictionary, dict);

    def test_get_all_tags(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        tags, tag_elements = tag_dictionary.get_all_tags(hed_root_element);
        self.assertIsInstance(tags, list);
        self.assertIsInstance(tag_elements, list);

    def test_populate_tag_dictionaries(self):
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        for tag_dictionary_key in tag_dictionaries:
            self.assertIsInstance(tag_dictionaries[tag_dictionary_key], dict);

    def test_populate_tag_dictionaries(self):
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        for tag_dictionary_key in tag_dictionaries:
            self.assertIsInstance(tag_dictionaries[tag_dictionary_key], dict);

    def test_get_all_leaf_tags(self):
        hed_root_element = tag_dictionary.get_hed_root_element(self.hed_xml);
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        leaf_tags = tag_dictionary.get_all_leaf_tags(hed_root_element);
        leaf_tags_with_take_value_tags = \
            tag_dictionary.get_all_leaf_tags(hed_root_element, exclude_take_value_tags=False);
        self.assertIsInstance(leaf_tags, dict);
        self.assertIsInstance(leaf_tags_with_take_value_tags, dict);
        self.assertNotEqual(len(leaf_tags), len(leaf_tags_with_take_value_tags));

    def test_tag_has_attribute(self):
        tag_dictionaries = tag_dictionary.populate_tag_dictionaries(self.hed_xml);
        for tag_attribute in self.tag_attributes:
            tag_attribute_keys = tag_dictionaries[tag_attribute].keys();
            tag = tag_attribute_keys[0];
            tag_has_attribute = tag_dictionary.tag_has_attribute(tag_dictionaries, tag, tag_attribute);
            self.assertTrue(tag_has_attribute);

if __name__ == '__main__':
    unittest.main();
