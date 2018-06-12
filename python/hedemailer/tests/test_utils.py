import unittest;
import json;
from hedemailer.app_factory import AppFactory;
import hedemailer;


class Test(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        Test.create_test_app();
        hed_payload_file = 'data/hed_payload.json';
        Test.get_payload_from_file(hed_payload_file);

    @classmethod
    def get_payload_from_file(cls, hed_payload_file):
        with open(hed_payload_file) as opened_hed_payload_file:
            cls.hed_payload_string = json.dumps(json.load(opened_hed_payload_file));

    @classmethod
    def create_test_app(cls):
        app = AppFactory.create_app('config.TestConfig');
        with app.app_context():
            from hedemailer.routes import route_blueprint;
            app.register_blueprint(route_blueprint);
            cls.app = app.test_client();

    def create_file_in_data_dir(self, file_path):
        with open(file_name, 'w') as file_name)


    def test_wiki_page_is_hed_schema_no_hed_payload(self):
        github_payload_dictionary = {};
        is_hed_schema = hedemailer.utils.wiki_page_is_hed_schema(github_payload_dictionary)
        self.assertFalse(is_hed_schema, 'Wiki page should not be HED schema');

    def test_wiki_page_is_hed_schema_good_hed_payload(self):
        github_payload_dictionary = {};
        is_hed_schema = hedemailer.utils.wiki_page_is_hed_schema(github_payload_dictionary)
        self.assertFalse(is_hed_schema, 'Wiki page should be HED schema');

    def test_delete_file_if_exist(file_path)
        delete_file_if_exist(file_path)


if __name__ == "__main__":
    unittest.main()
