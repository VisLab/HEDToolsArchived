from flask import Blueprint, current_app, request;
from hedemailer import hed_emailer, utils;
import json;

app_config = current_app.config;
route_blueprint = Blueprint('route_blueprint', __name__);


@route_blueprint.route('/', methods=['POST'])
def process_hed_payload():
    try:
        if utils.request_is_github_gollum_event(request):
            hed_emailer.send_email(request);
            return json.dumps({'success': True, 'message': 'Email(s) correctly sent'}), 200, {
                'ContentType': 'application/json'};
    except Exception as ex:
        return json.dumps({'success': False, 'message': ex}), 500, {'ContentType': 'application/json'};
    return json.dumps({'success': True,
                       'message': 'No email(s) sent. Not in the correct format. Content type needs to'
                                  ' be in JSON and X-GitHub-Event must be gollum'}), 200, {
               'ContentType': 'application/json'};
