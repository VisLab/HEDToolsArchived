import json;
import os;
import tempfile;
import xlrd;
from flask import abort, Flask, render_template, request, Response;
from werkzeug.utils import secure_filename;
from forms import ValidationForm;
from hed_input_reader import HedInputReader;

app = Flask(__name__);
app.config.from_object('config.Config');
SPREADSHEET_FILE_EXTENSIONS = ['xls', 'xlsx', 'txt', 'tsv', 'csv'];
TAG_COLUMN_NAMES = ['Event Details', 'HED tags', 'Tag', 'Tags'];
REQUIRED_TAG_COLUMN_NAMES = ['Category', 'Description', 'Label'];
REQUIRED_TAG_COLUMN_NAMES_DICTIONARY = {'Category': ['Category', 'Event Category'],
                                        'Description': ['Description', 'Description in text', 'Event Description'],
                                        'Label': ['Label', 'Event Label', 'Short Label']};
SPREADSHEET_FILE_EXTENSION_TO_DELIMITER_DICTIONARY = {'txt': '\t', 'tsv': '\t', 'csv': ','};


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
        return _validate_spreadsheet_after_submission(request);
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
            _delete_file_if_it_exist(os.path.join(app.config['UPLOAD_FOLDER'], filename));
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
    if _delete_file_if_it_exist(os.path.join(app.config['UPLOAD_FOLDER'], filename)):
        return Response(status=204);
    else:
        abort(404);

def _check_file_extension(filename, accepted_file_extensions):
    """Checks the file extension against a list of accepted ones.

    Parameters
    ----------
    filename: string
        The name of the file.

    accepted_file_extensions: list
        A list containing all of the accepted file extensions.

    Returns
    -------
    boolean
        True if the file has a valid file extension.

    """
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in accepted_file_extensions;

def _validate_spreadsheet_after_submission(validation_form_request_object):
    """Validate the spreadsheet in the form after submission and return an attachment file containing the output.

    Parameters
    ----------
    validation_form_request_object: Request object
        A Request object containing user data from the validation form.

    Returns
    -------
        string
        A serialized JSON string containing information related to the worksheet columns. If the validation fails then a
        500 error message is returned.
    """
    validation_status = {};
    spreadsheet_file = validation_form_request_object.files['spreadsheet'];
    if _file_has_valid_extension(spreadsheet_file, SPREADSHEET_FILE_EXTENSIONS):
        try:
            spreadsheet_file_path = _save_spreadsheet_file_to_upload_folder(spreadsheet_file);
            validation_input_arguments = _get_validation_input_arguments_from_validation_form(
                validation_form_request_object, spreadsheet_file_path);
            validation_issues = _report_spreadsheet_validation_issues(validation_input_arguments);
            validation_status['downloadFile'] = _save_validation_issues_to_file_in_upload_folder(
                spreadsheet_file.filename, validation_issues);
            validation_status['rowIssueCount'] = _get_the_number_of_rows_with_validation_issues(validation_issues);
        except:
            return abort(500);
        finally:
            _delete_file_if_it_exist(spreadsheet_file_path);
    return json.dumps(validation_status);

def _get_the_number_of_rows_with_validation_issues(validation_issues):
    """Gets the number of rows in the spreadsheet that has validation issues.

    Parameters
    ----------
    validation_issues: string
        A string containing the validation issues found in the spreadsheet.

    Returns
    -------
        integer
        A integer representing the number of spreadsheet rows that had validation issues.
    """
    number_of_rows_with_issues = 0;
    split_validation_issues = validation_issues.split('\n');
    if split_validation_issues != ['']:
        for validation_issue_line in split_validation_issues:
            if not validation_issue_line.startswith('\t'):
                number_of_rows_with_issues += 1;
    return number_of_rows_with_issues;

def _save_validation_issues_to_file_in_upload_folder(spreadsheet_file_name, validation_issues):
    """Saves the validation issues found to a file in the upload folder.

    Parameters
    ----------
    spreadsheet_file_name: string
        The name of the spreadsheet.
    validation_issues: string
        A string containing the validation issues.

    Returns
    -------
    string
        The name of the validation output file.

    """
    validation_issues_filename = _generate_spreadsheet_validation_filename(spreadsheet_file_name);
    validation_issues_file_path = os.path.join(app.config['UPLOAD_FOLDER'], validation_issues_filename);
    with open(validation_issues_file_path, 'w') as validation_issues_file:
        validation_issues_file.write(validation_issues);
    return validation_issues_filename;

