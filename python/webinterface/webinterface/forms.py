'''
Created on Apr 27, 2017

@author: jcockfie
'''
from wtforms import BooleanField, StringField, validators, SelectField
from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileAllowed

class NonValidatingSelectField(SelectField):
    """
    Attempt to make an open ended select multiple field that can accept dynamic
    choices added by the browser.
    """
    def pre_validate(self, form):
        pass

class ValidationForm(FlaskForm):
    spreadsheet = FileField('1) Select Spreadsheet', validators=[FileAllowed(['xls', 'xlsx', 'txt', 'tsv', 'csv'],
                                                                          'Excel or text spreadsheets only!')]);
    worksheet = NonValidatingSelectField('2) Choose a worksheet', coerce=str, choices=[]);
    tag_columns = StringField('3) Select tag columns',
                              [validators.Optional(),
                               validators.Regexp('^\s*(\d+(\s*,\s*\d+)*)?\s*$',
                                                 message = 'Must be a number or a comma-separated list of numbers')]);
    has_headers = BooleanField('5) Skip headers line', default=True);
    generate_warnings = BooleanField('Include warnings in output file');