import os;
from webinterface.app_factory import AppFactory;
from flask_wtf.csrf import CSRFProtect;
from logging.handlers import RotatingFileHandler;
from logging import ERROR;


def setup_logging():
    """Sets up the current_application logging. If the log directory does not exist then there will be no logging.

    """
    if not app.debug and os.path.exists(app.config['LOG_DIRECTORY']):
        file_handler = RotatingFileHandler(app.config['LOG_FILE'], maxBytes=10 * 1024 * 1024, backupCount=5);
        file_handler.setLevel(ERROR);
        app.logger.addHandler(file_handler);


app = AppFactory.create_app('config.ProductionConfig');
with app.app_context():
    from webinterface import utils;
    from webinterface.views import view_routes;
    CSRFProtect(app);
    app.register_blueprint(view_routes);
    utils.create_upload_directory(app.config['UPLOAD_FOLDER']);
    setup_logging();

if __name__ == '__main__':
    app.run();