def _file_has_valid_extension(file_object, accepted_file_extensions):
    """Checks to see if a file has a valid file extension.

    Parameters
    ----------
    file_object: File object
        A file object that points to a file.
    accepted_file_extensions: list
        A list of file extensions that are accepted

    Returns
    -------
    boolean
        True if the file has a valid file extension.

    """
    return file_object and _check_file_extension(file_object.filename, accepted_file_extensions);

def _generate_spreadsheet_validation_filename(spreadsheet_filename):
    """Generates a filename for the attachment that will contain the spreadsheet validation issues.

    Parameters
    ----------
    spreadsheet_filename: string
        The name of the spreadsheet file.
    Returns
    -------
    string
        The name of the attachment file containing the validation issues.
    """
    return 'validated_' + secure_filename(spreadsheet_filename).rsplit('.')[0] + '.txt';

def _get_file_extension(file_name_or_path):
    """Get the file extension from the specified filename. This can be the full path or just the name of the file.

       Parameters
       ----------
       file_name_or_path: string
           The name or full path of a file.

       Returns
       -------
       string
           The extension of the file.
       """
    return secure_filename(file_name_or_path).rsplit('.')[-1];

def _get_validation_input_arguments_from_validation_form(validation_form_request_object, workbook_file_path):
    """Gets the validation function input arguments from a request object associated with the validation form.

    Parameters
    ----------
    validation_form_request_object: Request object
        A Request object containing user data from the validation form.
    workbook_file_path: string
        The path to the workbook file.

    Returns
    -------
    dictionary
        A dictionary containing input arguments for calling the underlying validation function.
    """
    validation_input_arguments = {};
    validation_input_arguments['spreadsheet_path'] = workbook_file_path;
    validation_input_arguments['tag_columns'] = map(int, validation_form_request_object.form['tag-columns'].split(','))
    validation_input_arguments['required_tag_columns'] = \
        get_required_tag_columns_from_validation_form(validation_form_request_object);
    validation_input_arguments['worksheet'] = _get_optional_validation_form_field(
        validation_form_request_object, 'worksheet', 'string');
    validation_input_arguments['has_column_names'] = _get_optional_validation_form_field(
        validation_form_request_object, 'has-column-names', 'boolean');
    validation_input_arguments['check_for_warnings'] = _get_optional_validation_form_field(
        validation_form_request_object, 'generate-warnings', 'boolean');
    return validation_input_arguments;

def get_required_tag_columns_from_validation_form(validation_form_request_object):
    """Gets the validation function input arguments from a request object associated with the validation form.

    Parameters
    ----------
    validation_form_request_object: Request object
        A Request object containing user data from the validation form.

    Returns
    -------
    dictionary
        A dictionary containing the required tag columns. The keys will be the column numbers and the values will be
        the name of the column.
    """
    required_tag_columns = {};
    for tag_column_name in REQUIRED_TAG_COLUMN_NAMES:
        form_tag_column_name = tag_column_name.lower()+'-column';
        if form_tag_column_name in validation_form_request_object.form:
            tag_column_name_index = validation_form_request_object.form[form_tag_column_name].strip();
            if tag_column_name_index:
                tag_column_name_index = int(tag_column_name_index);
                required_tag_columns[tag_column_name_index] = tag_column_name;
    return required_tag_columns;

def _get_optional_validation_form_field(validation_form_request_object, form_field_name, type=''):
    """Gets the specified optional form field if present.

    Parameters
    ----------
    validation_form_request_object: Request object
        A Request object containing user data from the validation form.
    form_field_name: string
        The name of the optional form field.

    Returns
    -------
    boolean or string
        A boolean or string value based on the form field type.

    """
    if type == 'boolean':
        form_field_value = False;
        if form_field_name in validation_form_request_object.form:
            form_field_value = True;
    elif type == 'string':
        form_field_value = '';
        if form_field_name in validation_form_request_object.form:
            form_field_value = validation_form_request_object.form[form_field_name];
    return form_field_value;

def _delete_file_if_it_exist(file_path):
    """Deletes a file if it exist.

    Parameters
    ----------
    file_path: string
        The path to a file.

    Returns
    -------
    boolean
        True if the file exist and was deleted.
    """
    if os.path.isfile(file_path):
        os.remove(file_path);
        return True;
    return False;

