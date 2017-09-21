import unittest;
import defusedxml;
from defusedxml.lxml import parse;
import lxml;

class Test(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.HED_XML = 'data/HED.xml';
        pass;

    @classmethod
    def tearDownClass(self):
        pass;

    def test_get_root_element(self):
        hed_tree = parse(self.HED_XML);
        hed_root_element = hed_tree.getroot();
        self.assertIsInstance(hed_tree, lxml.etree._ElementTree);
        self.assertIsInstance(hed_root_element, defusedxml.lxml.RestrictedElement);

if __name__ == '__main__':
    unittest.main();
