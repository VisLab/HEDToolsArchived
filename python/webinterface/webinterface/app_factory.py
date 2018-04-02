from flask import Flask;
from flask_wtf.csrf import CSRFProtect;


class AppFactory:
    @staticmethod
    def create_app(config_file, static_url_path='/static'):
        app = Flask(__name__, static_url_path=static_url_path);
        app.config.from_object(config_file);
        CSRFProtect(app);
        return app;