def _create_upload_folder_if_needed():
    """Checks to see if the upload folder exist. If it doesn't then it creates it.

    Returns
    -------
    boolean
        True if the upload folder needed to be created, False if otherwise.

    """
    folder_needed_to_be_created = False;
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER']);
        folder_needed_to_be_created = True;
    return folder_needed_to_be_created;


def _save_file_to_upload_folder(file_object, file_suffix=""):
    """Save a file to the upload folder.

    Parameters
    ----------
    file_object: File object
        A file object that points to a file that was first saved in a temporary location.

    Returns
    -------
    string
        The path to the file that was saved to the temporary folder.

    """
    _create_upload_folder_if_needed();
    temporary_upload_file = tempfile.NamedTemporaryFile(suffix=file_suffix, delete=False, \
                                                        dir=app.config['UPLOAD_FOLDER']);
    _copy_file_line_by_line(file_object, temporary_upload_file);
    return temporary_upload_file.name;

def _copy_file_line_by_line(file_object_1, file_object_2):
    """Copy the contents of one file to the other file.

    Parameters
    ----------
    file_object_1: File object
        A file object that points to a file that will be copied.
    file_object_2: File object
        A file object that points to a file that will copy the other file.

    Returns
    -------
    boolean
       True if the file was copied successfully, False if it wasn't.

    """
    try:
        for line in file_object_1:
            file_object_2.write(line);
        return True;
    except:
        return False;

def _report_spreadsheet_validation_issues(validation_arguments):
    """Validates the HED tags in a worksheet by calling the validateworksheethedtags() function using the MATLAB engine.

    The underlying validateworksheethedtags() MATLAB function is called to do the validation.

    Parameters
    ----------
    validation_arguments: dictionary
        A dictionary containing the arguments for the validation function.
    matlab_engine: Object
        A MATLAB engine object.

    Returns
    -------
    list
        A list of strings containing the validation issues that were found. Each list element pertains to a particular
        row in the worksheet that generated issues.

    """
    hed_input_reader = HedInputReader(validation_arguments['spreadsheet_path'],
                                      tag_columns=validation_arguments['tag_columns'],
                                      has_column_names=validation_arguments['has_column_names'],
                                      required_tag_columns=validation_arguments['required_tag_columns'],
                                      worksheet_name=validation_arguments['worksheet'],
                                      check_for_warnings=validation_arguments['check_for_warnings']);
    return hed_input_reader.get_validation_issues();


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
        worksheets_info = _initialize_worksheets_info_dictionary();
        if _spreadsheet_file_present_in_form(request):
            workbook_file = request.files['spreadsheet_file'];
            workbook_file_path = _save_spreadsheet_file_to_upload_folder(workbook_file);
            if workbook_file_path:
                worksheets_info = _populate_worksheets_info_dictionary(worksheets_info, workbook_file_path);
    except:
        return abort(500);
    finally:
        _delete_file_if_it_exist(workbook_file_path);
    return json.dumps(worksheets_info);

def _spreadsheet_file_present_in_form(validation_form_request_object):
    """Checks to see if a spreadsheet file is present in a request object from validation form.

    Parameters
    ----------
    validation_form_request_object: Request object
        A Request object containing user data from the validation form.

    Returns
    -------
    boolean
        True if a spreadsheet file is present in a request object from the validation form.

    """
    return 'spreadsheet_file' in validation_form_request_object.files

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
        spreadsheet_columns_info = _initialize_spreadsheet_columns_info_dictionary();
        if _spreadsheet_file_present_in_form(request):
            spreadsheet_file = request.files['spreadsheet_file'];
            spreadsheet_file_path = _save_spreadsheet_file_to_upload_folder(spreadsheet_file);
            if spreadsheet_file_path and _worksheet_name_present_in_form(request):
                worksheet_name = request.form['worksheet_name'];
                spreadsheet_columns_info = _populate_spreadsheet_columns_info_dictionary(spreadsheet_columns_info, \
                                                                                         spreadsheet_file_path, \
                                                                                         worksheet_name);
            else:
                spreadsheet_columns_info = _populate_spreadsheet_columns_info_dictionary(spreadsheet_columns_info, \
                                                                                         spreadsheet_file_path);
        return json.dumps(spreadsheet_columns_info);
    except:
        return abort(500);
    finally:
        _delete_file_if_it_exist(spreadsheet_file_path);

