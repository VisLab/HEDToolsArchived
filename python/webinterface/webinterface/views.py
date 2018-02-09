from forms import ValidationForm;
from flask import render_template, Response, abort, request;
from hedvalidation.hed_dictionary import HedDictionary;
from hedvalidation.hed_input_reader import HedInputReader;
import json;
import os;
from webinterface import utils;
from webinterface import app;


@app.route('/validation', strict_slashes=False, methods=['GET', 'POST'])
def validate_spreadsheet_from_form():
    """Handles the site root and Validation tab functionality.

    Parameters
    ----------

    Returns
    -------
    Rendered template
        A rendered template for the validation form. If the HTTP method is a GET then the validation form will be
        displayed. If the HTTP method is a POST then the validation form is submitted.

    """
    form = ValidationForm();
    if request.method == 'POST':
        return utils.validate_spreadsheet_after_submission(request);
    return render_template('validation.html', form=form);


@app.route('/', strict_slashes=False, methods=['GET'])
def render_main_page():
    """Handles the site root.

    Parameters
    ----------

    Returns
    -------
    Rendered template
        A rendered template for the main page.

    """
    return render_template('hed.html')


@app.route('/help', strict_slashes=False, methods=['GET'])
def render_doc_page():
    """Handles the site root.

    Parameters
    ----------

    Returns
    -------
    Rendered template
        A rendered template for the main page.

    """
    return render_template('help.html')


@app.route('/download/<filename>')
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
    try:
        def generate():
            with open(os.path.join(app.config['UPLOAD_FOLDER'], filename)) as download_file:
                for line in download_file:
                    yield line;
            utils.delete_file_if_it_exist(os.path.join(app.config['UPLOAD_FOLDER'], filename));

        return Response(generate(), mimetype='text/plain', headers={'Content-Disposition': "attachment; filename=%s" % \
                                                                                           filename});
    except:
        abort(404);


@app.route('/delete/<filename>')
def delete_file_in_upload_directory(filename):
    """Deletes the specified file from the upload file.

    Parameters
    ----------
    filename: string
        The name of the file to delete from the upload file.

    Returns
    -------

    """
    if utils.delete_file_if_it_exist(os.path.join(app.config['UPLOAD_FOLDER'], filename)):
        return Response(status=204);
    else:
        abort(404);


@app.route('/getmajorhedversions', methods=['GET'])
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
    hed_info = {};
    try:
        hed_info['major_versions'] = HedInputReader.get_all_hed_versions();
        return json.dumps(hed_info);
    except:
        return abort(500);


@app.route('/gethedversion', methods=['POST'])
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
    hed_info = {};
    try:
        if utils.hed_file_present_in_form(request):
            hed_file = request.files['hed_file'];
            hed_file_path = utils.save_hed_to_upload_folder(hed_file);
            hed_info['version'] = HedDictionary.get_hed_xml_version(hed_file_path);
        return json.dumps(hed_info);
    except:
        return abort(500);


@app.route('/getworksheetsinfo', methods=['POST'])
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
    workbook_file_path = '';
    try:
        worksheets_info = utils.initialize_worksheets_info_dictionary();
        if utils.spreadsheet_file_present_in_form(request):
            workbook_file = request.files['spreadsheet_file'];
            workbook_file_path = utils.save_spreadsheet_to_upload_folder(workbook_file);
            if workbook_file_path:
                worksheets_info = utils.populate_worksheets_info_dictionary(worksheets_info, workbook_file_path);
    except:
        return abort(500);
    finally:
        utils.delete_file_if_it_exist(workbook_file_path);
    return json.dumps(worksheets_info);


@app.route('/getspreadsheetcolumnsinfo', methods=['POST'])
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
    spreadsheet_file_path = '';
    try:
        spreadsheet_columns_info = utils.initialize_spreadsheet_columns_info_dictionary();
        if utils.spreadsheet_file_present_in_form(request):
            spreadsheet_file = request.files['spreadsheet_file'];
            spreadsheet_file_path = utils.save_spreadsheet_to_upload_folder(spreadsheet_file);
            if spreadsheet_file_path and utils.worksheet_name_present_in_form(request):
                worksheet_name = request.form['worksheet_name'];
                spreadsheet_columns_info = utils.populate_spreadsheet_columns_info_dictionary(spreadsheet_columns_info, \
                                                                                              spreadsheet_file_path, \
                                                                                              worksheet_name);
            else:
                spreadsheet_columns_info = utils.populate_spreadsheet_columns_info_dictionary(spreadsheet_columns_info, \
                                                                                              spreadsheet_file_path);
        return json.dumps(spreadsheet_columns_info);
    except:
        return abort(500);
    finally:
        utils.delete_file_if_it_exist(spreadsheet_file_path);
