'''
This module is used to validate the HED tags as strings.

Created on Oct 2, 2017

@author: Jeremy Cockfield

'''

from validation import error_reporter, tag_dictionary;
from itertools import compress;
import re;

REQUIRE_CHILD_ERROR_TYPE = 'requireChild';
REQUIRED_ERROR_TYPE = 'required';
TAG_DICTIONARY_KEY = 'tags';
TILDE_ERROR_TYPE = 'tilde';
UNIQUE_ERROR_TYPE = 'unique';
VALID_ERROR_TYPE = 'valid';
EXTENSION_ALLOWED_ATTRIBUTE = 'extensionAllowed';
TAKES_VALUE_ATTRIBUTE = 'takesValue';

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
    if is_extension_allowed_tag(tag_dictionaries, formatted_tag):
        pass;
    elif not tag_dictionaries[TAG_DICTIONARY_KEY].get(formatted_tag):
        validation_error = error_reporter.report_error_type(VALID_ERROR_TYPE, tag=original_tag);
    return validation_error;

def is_extension_allowed_tag(tag_dictionaries, tag):
    """Checks to see if the tag has the 'extensionAllowed' attribute. It will strip the tag until there are no more
    slashes to check if its ancestors have the attribute.

    Parameters
    ----------
    tag_dictionaries: dictionary
        A dictionary containing containing all of the tags, tag attributes, unit class units, and unit class attributes.
    tag: string
        A tag.
    Returns
    -------
    boolean
        True if the tag has the 'extensionAllowed' attribute. False, if otherwise.

    """
    tag_slash_indices = get_tag_slash_indices(tag);
    for tag_slash_index in tag_slash_indices:
        tag_substring = get_tag_substring_by_end_index(tag, tag_slash_index);
        if tag_dictionary.tag_has_attribute(tag_dictionaries, tag_substring, EXTENSION_ALLOWED_ATTRIBUTE):
            return True;
    return False;

def tag_takes_value(tag_dictionaries, tag):
    """Checks to see if the tag has the 'takesValue' attribute.

    Parameters
    ----------
    tag_dictionaries: dictionary
        A dictionary containing containing all of the tags, tag attributes, unit class units, and unit class attributes.
    tag: string
        A tag.
    Returns
    -------
    boolean
        True if the tag has the 'takesValue' attribute. False, if otherwise.

    """
    last_tag_slash_index = tag.rfind('/');
    if last_tag_slash_index != -1:
        takes_value_tag = tag[:last_tag_slash_index] + '/#';
        return tag_dictionary.tag_has_attribute(tag_dictionaries, takes_value_tag, TAKES_VALUE_ATTRIBUTE);
    return False;

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


def check_for_required_tags(tag_dictionaries, formatted_tag_list):
    """Reports a validation error if the required tags aren't present.

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
    required_tag_prefixes = tag_dictionaries[REQUIRED_ERROR_TYPE];
    for required_tag_prefix in required_tag_prefixes:
        if sum([x.startswith(required_tag_prefix) for x in formatted_tag_list]) < 1:
            validation_error += error_reporter.report_error_type(REQUIRED_ERROR_TYPE,
                                                                 tag_prefix=required_tag_prefix);
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
                validation_error += error_reporter.report_error_type(UNIQUE_ERROR_TYPE, tag=unique_original_tag,
                                                                    tag_prefix=unique_tag_prefix);
    return validation_error;

def get_tag_slash_indices(tag, slash='/'):
    """Gets all of the indices in a tag that are slashes.

    Parameters
    ----------
    tag: string
        A tag.
    slash: string
        The slash character. By default it is a forward slash.
    Returns
    -------
    list
        A list containing the indices of the tag slashes.

    """
    return [s.start() for s in re.finditer(slash, tag)];

def get_tag_substring_by_end_index(tag, end_index):
    """Gets a tag substring from the start until the end index.

    Parameters
    ----------
    tag: string
        A tag.
    end_index: int
        A index for the tag substring to end.
    Returns
    -------
    string
        A tag substring.

    """
    if end_index != 0:
        return tag[:end_index]
    return tag;

if __name__ == '__main__':
    print('yes')
    # hed_xml = '../tests/data/HED.xml';
    # tag_dictionaries = tag_dictionary.populate_tag_dictionaries(hed_xml);
