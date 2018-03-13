from flask import Flask;
from flask_wtf.csrf import CSRFProtect;
app = Flask(__name__);
app.config.from_object('config.ProductionConfig');
CSRFProtect(app);
from webinterface.views import *;
from webinterface import utils;
utils.setup_logging();
utils.setup_upload_directory();

if __name__ == '__main__':
    app.run();
