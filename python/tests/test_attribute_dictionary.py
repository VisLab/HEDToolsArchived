import unittest;
import defusedxml;
from defusedxml.lxml import parse;
from validation import attribute_dictionary;

class Test(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.HED_XML = 'data/HED.xml';
        pass;

    @classmethod
    def tearDownClass(self):
        pass;

    def test_get_hed_root_element(self):
        hed_root_element = attribute_dictionary.get_hed_root_element(self.HED_XML);
        self.assertIsInstance(hed_root_element, defusedxml.lxml.RestrictedElement);

    def test_get_all_ancestor_tags(self):
        pass;

if __name__ == '__main__':
    unittest.main();
