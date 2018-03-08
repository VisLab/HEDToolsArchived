import unittest;
from webinterface.utils import *;
from StringIO import StringIO;
from flask import Request;


class Test(unittest.TestCase):

    def setUp(self):
        self.error_key = 'error';
        self.major_version_key = 'major_versions';

    def test_find_major_hed_versions(self):
        hed_info = find_major_hed_versions();
        self.assertTrue(self.major_version_key in hed_info);


if __name__ == '__main__':
    unittest.main();
