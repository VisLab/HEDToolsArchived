from hedconversion import wiki2xml;
from email.mime.multipart import MIMEMultipart;
from email.mime.text import MIMEText;
from flask import current_app;
import os;
import urllib.request;
from hedemailer import constants;

app_config = current_app.config;


# Create standard email message
def create_standard_email(github_payload_dictionary, email_list):
    msg = MIMEMultipart();
    msg[constants.EMAIL_SUBJECT_KEY] = '[' + github_payload_dictionary[constants.WIKI_REPOSITORY_KEY][
        constants.WIKI_REPOSITORY_FULL_NAME_KEY] + '] ' + constants.WIKI_NOTIFICATIONS_TEXT;
    msg[constants.EMAIL_FROM_KEY] = app_config[constants.EMAIL_FROM_KEY];
    msg[constants.EMAIL_TO_KEY] = app_config[constants.EMAIL_TO_KEY];
    msg[constants.EMAIL_BCC_KEY] = constants.EMAIL_LIST_DELIMITER.join(email_list);
    main_body_text = constants.HELLO_WIKI_TEXT + \
                     github_payload_dictionary[constants.WIKI_PAGES_KEY][0][constants.WIKI_TITLE_KEY] + \
                     constants.HAS_BEEN_TEXT + \
                     github_payload_dictionary[constants.WIKI_PAGES_KEY][0][constants.WIKI_ACTION_KEY] + \
                     constants.CHECK_OUT_CHANGES_TEXT + \
                     github_payload_dictionary[constants.WIKI_PAGES_KEY][0][constants.WIKI_HTML_URL_KEY] + \
                     constants.PERIOD_TEXT;
    return msg, main_body_text;


# Create HED schema email
def create_hed_schema_email(msg, main_body_text):
    try:
        hed_info_dictionary = wiki2xml.convert_hed_wiki_2_xml();
        main_body_text = add_hed_xml_attachment_text(main_body_text, hed_info_dictionary);
        main_body = MIMEText(main_body_text);
        msg.attach(main_body);
        hed_xml_attachment, hed_xml_file = create_hed_xml_attachment(
            hed_info_dictionary[constants.HED_XML_LOCATION_KEY]);
        msg.attach(hed_xml_attachment);
    finally:
        clean_up_hed_resources(hed_info_dictionary);
    return hed_info_dictionary;


def clean_up_hed_resources(hed_info_dictionary):
    delete_file_if_exist(hed_info_dictionary[constants.HED_XML_LOCATION_KEY]);
    delete_file_if_exist(hed_info_dictionary[constants.HED_WIKI_LOCATION_KEY]);


# Returns true if the wiki page is the HED schema
def wiki_page_is_hed_schema(github_payload_dictionary):
    return app_config[constants.HED_WIKI_PAGE] == \
           github_payload_dictionary[constants.WIKI_PAGES_KEY][0][constants.WIKI_TITLE_KEY];


# True if the request is a github gollum event
def request_is_github_gollum_event(request):
    return request.headers.get(constants.HEADER_CONTENT_TYPE) == constants.JSON_CONTENT_TYPE and \
           request.headers.get(constants.HEADER_EVENT_TYPE) == constants.GOLLUM;


# Add message body text for HED XML attachment
def add_hed_xml_attachment_text(main_body_text, hed_info_dictionary):
    main_body_text += constants.HED_ATTACHMENT_TEXT;
    main_body_text += constants.HED_VERSION_TEXT + hed_info_dictionary[constants.HED_XML_TREE_KEY].get(
        constants.HED_XML_VERSION_KEY);
    main_body_text += constants.CHANGE_LOG_TEXT + hed_info_dictionary[constants.HED_CHANGE_LOG_KEY][0];
    return main_body_text;


# Create HED XML attachment file
def create_hed_xml_attachment(hed_xml_file_location):
    with open(hed_xml_file_location, 'r') as hed_xml_file:
        hed_xml_string = hed_xml_file.read();
        hed_xml_attachment = MIMEText(hed_xml_string, 'plain', 'utf-8');
        hed_xml_attachment.add_header('Content-Disposition', 'attachment', filename=constants.HED_XML_ATTACHMENT_NAME);
    return hed_xml_attachment, hed_xml_file;


# Get email list from a repository name
def get_email_list_from_file(email_file_path):
    email_list = [];
    with open(email_file_path, 'r') as email_file:
        for email_address in email_file:
            email_list.append(email_address.strip());
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
