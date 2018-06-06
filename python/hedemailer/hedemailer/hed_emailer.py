'''
This module receives a post request from a github repository and emails a notification to a group of recipients associated with the repository. 
Created on Mar 8, 2017

@author: Jeremy Cockfield
'''
import smtplib;
import json;
from email.mime.text import MIMEText;
from flask import current_app;
from hedemailer import utils;

app_config = current_app.config;


# Send gollum event related email
def send_email(request):
    github_payload_string = request.data.decode('utf-8');
    github_payload_dictionary = json.loads(github_payload_string);
    email_list = utils.get_email_list_from_file(app_config['EMAIL_LIST']);
    msg, email_info_dictionary = create_email(github_payload_dictionary, app_config['EMAIL_LIST']);
    send_email_from_smtp_server(msg, email_list);
    return email_info_dictionary;


# Create gollum event related email
def create_email(github_payload_dictionary, email_list):
    email_info_dictionary = {};
    msg, main_body_text = utils.create_standard_email(github_payload_dictionary, email_list);
    if utils.wiki_page_is_hed_schema(github_payload_dictionary):
        email_info_dictionary = utils.create_hed_schema_email(msg, main_body_text);
    else:
        main_body = MIMEText(main_body_text);
        msg.attach(main_body);
    return msg, email_info_dictionary;


# Send the message via our own SMTP server
def send_email_from_smtp_server(msg, email_list):
    smtp_server = smtplib.SMTP('localhost');
    smtp_server.sendmail(app_config['SENDER'], email_list, msg.as_string());
    smtp_server.quit();
