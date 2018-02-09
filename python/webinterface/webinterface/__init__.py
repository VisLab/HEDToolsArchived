from flask import Flask;

app = Flask(__name__);
app.config.from_object('config.Config');
from webinterface.views import *;

if __name__ == '__main__':
    app.run();
