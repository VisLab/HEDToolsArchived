from webinterface.app_factory import AppFactory;
from flask_wtf.csrf import CSRFProtect;

app = AppFactory.create_app();
CSRFProtect(app);
from webinterface.views import *;

if __name__ == '__main__':
    utils.setup_logging();
    utils.setup_upload_directory();
    app.run();
