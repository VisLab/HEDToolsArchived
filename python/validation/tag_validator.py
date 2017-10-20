'''
This module is used to validate the HED tags as strings.

Created on Oct 2, 2017

@author: Jeremy Cockfield

'''

import random;

from validation import error_reporter, tag_dictionary;

def check_if_tag_is_valid(tag_dictionaries, original_tag, formatted_tag):
    """Reports a validation error if the tag provided is not a valid tag or doesn't take a value.

    Parameters
    ----------
    tag_dictionaries: dictionary
        A dictionary containing containing all of the tags, tag attributes, unit class units, and unit class attributes.
    original_tag: string
        The original tag that is used to report the error.
    formatted_tag: string
        The tag that is used to do the validation.
    Returns
    -------
    string
        A validation error string. If no errors are found then an empty string is returned.

    """
    validation_error = '';
    error_type = 'valid';
    if not tag_dictionaries['tags'].get(formatted_tag):
        validation_error = error_reporter.report_error_type(error_type, tag=original_tag);
    return validation_error;

def check_if_tag_requires_child(tag_dictionaries, original_tag, formatted_tag):
    """Reports a validation error if the tag provided has the 'requireChild' attribute.

    Parameters
    ----------
    tag_dictionaries: dictionary
        A dictionary containing containing all of the tags, tag attributes, unit class units, and unit class attributes.
    original_tag: string
        The original tag that is used to report the error.
    formatted_tag: string
        The tag that is used to do the validation.
    Returns
    -------
    string
        A validation error string. If no errors are found then an empty string is returned.

    """
    validation_error = '';
    error_type = 'requireChild';
    if tag_dictionaries['requireChild'].get(formatted_tag):
        validation_error = error_reporter.report_error_type(error_type, tag=original_tag);
    return validation_error;

if __name__ == '__main__':
    tag_dictionaries = tag_dictionary.populate_tag_dictionaries('../tests/data/HED.xml');
    random_require_child_key = random.randint(0, len(tag_dictionaries['requireChild']));
    print(tag_dictionaries.keys());
    # required_child_tag = \
    #     tag_dictionaries['requireChild']];
