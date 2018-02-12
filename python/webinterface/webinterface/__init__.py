from flask import Flask;
app = Flask(__name__);
app.config.from_object('config.Config');
from webinterface.views import *;
from webinterface.utils import *;
setup_logging();
setup_upload_directory();

if __name__ == '__main__':
    app.run();
