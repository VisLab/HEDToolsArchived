'''
This module contains the configurations for the gollum_email webhook application.
Created on Mar 14, 2017

@author: Jeremy Cockfield
'''

import socket

class Config(object):
    EMAIL_LIST_DIRECTORY = '/path/to/email-lists'
    REPOSITORY_NAME_TO_EMAIL_LIST = {'HED-schema':'hed.txt', 'HEDTools':'hedtools.txt'}
    SENDER = 'github-notifications@' + socket.getfqdn()
    HED_WIKI_PAGE = 'HED Schema'
    TO = 'github-mailing-list@' + socket.getfqdn()
