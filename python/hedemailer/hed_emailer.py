'''
This module receives a post request from a github repository and emails a notification to a group of recipients associated with the repository. 
Created on Mar 8, 2017

@author: Jeremy Cockfield
'''
import smtplib;
import os;
import json;
from hedconversion.wiki2xml import convert_hed_wiki_2_xml, delete_file_if_exist;
from email.MIMEMultipart import MIMEMultipart;
from email.MIMEText import MIMEText;
from flask import request;
from flask.app import Flask;
import codecs;

app = Flask(__name__);
app.config.from_object('config.Config');
 
EMAIL_LIST_DIRECTORY = app.config['EMAIL_LIST_DIRECTORY'];
REPOSITORY_NAME_TO_EMAIL_LIST = app.config['REPOSITORY_NAME_TO_EMAIL_LIST'];
SENDER = app.config['SENDER'];
TO = app.config['TO'];
HED_WIKI_PAGE = app.config['HED_WIKI_PAGE'];
 
@app.route('/', methods = ['POST'])
def process_gollum_event():
    try:
        if request_is_github_gollum_event(request):      
            send_gollum_email(request);
    except Exception as ex:
        return json.dumps({'success':False, 'message':ex.message}), 500, {'ContentType':'application/json'}; 
    return json.dumps({'success':True}), 200, {'ContentType':'application/json'};   

# Send gollum event related email
def send_gollum_email(request):
    github_payload_string = request.data;
    github_payload_dictionary = json.loads(github_payload_string);
    repository_email_list = get_repository_email_list(github_payload_dictionary['repository']['name']);
    msg, email_info_dictionary = create_email(github_payload_dictionary, repository_email_list);
    send_email_from_smtp_server(msg, repository_email_list);  
    return email_info_dictionary;

# Create gollum event related email 
def create_email(github_payload_dictionary, repository_email_list):
    email_info_dictionary = {};
    msg, main_body_text = create_standard_email(github_payload_dictionary, repository_email_list);
    if wiki_page_is_hed_schema(github_payload_dictionary):
        email_info_dictionary = create_hed_schema_email(msg, main_body_text);
    else:   
        main_body = MIMEText(main_body_text);     
        msg.attach(main_body);
    return msg, email_info_dictionary;

# Send the message via our own SMTP server
def send_email_from_smtp_server(msg, repository_email_list):
    smtp_server = smtplib.SMTP('localhost');
    smtp_server.sendmail(SENDER, repository_email_list, msg.as_string());
    smtp_server.quit();

# Create standard email message
def create_standard_email(github_payload_dictionary, repository_email_list):
    msg = MIMEMultipart();
    msg['Subject'] = '[' + github_payload_dictionary['repository']['full_name'] + '] ' + 'Wiki notifications';
    msg['From'] = SENDER;
    msg['To'] = TO;
    msg['Bcc'] = ', '.join(repository_email_list);   
    main_body_text = 'Hello,\nThe wiki page ' +  github_payload_dictionary['pages'][0]['title'] + ' has been ' + github_payload_dictionary['pages'][0]['action'] + '. Please checkout the changes at ' + github_payload_dictionary['pages'][0]['html_url'] + '.'
    return msg, main_body_text;

# Create HED schema email 
def create_hed_schema_email(msg, main_body_text):
    hed_info_dictionary = {'hed_wiki_file_location':'', 'hed_xml_file_location':''};
    hed_xml_file = None;
    try:
        hed_info_dictionary = convert_hed_wiki_2_xml();
        main_body_text = add_hed_xml_attachment_text(main_body_text, hed_info_dictionary);
        main_body = MIMEText(main_body_text);
        msg.attach(main_body);
        hed_xml_attachment, hed_xml_file = create_hed_xml_attachment(hed_info_dictionary['hed_xml_file_location'])
        msg.attach(hed_xml_attachment); 
    finally:
        cleanup_resources(hed_xml_file, hed_info_dictionary);
    return hed_info_dictionary;

# Clean up resources, close HED XML file and delete HED XML and HED wiki files. 
def cleanup_resources(hed_xml_file, hed_info_dictionary):
    if hed_xml_file:
        hed_xml_file.close();
    delete_file_if_exist(hed_info_dictionary['hed_wiki_file_location']);
    delete_file_if_exist(hed_info_dictionary['hed_xml_file_location']);
    
# Returns true if the wiki page is the HED schema 
def wiki_page_is_hed_schema(github_payload_dictionary):
    return HED_WIKI_PAGE == github_payload_dictionary['pages'][0]['title'];

# True if the request is a github gollum event 
def request_is_github_gollum_event(request):
    return request.headers.get('content-type') == 'application/json' and request.headers.get('X-GitHub-Event') == 'gollum'

# Add message body text for HED XML attachment 
def add_hed_xml_attachment_text(main_body_text, hed_info_dictionary):
    main_body_text += ' Also, the latest HED schema is attached.';
    main_body_text += '\n\nVersion\n' + hed_info_dictionary['hed_xml_tree'].get('version');
    main_body_text += '\n\nChange log\n' + hed_info_dictionary['hed_change_log'][0];
    return main_body_text;

# Create HED XML attachment file 
def create_hed_xml_attachment(hed_xml_file_location):
    hed_xml_file = codecs.open(hed_xml_file_location, 'r', 'utf-8');
    hed_xml_string = hed_xml_file.read();
    hed_xml_attachment = MIMEText(hed_xml_string, 'plain', 'utf-8');
    hed_xml_attachment.add_header('Content-Disposition', 'attachment', filename="HED.xml");  
    return hed_xml_attachment, hed_xml_file;

# Get email list from a repository name     
def get_repository_email_list(organizational_repository, email__list_directory = EMAIL_LIST_DIRECTORY, repository_name_to_email_list = REPOSITORY_NAME_TO_EMAIL_LIST):
    email_file_path = '';
    email_list = [];
    email_file = None;
    try:
        repository_names = repository_name_to_email_list.keys();
        for repository_name in repository_names:
            if organizational_repository.endswith(repository_name):
                email_file_path = os.path.join(email__list_directory, repository_name_to_email_list.get(repository_name));
        if email_file_path:
            email_file = open(email_file_path, 'r');
            email_list = [x.strip() for x in email_file.readlines()];
    finally:
        if email_file:
            email_file.close();
    return email_list;
        
if __name__ == '__main__':
    app.run()