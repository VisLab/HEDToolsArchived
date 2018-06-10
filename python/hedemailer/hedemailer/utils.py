from hedconversion import wiki2xml;
from email.mime.multipart import MIMEMultipart;
from email.mime.text import MIMEText;
from flask import current_app;
import os;
import urllib.request;

app_config = current_app.config;


# Create standard email message
def create_standard_email(github_payload_dictionary, email_list):
    msg = MIMEMultipart();
    msg['Subject'] = '[' + github_payload_dictionary['repository']['full_name'] + '] ' + 'Wiki notifications';
    msg['From'] = app_config['SENDER'];
    msg['To'] = app_config['TO'];
    msg['Bcc'] = ', '.join(email_list);
    main_body_text = 'Hello,\nThe wiki page ' + github_payload_dictionary['pages'][0]['title'] + ' has been ' + \
                     github_payload_dictionary['pages'][0]['action'] + '. Please checkout the changes at ' + \
                     github_payload_dictionary['pages'][0]['html_url'] + '.'
    return msg, main_body_text;


# Create HED schema email
def create_hed_schema_email(msg, main_body_text):
    hed_info_dictionary = wiki2xml.convert_hed_wiki_2_xml();
    main_body_text = add_hed_xml_attachment_text(main_body_text, hed_info_dictionary);
    main_body = MIMEText(main_body_text);
    msg.attach(main_body);
    hed_xml_attachment, hed_xml_file = create_hed_xml_attachment(hed_info_dictionary['hed_xml_file_location'])
    msg.attach(hed_xml_attachment);
    return hed_info_dictionary;


# Returns true if the wiki page is the HED schema
def wiki_page_is_hed_schema(github_payload_dictionary):
    return app_config['HED_WIKI_PAGE'] == github_payload_dictionary['pages'][0]['title'];


# True if the request is a github gollum event
def request_is_github_gollum_event(request):
    return request.headers.get('content-type') == 'application/json' and request.headers.get(
        'X-GitHub-Event') == 'gollum';


# Add message body text for HED XML attachment
def add_hed_xml_attachment_text(main_body_text, hed_info_dictionary):
    main_body_text += ' Also, the latest HED schema is attached.';
    main_body_text += '\n\nVersion\n' + hed_info_dictionary['hed_xml_tree'].get('version');
    main_body_text += '\n\nChange log\n' + hed_info_dictionary['hed_change_log'][0];
    return main_body_text;


# Create HED XML attachment file
def create_hed_xml_attachment(hed_xml_file_location):
    with open(hed_xml_file_location, 'r') as hed_xml_file:
        hed_xml_string = hed_xml_file.read();
        hed_xml_attachment = MIMEText(hed_xml_string, 'plain', 'utf-8');
        hed_xml_attachment.add_header('Content-Disposition', 'attachment', filename="HED.xml");
    return hed_xml_attachment, hed_xml_file;


# Get email list from a repository name
def get_email_list_from_file(email_file_path):
    with open(email_file_path, 'r') as opened_email_file:
        email_list = [x.strip() for x in opened_email_file.readlines()];
    return email_list;


# Write data from a URL into a file
def url_to_file(file_url, file_location):
    url_request = urllib.request.urlopen(file_url);
    url_data = str(url_request.read(), 'utf-8');
    with open(file_location, 'w') as opened_file:
        opened_file.write(url_data);


# Deletes the file if it exist
def delete_file_if_exist(file_location):
    if os.path.isfile(file_location):
        os.remove(file_location);
