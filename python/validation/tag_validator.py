'''
This module is used to validate the HED tags as strings.

Created on Oct 2, 2017

@author: Jeremy Cockfield

'''

import random;
from validation import error_reporter, tag_dictionary;
from itertools import compress;

REQUIRE_CHILD_ERROR_TYPE = 'requireChild';
TAG_DICTIONARY_KEY = 'tags';
TILDE_ERROR_TYPE = 'tilde';
UNIQUE_ERROR_TYPE = 'unique';
VALID_ERROR_TYPE = 'valid';

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
    if not tag_dictionaries[TAG_DICTIONARY_KEY].get(formatted_tag):
        validation_error = error_reporter.report_error_type(VALID_ERROR_TYPE, tag=original_tag);
    return validation_error;

def check_number_of_group_tildes(group_tag_string):
    """Reports a validation error if the tag group has too many tildes.

    Parameters
    ----------
    group_tag_string: string
        A group tag string.
    Returns
    -------
    string
        A validation error string. If no errors are found then an empty string is returned.

    """
    validation_error = '';
    if group_tag_string.count('~') > 2:
        validation_error = error_reporter.report_error_type(TILDE_ERROR_TYPE, group_tag_string);
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
    if tag_dictionaries[REQUIRE_CHILD_ERROR_TYPE].get(formatted_tag):
        validation_error = error_reporter.report_error_type(REQUIRE_CHILD_ERROR_TYPE, tag=original_tag);
    return validation_error;

def check_if_multiple_unique_tags_exist(tag_dictionaries, original_tag_list, formatted_tag_list):
    """Reports a validation error if two or more tags start with a tag prefix that has the 'unique' attribute.

    Parameters
    ----------
    tag_dictionaries: dictionary
        A dictionary containing containing all of the tags, tag attributes, unit class units, and unit class attributes.
    original_tag_list: list
        A list containing tags that are used to report the error.
    formatted_tag_list: list
        A list containing tags that are used to do the validation.
    Returns
    -------
    string
        A validation error string. If no errors are found then an empty string is returned.

    """
    validation_error = '';
    unique_tag_prefixes = tag_dictionaries[UNIQUE_ERROR_TYPE];
    for unique_tag_prefix in unique_tag_prefixes:
        unique_tag_prefix_boolean_mask = [x.startswith(unique_tag_prefix) for x in formatted_tag_list];
        if sum(unique_tag_prefix_boolean_mask) > 1:
            unique_original_tag_list = list(compress(original_tag_list, unique_tag_prefix_boolean_mask));
            for unique_original_tag in unique_original_tag_list:
                validation_error += error_reporter.report_error_type(UNIQUE_ERROR_TYPE, tag=unique_original_tag, \
                                                                    tag_prefix=unique_tag_prefix);
    return validation_error;

if __name__ == '__main__':
    hed_xml = '../tests/data/HED.xml';
    tag_dictionaries = tag_dictionary.populate_tag_dictionaries(hed_xml);
    a = ['Event/Label/This is a label', 'Event/Label/This is another label', 'Event/Description/This is a description'];
    b = ['event/label/this is a label', 'event/label/this is another label', 'event/description/this is a description'];
    validation_error = check_if_multiple_unique_tags_exist(tag_dictionaries, a, b);
    print(validation_error);
