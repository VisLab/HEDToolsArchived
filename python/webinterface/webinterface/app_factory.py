from flask import Flask;
from flask_wtf.csrf import CSRFProtect;


class AppFactory:
    @staticmethod
    def create_app(config_file):
        app = Flask(__name__);
        app.config.from_object(config_file);
        CSRFProtect(app);
        return app;

