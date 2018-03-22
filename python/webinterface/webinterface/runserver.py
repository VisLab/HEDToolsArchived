from webinterface.app_factory import AppFactory;
from flask_wtf.csrf import CSRFProtect;

app = AppFactory.create_app('config.ProductionConfig');
CSRFProtect(app);
from webinterface.views import *;
utils.setup_logging();
utils.setup_upload_directory();

if __name__ == '__main__':
    app.run();
