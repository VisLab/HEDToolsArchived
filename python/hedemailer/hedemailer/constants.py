import json;

EMAILS_SENT = 'Email(s) correctly sent';
EMAIL_SENT_RESPONSE = json.dumps({'success': True, 'message': EMAILS_SENT}), 200, {'ContentType': 'application/json'};
NO_EMAILS_SENT = 'No email(s) sent. Not in the correct format. Content type needs to be in JSON and X-GitHub-Event'
' must be gollum';
NO_EMAILS_SENT_RESPONSE = json.dumps({'success': True, 'message': constants.NO_EMAILS_SENT}), 200, {
    'ContentType': 'application/json'};


def generate_exception_response(ex):
    return json.dumps({'success': False, 'message': ex}), 500, {'ContentType': 'application/json'};
