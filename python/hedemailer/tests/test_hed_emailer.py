import unittest;
import json;


class Test(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.hed_payload_file = 'data/hed_payload.json';
        with open(cls.hed_payload_file) as opened_hed_payload_file:
            cls.hed_payload_string = json.load(opened_hed_payload_file);
        cls.hed_emailer =

    @classmethod
    def tearDownClass(self):
        self.github_payload_file.close();

    def test_send_gollum_email(self):

    pass


if __name__ == "__main__":
    unittest.main()
