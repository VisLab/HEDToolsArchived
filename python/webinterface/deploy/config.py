'''
This module contains the configurations for the HEDTools application.
Created on Dec 21, 2017

@author: Jeremy Cockfield
'''

import os;
import tempfile;

class Config(object):
    UPLOAD_FOLDER = os.path.join(tempfile.gettempdir(), 'hedtools_uploads');
    SECRET_KEY = os.urandom(24);
    URL_PREFIX = None;
    STATIC_URL_PATH = None;
    
    
class DevelopmentConfig(Config):
    LOG_DIRECTORY = '/var/log/hedtools';
    LOG_FILE = os.path.join(LOG_DIRECTORY, 'error.log');
    TESTING = False;
    DEBUG = False;

    
class TestConfig(Config):
    TESTING = True;
    DEBUG = False;


class DebugConfig(Config):
    TESTING = False;
    DEBUG = True;
