from flask import Flask;


class AppFactory:
    @staticmethod
    def create_app(config_file):
        app = Flask(__name__);
        app.config.from_object(config_file);
        return app;

