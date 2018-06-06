import unittest;
from hedemailer.app_factory import AppFactory;


class Test(unittest.TestCase):
    def setUp(self):
        app = AppFactory.create_app('config.TestConfig');
        with app.app_context():
            from hedemailer.routes import route_blueprint;
            app.register_blueprint(route_blueprint);
            self.app = app.test_client();

    def test_empty_payload(self):
        response = self.app.post('/');
        self.assertEqual(response.status_code, 200);


if __name__ == '__main__':
    unittest.main();
