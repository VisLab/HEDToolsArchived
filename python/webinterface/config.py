'''
This module contains the configurations for the HEDTools application.
Created on Dec 21, 2017

@author: Jeremy Cockfield
'''

import os;
import tempfile;


class Config(object):
    LOG_DIRECTORY = '/var/log/hedtools';
    LOG_FILE = os.path.join(LOG_DIRECTORY, 'error.log');
    SECRET_KEY = os.urandom(24);
    STATIC_URL_PATH = None;
    STATIC_URL_PATH_ATTRIBUTE_NAME = 'STATIC_URL_PATH';
    UPLOAD_FOLDER = os.path.join(tempfile.gettempdir(), 'hedtools_uploads');
    URL_PREFIX = None;


class DevelopmentConfig(Config):
    DEBUG = False;
    TESTING = False;


class TestConfig(Config):
    DEBUG = False;
    TESTING = True;


class DebugConfig(Config):
    DEBUG = True;
    TESTING = False;
