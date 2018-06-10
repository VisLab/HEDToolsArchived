import unittest;
import json;
from hedemailer.app_factory import AppFactory;


class Test(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        hed_payload_file = 'data/hed_payload.json';
        Test.create_test_app();
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


if __name__ == "__main__":
    unittest.main()
