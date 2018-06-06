from flask import Blueprint, current_app, request;
from hedemailer import hed_emailer;
import json;

app_config = current_app.config;
route_blueprint = Blueprint('route_blueprint', __name__);


@route_blueprint.route('/', methods=['POST'])
def process_gollum_event():
    try:
        if hed_emailer.request_is_github_gollum_event(request):
            hed_emailer.send_gollum_email(request);
    except Exception as ex:
        return json.dumps({'success': False, 'message': ex.message}), 500, {'ContentType': 'application/json'};
    return json.dumps({'success': True}), 200, {'ContentType': 'application/json'};
