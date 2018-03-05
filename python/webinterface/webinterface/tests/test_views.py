import unittest;
from flask import Flask;


class Test(unittest.TestCase):

    def setUp(self):
        app = Flask(__name__);
        app.config.from_object('config.TestConfig');
        from webinterface.views import *;
        from webinterface.utils import *;
        self.app = app.test_client();

    def test_render_main_page(self):
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



if __name__ == '__main__':
    unittest.main();
