import unittest;
import os;
from webinterface.app_factory import AppFactory;


class Test(unittest.TestCase):
    def setUp(self):
        upload_directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data/HED.xml');
        app = AppFactory.create_app('config.TestConfig');
        with app.app_context():
            from webinterface import utils;
            from webinterface.routes import route_blueprint;
            app.register_blueprint(route_blueprint);
            utils.create_upload_directory(upload_directory);
            app.config['UPLOAD_FOLDER'] = upload_directory;
            self.app = app.test_client();

    def test_render_home_page(self):
        response = self.app.get('/');
        self.assertEqual(response.status_code, 200);

    def test_delete_file_in_upload_directory(self):
        response = self.app.get('/delete/file_that_does_not_exist');
        self.assertEqual(response.status_code, 404);

    def test_get_hed_version_in_file(self):
        response = self.app.post('/gethedversion');
        self.assertEqual(response.status_code, 400);

    def test_get_major_hed_versions(self):
        response = self.app.post('/getmajorhedversions');
        self.assertEqual(response.status_code, 405);

    def test_get_spreadsheet_columns_info(self):
        response = self.app.post('/getspreadsheetcolumnsinfo');
        self.assertEqual(response.status_code, 400);


if __name__ == '__main__':
    unittest.main();
