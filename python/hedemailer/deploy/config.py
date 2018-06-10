'''
This module contains the configurations for the gollum_email webhook application.
Created on Mar 14, 2017

@author: Jeremy Cockfield
'''

import socket


class Config(object):
    EMAIL_LIST = '/path/to/email/list';
    FROM = 'github-notifications@' + socket.getfqdn();
    HED_WIKI_PAGE = 'HED Schema';
    TO = 'github-mailing-list@' + socket.getfqdn();


class DevelopmentConfig(Config):
    TESTING = False;
    DEBUG = False;


class TestConfig(Config):
    TESTING = True;
    DEBUG = False;


class DebugConfig(Config):
    TESTING = False;
    DEBUG = True;
