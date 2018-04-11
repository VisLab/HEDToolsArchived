from flask import render_template, Response, request, Blueprint, current_app;
import os;
import json;
from webinterface import utils
from config import ProductionConfig;

INTERNAL_SERVER_ERROR = 500;
NOT_FOUND_ERROR = 404;
NO_CONTENT_SUCCESS = 204;

app_config = current_app.config;
route_blueprint = Blueprint('route_blueprint', __name__);


@route_blueprint.route('/', strict_slashes=False, methods=['GET'])
def render_home_page():
    """Handles the home page.

    Parameters
    ----------

    Returns
    -------
    Rendered template
        A rendered template for the home page.

    """
    return render_template('home.html');


@route_blueprint.route('/delete/<filename>', strict_slashes=False, methods=['GET'])
def delete_file_in_upload_directory(filename):
    """Deletes the specified file from the upload file.

    Parameters
    ----------
    filename: string
        The name of the file to delete from the upload file.

    Returns
    -------

    """
    if utils.delete_file_if_it_exist(os.path.join(app_config['UPLOAD_FOLDER'], filename)):
        return Response(status=NO_CONTENT_SUCCESS);
    else:
        return utils.handle_http_error(NOT_FOUND_ERROR, "File doesn't exist");


@route_blueprint.route('/download/<filename>', strict_slashes=False, methods=['GET'])
def download_file_in_upload_directory(filename):
    """Downloads the specified file from the upload file.

    Parameters
    ----------
    filename: string
        The name of the file to download from the upload file.

    Returns
    -------
    File
        The contents of a file in the upload directory to send to the client.

    """
    download_response = utils.generate_download_file_response(filename);
    if isinstance(download_response, str):
        utils.handle_http_error(NOT_FOUND_ERROR, download_response);
    return download_response;


@route_blueprint.route('/gethedversion', methods=['POST'])
def get_hed_version_in_file():
    """Gets information related to the spreadsheet columns.

    This information contains the names of the spreadsheet columns and column indices that contain HED tags.

    Parameters
    ----------

    Returns
    -------
    string
        A serialized JSON string containing information related to the spreadsheet columns.

    """
    hed_info = utils.find_hed_version_in_file(request);
    if 'error' in hed_info:
        return utils.handle_http_error(INTERNAL_SERVER_ERROR, hed_info['error']);
    return json.dumps(hed_info);


@route_blueprint.route('/getmajorhedversions', methods=['GET'])
def get_major_hed_versions():
    """Gets information related to the spreadsheet columns.

    This information contains the names of the spreadsheet columns and column indices that contain HED tags.

    Parameters
    ----------

    Returns
    -------
    string
        A serialized JSON string containing information related to the spreadsheet columns.

    """
    hed_info = utils.find_major_hed_versions();
    if 'error' in hed_info:
        return utils.handle_http_error(INTERNAL_SERVER_ERROR, hed_info['error']);
    return json.dumps(hed_info);


@route_blueprint.route('/getspreadsheetcolumnsinfo', methods=['POST'])
def get_spreadsheet_columns_info():
    """Gets information related to the spreadsheet columns.

    This information contains the names of the spreadsheet columns and column indices that contain HED tags.

    Parameters
    ----------

    Returns
    -------
    string
        A serialized JSON string containing information related to the spreadsheet columns.

    """
    spreadsheet_columns_info = utils.find_spreadsheet_columns_info(request);
    if 'error' in spreadsheet_columns_info:
        return utils.handle_http_error(INTERNAL_SERVER_ERROR, spreadsheet_columns_info['error']);
    return json.dumps(spreadsheet_columns_info);


@route_blueprint.route('/getworksheetsinfo', methods=['POST'])
def get_worksheets_info():
    """Gets information related to the Excel worksheets.

    This information contains the names of the worksheets in a workbook, the names of the columns in the first
    worksheet, and column indices that contain HED tags in the first worksheet.

    Parameters
    ----------

    Returns
    -------
    string
        A serialized JSON string containing information related to the Excel worksheets.

    """
    worksheets_info = utils.find_worksheets_info(request);
    if 'error' in worksheets_info:
        return utils.handle_http_error(INTERNAL_SERVER_ERROR, worksheets_info['error']);
    return json.dumps(worksheets_info);


@route_blueprint.route('/help', strict_slashes=False, methods=['GET'])
def render_help_page():
    """Handles the site root.

    Parameters
    ----------

    Returns
    -------
    Rendered template
        A rendered template for the main page.

    """
    return render_template('help.html')


@route_blueprint.route('/submit', strict_slashes=False, methods=['POST'])
def get_validation_results():
    """Validate the spreadsheet in the form after submission and return an attachment file containing the output.

    Parameters
    ----------

    Returns
    -------
        string
        A serialized JSON string containing information related to the worksheet columns. If the validation fails then a
        500 error message is returned.
    """
    validation_status = utils.report_spreadsheet_validation_status(request);
    if 'error' in validation_status:
        return utils.handle_http_error(INTERNAL_SERVER_ERROR, validation_status['error']);
    return json.dumps(validation_status);


@route_blueprint.route('/validation', strict_slashes=False, methods=['GET'])
def render_validation_form():
    """Handles the site root and Validation tab functionality.

    Parameters
    ----------

    Returns
    -------
    Rendered template
        A rendered template for the validation form. If the HTTP method is a GET then the validation form will be
        displayed. If the HTTP method is a POST then the validation form is submitted.

    """
    return render_template('validation.html');
