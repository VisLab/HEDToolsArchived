'''
This module contains the configurations for the HEDTools application.
Created on Dec 21, 2017

@author: Jeremy Cockfield
'''

import os;
import tempfile;


class ProductionConfig(object):
    UPLOAD_FOLDER = os.path.join(tempfile.gettempdir(), 'hedtools_uploads');
    SECRET_KEY = '2k3jsd90sf24*(#&#J@#KJ@#(U@#($(@*)';
    LOG_DIRECTORY = '/var/log/hedtools';
    LOG_FILE = os.path.join(LOG_DIRECTORY, 'error.log');
    TESTING = False;
    DEBUG = False;
    URL_PREFIX = '/hed';
    STATIC_URL_PATH = '/hed/static';

class LocalConfig(object):
    UPLOAD_FOLDER = os.path.join(tempfile.gettempdir(), 'hedtools_uploads');
    SECRET_KEY = os.urandom(24);
    LOG_DIRECTORY = '/var/log/hedtools';
    LOG_FILE = os.path.join(LOG_DIRECTORY, 'error.log');
    TESTING = False;
    DEBUG = False;
    URL_PREFIX = None;
    STATIC_URL_PATH = None;


class TestConfig(object):
    SECRET_KEY = os.urandom(24);
    TESTING = True;
    DEBUG = False;


class DebugConfig(object):
    SECRET_KEY = os.urandom(24);
    TESTING = False;
    DEBUG = True;
