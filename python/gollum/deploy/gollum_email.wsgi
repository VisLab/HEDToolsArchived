#!/usr/bin/python
import sys
activate_this = '/var/www/webhooks/env/bin/activate_this.py'
execfile(activate_this, dict(__file__=activate_this))
sys.path.insert(0, "/var/www/webhooks/gollum")
from gollum_email import app as application