def _initialize_worksheets_info_dictionary():
    """Initializes a dictionary that will hold information related to the Excel worksheets.

    This information contains the names of the worksheets in a workbook, the names of the columns in the first
    worksheet, and column indices that contain HED tags in the first worksheet.

    Parameters
    ----------

    Returns
    -------
    dictionary
        A dictionary that will hold information related to the Excel worksheets.

    """
    worksheets_info = {'worksheetNames': [], 'columnNames': [], 'tagColumnIndices': []};
    return worksheets_info;

def _initialize_spreadsheet_columns_info_dictionary():
    """Initializes a dictionary that will hold information related to the spreadsheet columns.

    This information contains the names of the spreadsheet columns and column indices that contain HED tags.

    Parameters
    ----------

    Returns
    -------
    dictionary
        A dictionary that will hold information related to the spreadsheet columns.

    """
    worksheet_columns_info = {'columnNames': [], 'tagColumnIndices': []};
    return worksheet_columns_info;

def _populate_worksheets_info_dictionary(worksheets_info, spreadsheet_file_path):
    """Populate dictionary with information related to the Excel worksheets.

    This information contains the names of the worksheets in a workbook, the names of the columns in the first
    worksheet, and column indices that contain HED tags in the first worksheet.

    Parameters
    ----------
    worksheets_info: dictionary
        A dictionary that contains information related to the Excel worksheets.
    spreadsheet_file_path: string
        The full path to an Excel workbook file.

    Returns
    -------
    dictionary
        A dictionary populated with information related to the Excel worksheets.

    """
    worksheets_info['worksheetNames'] = _get_excel_workbook_worksheet_names(spreadsheet_file_path);
    worksheets_info['columnNames'] = _get_worksheet_column_names(spreadsheet_file_path,
                                                                            worksheets_info['worksheetNames'][0]);
    worksheets_info['tagColumnIndices'] = _get_spreadsheet_tag_column_indices(worksheets_info['columnNames']);
    worksheets_info['requiredTagColumnIndices'] = \
        _get_spreadsheet_required_tag_column_indices(worksheets_info['columnNames']);
    return worksheets_info;

def _populate_spreadsheet_columns_info_dictionary(spreadsheet_columns_info, spreadsheet_file_path,
                                                  worksheet_name=''):
    """Populate dictionary with information related to the spreadsheet columns.

    This information contains the names of the spreadsheet columns and column indices that contain HED tags.

    Parameters
    ----------
    spreadsheet_columns_info: dictionary
        A dictionary that contains information related to the spreadsheet column.
    spreadsheet_file_path: string
        The full path to a spreadsheet file.
    worksheet_name: string
        The name of an Excel worksheet.

    Returns
    -------
    dictionary
        A dictionary populated with information related to the spreadsheet columns.

    """
    if worksheet_name:
        spreadsheet_columns_info['columnNames'] = _get_worksheet_column_names(spreadsheet_file_path,
                                                                              worksheet_name);
    else:
        column_delimiter = get_column_delimiter_based_on_file_extension(spreadsheet_file_path);
        spreadsheet_columns_info['columnNames'] = get_text_file_column_names(spreadsheet_file_path,
                                                                             column_delimiter);
    spreadsheet_columns_info['tagColumnIndices'] = \
        _get_spreadsheet_tag_column_indices(spreadsheet_columns_info['columnNames']);
    spreadsheet_columns_info['requiredTagColumnIndices'] = \
        _get_spreadsheet_required_tag_column_indices(spreadsheet_columns_info['columnNames']);
    return spreadsheet_columns_info;

def get_text_file_column_names(text_file_path, column_delimiter):
    """Gets the text spreadsheet column names.

    Parameters
    ----------
    text_file_path: string
        The path to a text file.
    column_delimiter: string
        The spreadsheet column delimiter.

    Returns
    -------
    string
        The spreadsheet column delimiter based on the file extension.

    """
    with open(text_file_path, 'r') as opened_text_file:
        first_line = opened_text_file.readline();
        text_file_columns = first_line.split(column_delimiter);
    return text_file_columns;

def get_column_delimiter_based_on_file_extension(file_name_or_path):
    """Gets the spreadsheet column delimiter based on the file extension.

    Parameters
    ----------
    file_name_or_path: string
        A file name or path.

    Returns
    -------
    string
        The spreadsheet column delimiter based on the file extension.

    """
    column_delimiter = '';
    file_extension = _get_file_extension(file_name_or_path);
    if file_extension in SPREADSHEET_FILE_EXTENSION_TO_DELIMITER_DICTIONARY:
        column_delimiter = SPREADSHEET_FILE_EXTENSION_TO_DELIMITER_DICTIONARY.get(file_extension);
    return column_delimiter;

