import unittest;
from flask import Flask;


class Test(unittest.TestCase):

    def setUp(self):
        app = Flask(__name__);
        app.config.from_object('config.ProductionConfig');
        from webinterface.views import *;
        from webinterface.utils import *;
        self.app = app.test_client();

    def test_render_main_page(self):
        response = self.app.get('/');
        self.assertEqual(response.status_code, 200);

    def test_delete_file_in_upload_directory(self):
        response = self.app.get('/delete/file_that_does_not_exist');
        self.assertEqual(response.status_code, 404)

if __name__ == '__main__':
    unittest.main();