def _worksheet_name_present_in_form(validation_form_request_object):
    """Checks to see if a worksheet name is present in a request object from the validation form.

    Parameters
    ----------
    validation_form_request_object: Request object
        A Request object containing user data from the validation form.

    Returns
    -------
    boolean
        True if a worksheet name is present in a request object from the validation form.

    """
    return 'worksheet_name' in validation_form_request_object.form;

def _save_spreadsheet_file_to_upload_folder(spreadsheet_file_object):
    """Save an spreadsheet file to the upload folder.

    Parameters
    ----------
    spreadsheet_file_object: File object
        A file object that points to a spreadsheet that was first saved in a temporary location.

    Returns
    -------
    string
        The path to the spreadsheet that was saved to the upload folder.

    """
    spreadsheet_file_extension = '.' + _get_file_extension(spreadsheet_file_object.filename);
    spreadsheet_file_path = _save_file_to_upload_folder(spreadsheet_file_object, spreadsheet_file_extension);
    return spreadsheet_file_path;

def _get_excel_workbook_worksheet_names(workbook_file_path):
    """Gets the worksheet names in an Excel workbook.

    Parameters
    ----------
    workbook_file_path: string
        The full path to an Excel workbook file.

    Returns
    -------
    list
        A list containing the worksheet names in an Excel workbook.

    """
    opened_workbook_file = xlrd.open_workbook(workbook_file_path);
    worksheet_names = opened_workbook_file.sheet_names();
    return worksheet_names;

def _get_spreadsheet_tag_column_indices(column_names):
    """Gets the tag column indices in a spreadsheet. The indices found will be one-based.

    Parameters
    ----------
    column_names: list
        A list containing the column names in a spreadsheet.

    Returns
    -------
    list
        A list containing the tag column indices found in a spreadsheet.

    """
    tag_column_indices = [];
    for tag_column_name in TAG_COLUMN_NAMES:
        tag_column_index = _find_str_index_in_list(column_names, tag_column_name);
        if tag_column_index != -1:
            tag_column_indices.append(tag_column_index);
    return tag_column_indices;

def _get_spreadsheet_required_tag_column_indices(column_names):
    """Gets the required tag column indices in a spreadsheet. The indices found will be one-based.

    Parameters
    ----------
    column_names: list
        A list containing the column names in a spreadsheet.

    Returns
    -------
    dictionary
        A dictionary containing the required tag column indices found in a spreadsheet.

    """
    required_tag_column_indices = {};
    required_tag_column_names = REQUIRED_TAG_COLUMN_NAMES_DICTIONARY.keys();
    for required_tag_column_name in required_tag_column_names:
        alternative_required_tag_column_names = REQUIRED_TAG_COLUMN_NAMES_DICTIONARY[required_tag_column_name];
        for alternative_required_tag_column_name in alternative_required_tag_column_names:
            required_tag_column_index = _find_str_index_in_list(column_names, alternative_required_tag_column_name);
            if required_tag_column_index != -1:
                required_tag_column_indices[required_tag_column_name] = required_tag_column_index;
    return required_tag_column_indices;

def _find_str_index_in_list(list_of_strs, str_value):
    """Find the index of a string value in a list.

    Parameters
    ----------
    list_of_strs: list
        A list containing strings.
    str_value: string
        A string value.

    Returns
    -------
    integer
        An positive integer if the string value was found in the list. A -1 is returned if the string value was not
        found.

    """
    try:
        return [s.lower() for s in list_of_strs].index(str_value.lower()) + 1;
    except ValueError:
        return -1;

def _get_worksheet_column_names(workbook_file_path, worksheet_name):
    """Get the worksheet columns in a Excel workbook.

    Parameters
    ----------
    workbook_file_path : string
        The full path to an Excel workbook file.
    worksheet_name : string
        The name of an Excel worksheet.

    Returns
    -------
    list
        A list containing the worksheet columns in an Excel workbook.

    """
    opened_workbook_file = xlrd.open_workbook(workbook_file_path);
    opened_worksheet = opened_workbook_file.sheet_by_name(worksheet_name);
    worksheet_column_names = [opened_worksheet.cell(0, col_index).value for col_index in xrange(opened_worksheet.ncols)];
    return worksheet_column_names;

if __name__ == '__main__':
    app.config.update(TEMPLATES_AUTO_RELOAD=True);
    app.run(debug=True);